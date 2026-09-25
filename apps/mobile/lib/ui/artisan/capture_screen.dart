import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/languages.dart';
import '../../core/recorder.dart';
import '../../core/session.dart';
import '../../core/voice.dart';
import '../../offline/sync_queue.dart';
import '../widgets.dart';
import 'camera_screen.dart';
import 'capture_view.dart';
import 'photo_quality.dart';

/// Steps 1 + 2: Speak and Snap, in either order, fully offline. The phone's own speech recogniser writes the
/// transcript live; where the phone has none, the voice is recorded and the server transcribes it.
/// (Android lets only one thing use the microphone, so recognition and recording never run together there.)
class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  late final VoiceRecorder recorder = context.read<VoiceRecorder>();
  final photos = <Uint8List>[];
  (Uint8List, String)? audio;
  String transcript = '';
  String? hint;
  bool listening = false;
  bool live = false; // true while the phone's recogniser (not the recorder) is taking the voice
  final sttLevels = List<double>.filled(28, 0.05, growable: true);
  late final Voice voice = context.read<Voice>();

  @override
  void initState() {
    super.initState();
    recorder.addListener(_tick);
    voice.addListener(_voiceTick);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l = context.l;
      context.voice.speak('${l.addProductTitle}. ${l.speakOwnLanguage}');
    });
  }

  void _tick() => mounted ? setState(() {}) : null;

  /// Waveform from the recogniser's sound level, and stop when it ends on its own (after a pause).
  void _voiceTick() {
    if (!mounted || !live) return;
    sttLevels
      ..removeAt(0)
      ..add(((voice.level + 2) / 12).clamp(0.05, 1.0));
    if (!voice.listening && listening) {
      setState(() {
        listening = false;
        live = false;
        if (voice.partial.length >= transcript.length) transcript = voice.partial;
      });
      if (recorder.recording) _keepRecording();
    } else {
      setState(() {});
    }
  }

  Future<void> _keepRecording() async {
    final rec = await recorder.stop();
    if (rec != null && mounted) setState(() => audio = rec);
  }

  @override
  void dispose() {
    voice.removeListener(_voiceTick);
    if (voice.listening) voice.stopListening();
    recorder.removeListener(_tick);
    if (recorder.recording) recorder.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    if (listening) return;
    await voice.stopSpeaking();
    // 1) The phone's recogniser: the words appear as they are spoken.
    final ok = await voice.listen(
      quiet: true,
      onFinal: (t) {
        if (mounted && t.trim().isNotEmpty) setState(() => transcript = t);
      },
    );
    if (ok) {
      setState(() => (listening = true, live = true));
      if (Voice.canRecordWhileListening) recorder.start(); // browsers can also keep the voice itself
      return;
    }
    // 2) No recogniser on this phone: record the voice; the server transcribes it after upload.
    if (!await recorder.start(onLimit: _stop)) {
      if (mounted) voice.onProblem?.call(Voice.insecureWeb ? VoiceProblem.insecure : VoiceProblem.permission);
      return;
    }
    setState(() => listening = true);
  }

  Future<void> _stop() async {
    if (!listening) return;
    if (live) {
      await voice.stopListening(); // hands over the last words via onFinal
      final heard = voice.partial;
      setState(() {
        live = false;
        if (heard.length >= transcript.length) transcript = heard;
      });
    }
    final rec = await recorder.stop();
    setState(() {
      listening = false;
      if (rec != null) audio = rec;
    });
  }

  Future<void> _photo() async {
    if (listening) await _stop();
    if (!mounted) return;
    final bytes = await CameraScreen.capture(context);
    if (bytes == null || !mounted) return;
    final l = context.l;
    final h = await photoHint(bytes);
    setState(() {
      if (photos.length < 5) photos.add(bytes);
      hint = switch (h) { 'too_dark' => l.hintTooDark, 'too_bright' => l.hintTooBright, _ => null };
    });
    if (!mounted) return;
    context.voice.speak([l.photoCaptured, ?hint].join('. '));
  }

  Future<void> _submit() async {
    final s = context.read<Session>();
    final q = context.read<SyncQueue>();
    final id = await q.enqueue(
      language: s.language,
      audio: audio?.$1,
      audioExt: audio?.$2 ?? 'wav',
      photos: photos,
      deviceTranscript: transcript.isEmpty ? null : transcript,
      actAsArtisanId: s.role == 'operator' ? s.activeArtisanId : null,
    );
    if (!mounted) return;
    if (!q.online) spokenMessage(context, context.l.savedOnPhone);
    context.pushReplacement('/artisan/build/$id');
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<Session>();
    final v = context.watch<Voice>();
    final shown = listening && live && v.partial.isNotEmpty ? v.partial : transcript;
    return CaptureView(
      listening: listening,
      languageName: context.l.localeName == 'en' ? languageFor(s.language).english : languageFor(s.language).native,
      transcript: shown,
      levels: live ? sttLevels : recorder.levels,
      photos: photos,
      hint: hint,
      subtitleOverride: s.role == 'operator' && s.activeArtisanName != null ? context.l.captureFor(s.activeArtisanName!) : null,
      onMicTap: listening ? _stop : _start,
      onHoldStart: _start,
      onHoldEnd: _stop,
      onTakePhoto: _photo,
      onSubmit: _submit,
      syncBanner: const SyncBanner(dark: true),
    );
  }
}
