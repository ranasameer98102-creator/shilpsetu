import 'dart:typed_data';
import 'dart:ui' as ui;

/// Quick on-device quality check (works offline): brightness from a 64px thumbnail.
/// Returns a hint key — 'too_dark' / 'too_bright' — or null. Advisory only, never blocks capture.
Future<String?> photoHint(Uint8List bytes) async {
  try {
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 64);
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (data == null) return null;
    var sum = 0.0;
    final n = data.lengthInBytes ~/ 4;
    for (var i = 0; i < n; i++) {
      final r = data.getUint8(i * 4), g = data.getUint8(i * 4 + 1), b = data.getUint8(i * 4 + 2);
      sum += 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }
    final mean = sum / n / 255;
    if (mean < 0.28) return 'too_dark';
    if (mean > 0.86) return 'too_bright';
    return null;
  } catch (_) {
    return null;
  }
}
