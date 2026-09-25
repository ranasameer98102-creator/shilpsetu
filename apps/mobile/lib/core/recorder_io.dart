import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> tempPath() async =>
    p.join((await getTemporaryDirectory()).path, 'voice_${DateTime.now().millisecondsSinceEpoch}.wav');

Future<Uint8List> readRecording(String path) async {
  final f = File(path);
  final bytes = await f.readAsBytes();
  await f.delete();
  return bytes;
}
