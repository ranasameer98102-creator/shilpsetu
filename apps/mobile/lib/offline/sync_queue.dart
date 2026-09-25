import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';
import 'package:uuid/uuid.dart';

import 'database.dart';
import 'media_store.dart';

/// Server operations the queue needs — an interface so the queue can be tested without a network.
abstract class SyncApi {
  Future<Map<String, dynamic>> createUpload(String key, String kind, String contentType, int size, String sha256);
  Future<Map<String, dynamic>> putChunk(String uploadId, int offset, Uint8List bytes);
  Future<Map<String, dynamic>> complete(String uploadId);
  Future<Map<String, dynamic>> createDraft(Map<String, dynamic> body, {String? actAsArtisanId});
  Future<Map<String, dynamic>> status(String deviceId, List<String> keys, {String? actAsArtisanId});
}

class HttpSyncApi implements SyncApi {
  HttpSyncApi(this.api);
  final ApiClient api;

  @override
  Future<Map<String, dynamic>> createUpload(String key, String kind, String ct, int size, String sha) async =>
      Map<String, dynamic>.from(await api.post('/capture/uploads',
          {'idempotency_key': key, 'kind': kind, 'content_type': ct, 'total_size': size, 'sha256': sha}));

  @override
  Future<Map<String, dynamic>> putChunk(String uploadId, int offset, Uint8List bytes) async =>
      Map<String, dynamic>.from(await api.putBytes('/capture/uploads/$uploadId', bytes, {'offset': offset}));

  @override
  Future<Map<String, dynamic>> complete(String uploadId) async =>
      Map<String, dynamic>.from(await api.post('/capture/uploads/$uploadId/complete'));

  Future<T> _as<T>(String? artisanId, Future<T> Function() fn) async {
    final prev = api.actAsArtisanId;
    api.actAsArtisanId = artisanId ?? prev;
    try {
      return await fn();
    } finally {
      api.actAsArtisanId = prev;
    }
  }

  @override
  Future<Map<String, dynamic>> createDraft(Map<String, dynamic> body, {String? actAsArtisanId}) =>
      _as(actAsArtisanId, () async => Map<String, dynamic>.from(await api.post('/products/drafts', body)));

  @override
  Future<Map<String, dynamic>> status(String deviceId, List<String> keys, {String? actAsArtisanId}) =>
      _as(actAsArtisanId, () async =>
          Map<String, dynamic>.from(await api.get('/sync/status', {'device_id': deviceId, 'keys': keys.join(',')})));
}

/// Offline-first capture queue (§9.12): every capture is saved on the phone first, then uploaded with
/// resumable chunks, retried with exponential backoff, and made idempotent so retries never duplicate listings.
class SyncQueue extends ChangeNotifier {
  SyncQueue({required this.db, required this.media, required this.api, required this.deviceId, this.chunkSize = 64 * 1024,
      DateTime Function()? clock, this.random})
      : _clock = clock ?? DateTime.now;

  final LocalDb db;
  final MediaStore media;
  SyncApi api;
  final String deviceId;
  int chunkSize; // lowered in low-bandwidth mode
  final DateTime Function() _clock;
  final Random? random;
  bool online = true;
  Future<void>? _current;
  List<Capture> items = [];

  static const maxBackoff = Duration(minutes: 30);
  static const done = {'live'};

  bool get running => _current != null;
  int get pendingCount => items.where((c) => c.status == 'queued' || c.status == 'uploading').length;
  bool get allSynced => items.every((c) => !{'queued', 'uploading', 'failed'}.contains(c.status));

  Future<void> load() async {
    items = await (db.select(db.captures)..orderBy([(t) => OrderingTerm.desc(t.capturedAt)])).get();
    notifyListeners();
  }

