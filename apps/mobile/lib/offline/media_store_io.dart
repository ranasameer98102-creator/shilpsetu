import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database.dart';
import 'media_store.dart';

MediaStore create(LocalDb db) => FileMediaStore();

class FileMediaStore implements MediaStore {
  Future<Directory> _dir() async {
    final d = Directory(p.join((await getApplicationSupportDirectory()).path, 'captures'));
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  @override
  Future<String> save(String name, Uint8List bytes, String contentType) async {
    final f = File(p.join((await _dir()).path, name));
    await f.writeAsBytes(bytes, flush: true);
    return 'file:${f.path}';
  }

  @override
  Future<Uint8List> read(String ref) => File(ref.substring(5)).readAsBytes();

  @override
  Future<void> delete(String ref) async {
    final f = File(ref.substring(5));
    if (await f.exists()) await f.delete();
  }
}
