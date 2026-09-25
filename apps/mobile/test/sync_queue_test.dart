import 'dart:math';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';
import 'package:shilpsetu_mobile/offline/database.dart';
import 'package:shilpsetu_mobile/offline/media_store.dart';
import 'package:shilpsetu_mobile/offline/sync_queue.dart';

/// A fake server that behaves like the real resumable-upload API and can drop the connection mid-upload.
class FakeServer implements SyncApi {
  final uploads = <String, Map<String, dynamic>>{}; // idempotency key -> state
  final data = <String, BytesBuilder>{};
  final drafts = <String, Map<String, dynamic>>{};
  int dropAfterChunks = -1;
  int chunks = 0;
  bool offline = false;

  void _net() {
    if (offline) throw ApiException(0, 'network: offline');
  }

  @override
  Future<Map<String, dynamic>> createUpload(String key, String kind, String ct, int size, String sha) async {
    _net();
    final u = uploads.putIfAbsent(key, () => {'upload_id': 'u-$key', 'received': 0, 'total_size': size, 'status': 'open'});
    data.putIfAbsent(u['upload_id'], () => BytesBuilder());
    return Map.of(u);
  }

  @override
  Future<Map<String, dynamic>> putChunk(String uploadId, int offset, Uint8List bytes) async {
    _net();
    if (dropAfterChunks >= 0 && chunks++ >= dropAfterChunks) {
      dropAfterChunks = -1;
      throw ApiException(0, 'network: connection reset');
    }
    final u = uploads.values.firstWhere((u) => u['upload_id'] == uploadId);
    final have = u['received'] as int;
    final fresh = offset < have ? bytes.sublist(have - offset) : bytes;
    data[uploadId]!.add(fresh);
    u['received'] = have + fresh.length;
    return Map.of(u);
  }

  @override
  Future<Map<String, dynamic>> complete(String uploadId) async {
    _net();
    final u = uploads.values.firstWhere((u) => u['upload_id'] == uploadId);
    expect(u['received'], u['total_size']);
    u['status'] = 'complete';
    return Map.of(u);
  }

  @override
  Future<Map<String, dynamic>> createDraft(Map<String, dynamic> body, {String? actAsArtisanId}) async {
    _net();
    return drafts.putIfAbsent(body['idempotency_key'], () => {
          'id': 'p${drafts.length + 1}',
          'status': 'processing',
          'title': null,
          'body': body,
          'artisan': actAsArtisanId,
        });
  }

  @override
  Future<Map<String, dynamic>> status(String deviceId, List<String> keys, {String? actAsArtisanId}) async {
    _net();
    return {
      for (final k in keys)
        if (drafts.containsKey(k)) k: {'status': 'ready', 'title': 'Hand-painted Blue Pottery Vase', 'price': 1450}
    };
  }
}

void main() {
  late LocalDb db;
  late FakeServer server;
  late SyncQueue q;
  var now = DateTime(2026, 9, 1, 10);

  setUp(() {
    db = LocalDb(NativeDatabase.memory());
    server = FakeServer();
    now = DateTime(2026, 9, 1, 10);
    q = SyncQueue(db: db, media: MemoryMediaStore(), api: server, deviceId: 'phone-1', chunkSize: 1000,
        clock: () => now, random: Random(1));
  });
  tearDown(() => db.close());

  Uint8List bytes(int n, [int seed = 1]) => Uint8List.fromList(List.generate(n, (i) => (i * seed) % 251));

  test('capture works offline and syncs when the network returns', () async {
    q.online = false;
    final id = await q.enqueue(language: 'hi', audio: bytes(3500), photos: [bytes(5200, 3)], deviceTranscript: 'नीली पॉटरी का फूलदान');
    await q.load();
    expect(q.items.single.status, 'queued');
    expect(server.drafts, isEmpty);

    q.online = true;
    await q.run();
    final c = q.items.single;
    expect(c.id, id);
    expect(c.productId, 'p1');
    expect(c.status, 'ready'); // server status pulled back (server wins for model outputs)
    expect(c.title, 'Hand-painted Blue Pottery Vase');
    expect(server.data['u-${c.idempotencyKey}-1']!.length, 5200);
  });

  test('resumes a photo upload after the connection drops mid-way', () async {
    server.dropAfterChunks = 2; // third chunk fails
    await q.enqueue(language: 'hi', photos: [bytes(5000, 7)]);
    await q.run();
    var c = q.items.single;
    expect(c.status, 'queued');
    expect(c.attempts, 1);
    expect(c.lastError, contains('connection reset'));
    final partial = server.uploads['${c.idempotencyKey}-1']!['received'] as int;
    expect(partial, 2000);

    // backoff: not retried before the next attempt time
    q.online = true;
    await q.run();
    expect(q.items.single.attempts, 1);
    expect(server.drafts, isEmpty);

    now = now.add(const Duration(minutes: 1));
    await q.run();
    c = q.items.single;
    expect(c.status, 'ready');
    expect(server.data['u-${c.idempotencyKey}-1']!.length, 5000); // no duplicated bytes
  });

  test('retries never create duplicate listings (idempotency key)', () async {
    await q.enqueue(language: 'bn', photos: [bytes(800)]);
    await q.run();
    final key = q.items.single.idempotencyKey;
    await q.retryNow(q.items.single.id);
    await q.retryNow(q.items.single.id);
    expect(server.drafts.keys.where((k) => k == key).length, 1);
    expect(server.drafts.length, 1);
  });

  test('backoff grows exponentially and is capped', () {
    expect(q.backoff(1).inSeconds, inInclusiveRange(5, 6));
    expect(q.backoff(3).inSeconds, inInclusiveRange(20, 24));
    expect(q.backoff(20).inMinutes, inInclusiveRange(30, 36));
  });

  test('client errors are marked failed, not retried forever', () async {
    q.api = _Rejecting(server);
    await q.enqueue(language: 'hi', photos: [bytes(100)]);
    await q.run();
    expect(q.items.single.status, 'failed');
  });

  test('kiosk captures carry the artisan they were made for', () async {
    await q.enqueue(language: 'hi', photos: [bytes(100)], actAsArtisanId: 'artisan-42');
    await q.run();
    expect(server.drafts.values.single['artisan'], 'artisan-42');
  });

  test('voice answers are uploaded and attached to the draft', () async {
    await q.enqueue(language: 'hi', photos: [bytes(100)], answers: [
      {'field': 'time_hours', 'audio': bytes(300), 'ext': 'wav'},
      {'field': 'material_cost', 'text': 'तीन सौ'},
    ]);
    await q.run();
    final answers = (server.drafts.values.single['body'] as Map)['answers'] as List;
    expect(answers[0]['upload_id'], isNotNull);
    expect(answers[1]['text'], 'तीन सौ');
  });
}

class _Rejecting extends FakeServer {
  _Rejecting(this.inner);
  final FakeServer inner;
  @override
  Future<Map<String, dynamic>> createDraft(Map<String, dynamic> body, {String? actAsArtisanId}) async =>
      throw ApiException(400, 'need at least a voice description or a photo');
}