  /// Save a new capture locally (works in airplane mode). Returns the local capture id.
  Future<String> enqueue({
    required String language,
    Uint8List? audio,
    String audioExt = 'wav',
    List<Uint8List> photos = const [],
    String? deviceTranscript,
    List<Map<String, dynamic>> answers = const [],
    String? actAsArtisanId,
    Map<String, dynamic> edits = const {},
  }) async {
    final id = const Uuid().v4();
    String? audioRef;
    if (audio != null) audioRef = await media.save('$id-voice.$audioExt', audio, contentTypeFor('x.$audioExt'));
    final photoRefs = <String>[];
    for (var i = 0; i < photos.length; i++) {
      photoRefs.add(await media.save('$id-photo$i.jpg', photos[i], 'image/jpeg'));
    }
    final storedAnswers = <Map<String, dynamic>>[];
    for (var i = 0; i < answers.length; i++) {
      final a = Map<String, dynamic>.from(answers[i]);
      final bytes = a.remove('audio') as Uint8List?;
      if (bytes != null) a['ref'] = await media.save('$id-answer$i.${a.remove('ext') ?? 'wav'}', bytes, 'audio/wav');
      storedAnswers.add(a);
    }
    await db.into(db.captures).insert(CapturesCompanion.insert(
          id: id,
          idempotencyKey: 'cap-$id',
          actAsArtisanId: Value(actAsArtisanId),
          language: Value(language),
          audioRef: Value(audioRef),
          photoRefs: Value(jsonEncode(photoRefs)),
          deviceTranscript: Value(deviceTranscript),
          answers: Value(jsonEncode(storedAnswers)),
          edits: Value(jsonEncode(edits)),
          capturedAt: _clock(),
        ));
    await load();
    unawaited(run());
    return id;
  }

  Future<void> _update(String id, CapturesCompanion c) async {
    await (db.update(db.captures)..where((t) => t.id.equals(id))).write(c);
  }

  /// Process everything that is due. Safe to call often (connectivity change, timer, app resume);
  /// a call made while a run is in flight waits for that run instead of starting a second one.
  Future<void> run() {
    if (!online) return Future.value();
    return _current ??= _run().whenComplete(() => _current = null);
  }

  Future<void> _run() async {
    notifyListeners();
    try {
      await load();
      final now = _clock();
      for (final c in items.where((c) => c.status == 'queued' || c.status == 'uploading')) {
        if (c.nextAttemptAt != null && c.nextAttemptAt!.isAfter(now)) continue;
        if (!online) break;
        await _push(c);
      }
      await load();
      await refreshStatuses();
    } finally {
      await load();
    }
  }

