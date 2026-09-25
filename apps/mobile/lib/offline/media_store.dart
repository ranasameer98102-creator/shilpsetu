import 'dart:typed_data';

import 'package:drift/drift.dart';

import 'database.dart';
import 'media_store_io.dart' if (dart.library.js_interop) 'media_store_web.dart' as platform;

/// Stores captured audio/photos on the device until they are synced.
/// Android: files in the app's private directory. Web: blobs in the local database.
abstract class MediaStore {
  Future<String> save(String name, Uint8List bytes, String contentType);
  Future<Uint8List> read(String ref);
  Future<void> delete(String ref);

  factory MediaStore(LocalDb db) => platform.create(db);
}

class BlobMediaStore implements MediaStore {
  BlobMediaStore(this.db);
  final LocalDb db;

  @override
  Future<String> save(String name, Uint8List bytes, String contentType) async {
    final ref = 'blob:$name';
    await db.into(db.mediaBlobs).insertOnConflictUpdate(
        MediaBlobsCompanion.insert(ref: ref, bytes: bytes, contentType: contentType));
    return ref;
  }

  @override
  Future<Uint8List> read(String ref) async =>
      (await (db.select(db.mediaBlobs)..where((t) => t.ref.equals(ref))).getSingle()).bytes;

  @override
  Future<void> delete(String ref) => (db.delete(db.mediaBlobs)..where((t) => t.ref.equals(ref))).go();
}

/// In-memory store for tests.
class MemoryMediaStore implements MediaStore {
  final _m = <String, Uint8List>{};
  @override
  Future<String> save(String name, Uint8List bytes, String contentType) async {
    _m['mem:$name'] = bytes;
    return 'mem:$name';
  }

  @override
  Future<Uint8List> read(String ref) async => _m[ref]!;
  @override
  Future<void> delete(String ref) async => _m.remove(ref);
}

String contentTypeFor(String ref) {
  final r = ref.toLowerCase();
  if (r.endsWith('.wav')) return 'audio/wav';
  if (r.endsWith('.m4a') || r.endsWith('.aac')) return 'audio/mp4';
  if (r.endsWith('.webm')) return 'audio/webm';
  if (r.endsWith('.ogg')) return 'audio/ogg';
  if (r.endsWith('.png')) return 'image/png';
  if (r.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}
