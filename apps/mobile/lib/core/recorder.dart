import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

import 'recorder_io.dart' if (dart.library.js_interop) 'recorder_web.dart' as platform;

/// Records the artisan's voice as-is (kept and uploaded even when on-device ASR is unavailable).
class VoiceRecorder extends ChangeNotifier {
  VoiceRecorder();

  final _rec = AudioRecorder();
  StreamSubscription<Amplitude>? _ampSub;
  final List<double> levels = List.filled(28, 0.05, growable: true);
  bool recording = false;
  DateTime? _startedAt;
  Timer? _limit;
  static const maxDuration = Duration(seconds: 60);

  Duration get elapsed => _startedAt == null ? Duration.zero : DateTime.now().difference(_startedAt!);

  Future<bool> start({VoidCallback? onLimit}) async {
    if (recording) return true;
    try {
      if (!await _rec.hasPermission()) return false;
      final encoder = kIsWeb ? AudioEncoder.opus : AudioEncoder.wav;
      await _rec.start(RecordConfig(encoder: encoder, sampleRate: 16000, numChannels: 1), path: await platform.tempPath());
      recording = true;
      _startedAt = DateTime.now();
      _ampSub = _rec.onAmplitudeChanged(const Duration(milliseconds: 90)).listen((a) {
        // dBFS (-60..0) -> 0..1
        final v = ((a.current + 60) / 60).clamp(0.04, 1.0);
        levels
          ..removeAt(0)
          ..add(v);
        notifyListeners();
      });
      _limit = Timer(maxDuration, () => onLimit?.call());
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Returns (bytes, file extension) of the recording.
  Future<(Uint8List, String)?> stop() async {
    if (!recording) return null;
    _limit?.cancel();
    await _ampSub?.cancel();
    recording = false;
    notifyListeners();
    final path = await _rec.stop();
    if (path == null) return null;
    final bytes = await platform.readRecording(path);
    return (bytes, kIsWeb ? 'webm' : 'wav');
  }

  Future<void> cancel() async {
    _limit?.cancel();
    await _ampSub?.cancel();
    recording = false;
    try {
      await _rec.cancel();
    } catch (_) {}
    notifyListeners();
  }

  @override
  void dispose() {
    _limit?.cancel();
    _ampSub?.cancel();
    _rec.dispose();
    super.dispose();
  }
}