  Future<void> _push(Capture c) async {
    await _update(c.id, const CapturesCompanion(status: Value('uploading')));
    notifyListeners();
    try {
      final uploads = Map<String, String>.from(jsonDecode(c.uploads) as Map);
      Future<String> ensure(String ref, String kind, int idx) async {
        if (uploads[ref] case final done?) return done;
        final bytes = await media.read(ref);
        final sha = sha256.convert(bytes).toString();
        final ct = contentTypeFor(ref);
        var st = await api.createUpload('${c.idempotencyKey}-$idx', kind, ct, bytes.length, sha);
        final uid = st['upload_id'] as String;
        var off = st['received'] as int;
        while (off < bytes.length && st['status'] != 'complete') {
          final end = min(off + chunkSize, bytes.length);
          st = await api.putChunk(uid, off, Uint8List.sublistView(bytes, off, end));
          off = st['received'] as int;
        }
        if (st['status'] != 'complete') await api.complete(uid);
        uploads[ref] = uid;
        await _update(c.id, CapturesCompanion(uploads: Value(jsonEncode(uploads))));
        return uid;
      }

      String? audioId;
      if (c.audioRef != null) audioId = await ensure(c.audioRef!, 'audio', 0);
      final photoIds = <String>[];
      final photos = (jsonDecode(c.photoRefs) as List).cast<String>();
      for (var i = 0; i < photos.length; i++) {
        photoIds.add(await ensure(photos[i], 'photo', i + 1));
      }
      final answers = <Map<String, dynamic>>[];
      final stored = (jsonDecode(c.answers) as List).cast<Map>();
      for (var i = 0; i < stored.length; i++) {
        final a = Map<String, dynamic>.from(stored[i]);
        final ref = a.remove('ref') as String?;
        if (ref != null) a['upload_id'] = await ensure(ref, 'audio', 10 + i);
        answers.add(a);
      }
      final draft = await api.createDraft({
        'idempotency_key': c.idempotencyKey,
        'device_id': deviceId,
        'language': c.language,
        'audio_upload_id': audioId,
        'photo_upload_ids': photoIds,
        'device_transcript': c.deviceTranscript,
        'answers': answers,
        'captured_offline_at': c.capturedAt.toUtc().toIso8601String(),
        'edits': jsonDecode(c.edits),
      }, actAsArtisanId: c.actAsArtisanId);
      await _update(
          c.id,
          CapturesCompanion(
            status: Value(draft['status'] == 'queued' ? 'processing' : (draft['status'] as String? ?? 'processing')),
            productId: Value(draft['id'] as String?),
            title: Value(draft['title'] as String?),
            price: Value((draft['price'] as num?)?.toDouble()),
            lastError: const Value(null),
          ));
    } on ApiException catch (e) {
      final permanent = !e.isNetwork && e.status >= 400 && e.status < 500 && e.status != 408 && e.status != 429;
      final attempts = c.attempts + 1;
      await _update(
          c.id,
          CapturesCompanion(
            status: Value(permanent ? 'failed' : 'queued'),
            attempts: Value(attempts),
            nextAttemptAt: Value(_clock().add(backoff(attempts))),
            lastError: Value(e.message),
          ));
      if (e.isNetwork) online = false; // stop hammering; connectivity listener will resume us
    }
  }

  /// Exponential backoff with jitter: 5s, 10s, 20s ... capped at 30 min.
  Duration backoff(int attempts) {
    final base = Duration(seconds: 5 * pow(2, min(attempts - 1, 12)).toInt());
    final capped = base > maxBackoff ? maxBackoff : base;
    final jitter = (random ?? Random()).nextDouble() * 0.2 * capped.inMilliseconds;
    return Duration(milliseconds: capped.inMilliseconds + jitter.round());
  }

  /// Server wins for model outputs (status / title / price) once a capture has become a product.
  Future<void> refreshStatuses() async {
    final open = items.where((c) => c.productId != null && !done.contains(c.status)).toList();
    final byArtisan = <String?, List<Capture>>{};
    for (final c in open) {
      byArtisan.putIfAbsent(c.actAsArtisanId, () => []).add(c);
    }
    for (final entry in byArtisan.entries) {
      try {
        final st = await api.status(deviceId, entry.value.map((c) => c.idempotencyKey).toList(),
            actAsArtisanId: entry.key);
        for (final c in entry.value) {
          final s = st[c.idempotencyKey];
          if (s is Map) {
            await _update(
                c.id,
                CapturesCompanion(
                  status: Value(s['status'] as String),
                  title: Value(s['title'] as String?),
                  price: Value((s['price'] as num?)?.toDouble()),
                ));
          }
        }
      } on ApiException catch (e) {
        if (e.isNetwork) online = false;
      }
    }
  }

  Future<void> retryNow(String id) async {
    await _update(id, const CapturesCompanion(status: Value('queued'), nextAttemptAt: Value(null)));
    online = true;
    await run();
  }

  /// Media can be deleted once the server has the product live (keeps phone storage small).
  Future<void> cleanupLive() async {
    for (final c in items.where((c) => c.status == 'live')) {
      for (final ref in [if (c.audioRef != null) c.audioRef!, ...(jsonDecode(c.photoRefs) as List).cast<String>()]) {
        await media.delete(ref);
      }
    }
  }
}
