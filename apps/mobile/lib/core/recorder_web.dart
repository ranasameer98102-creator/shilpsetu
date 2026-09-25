import 'dart:typed_data';

import 'package:http/http.dart' as http;

Future<String> tempPath() async => '';

/// On the web the recorder returns a blob: URL; fetch its bytes.
Future<Uint8List> readRecording(String path) async => (await http.get(Uri.parse(path))).bodyBytes;
