import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../../core/recorder.dart';
import '../../core/session.dart';
import '../../core/voice.dart';
import '../widgets.dart';

/// Zero-typing profile: the app asks each question aloud, the artisan answers by voice.
/// The story is also kept as the artisan's own voice recording (played to buyers if consented).
class VoiceProfileScreen extends StatefulWidget {
  const VoiceProfileScreen({super.key, required this.consent});
  final Map<String, bool> consent;

  @override
  State<VoiceProfileScreen> createState() => _VoiceProfileScreenState();
}

class _VoiceProfileScreenState extends State<VoiceProfileScreen> {
  int step = 0;
  final answers = <String, String>{};
  final recorder = VoiceRecorder();
  bool recording = false, saving = false;
  String? storyUploadId;

  List<(String, String Function())> get questions {
    final l = context.l;
    return [
      ('name', () => l.askName),
      ('village', () => l.askVillage),
      ('state', () => l.askState),
      ('craft_type', () => l.askCraft),
      ('years_practice', () => l.askYears),
      ('story', () => l.askStory),
      ('pehchan_id', () => l.askPehchan),
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ask());
  }

  @override
  void dispose() {
    recorder.dispose();
    super.dispose();
  }

  void _ask() => context.voice.speak(questions[step].$2());

  Future<void> _toggle() async {
    final v = context.voice;
    final field = questions[step].$1;
    if (!recording) {
      setState(() => recording = true);
      // Recognition first. The story's own audio is also kept where the platform allows both at once (web);
      // on phones the microphone serves one of them, and recording is the fallback when there is no recogniser.
      if (field == 'story' && Voice.canRecordWhileListening) await recorder.start();
      final ok = await v.listen(quiet: true, onFinal: (t) {
        if (mounted && t.trim().isNotEmpty) setState(() => answers[field] = t);
      });
      if (!ok && !recorder.recording && !await recorder.start() && mounted) {
        v.onProblem?.call(Voice.insecureWeb ? VoiceProblem.insecure : VoiceProblem.permission);
        setState(() => recording = false);
      }
      return;
    }
    await v.stopListening();
    final rec = await recorder.stop();
    setState(() => recording = false);
    if (rec != null) {
      final id = await _upload(rec.$1, rec.$2);
      if (field == 'story') {
        storyUploadId = id;
      } else if (!answers.containsKey(field) && id != null) {
        answers[field] = id; // an upload id: the server runs ASR on it
      }
    }
    if (v.partial.isNotEmpty && (answers[field] == null || answers[field]!.length < 40)) {
      answers[field] = v.partial;
    }
    setState(() {});
  }

  Future<String?> _upload(List<int> bytes, String ext) async {
    final api = context.read<Session>().api;
    try {
      final key = sha256.convert(bytes).toString().substring(0, 40);
      final r = await api.post('/capture/uploads', {
        'idempotency_key': 'profile-$key', 'kind': 'audio', 'content_type': ext == 'wav' ? 'audio/wav' : 'audio/webm',
        'total_size': bytes.length,
      });
      final id = r['upload_id'] as String;
      await api.putBytes('/capture/uploads/$id', Uint8List.fromList(bytes), {'offset': r['received']});
      await api.post('/capture/uploads/$id/complete');
      return id;
    } catch (_) {
      return null;
    }
  }

  Future<void> _next({bool skip = false}) async {
    if (step < questions.length - 1) {
      setState(() => step++);
      _ask();
      return;
    }
    setState(() => saving = true);
    final s = context.read<Session>();
    try {
      final r = await s.api.post('/artisans/me/voice-profile', {
        'language': s.language,
        'answers': {...answers, if (storyUploadId != null && !answers.containsKey('story')) 'story': storyUploadId},
        'consent': widget.consent,
      });
      if (storyUploadId != null && widget.consent['voice'] == true) {
        await s.api.put('/artisans/me', {'name': r['name'], 'story_audio_key': storyUploadId, 'consent': widget.consent});
      }
      await s.markProfileDone(Map<String, dynamic>.from(r));
      if (!mounted) return;
      spokenMessage(context, context.l.profileSaved);
      context.go('/artisan');
    } catch (e) {
      if (mounted) spokenError(context, e);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final (field, question) = questions[step];
    final heard = answers[field];
    final isUploadId = heard != null && RegExp(r'^[0-9a-f]{32}$').hasMatch(heard);
    return Scaffold(
      backgroundColor: SS.tealDeep,
      appBar: AppBar(backgroundColor: SS.tealDeep, title: Text(l.profileTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            LinearProgressIndicator(value: (step + 1) / questions.length, backgroundColor: SS.teal),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: Text(question(),
                    style: const TextStyle(color: SS.cream, fontSize: 24, fontWeight: FontWeight.w700, height: 1.3)),
              ),
              IconButton(onPressed: _ask, icon: const Icon(Icons.volume_up_rounded, color: SS.marigold, size: 32)),
            ]),
            const Spacer(),
            MicButton(active: recording, onTap: _toggle, label: l.tapMicToAnswer),
            Text(recording ? l.stopRecording : l.tapMicToAnswer, style: TextStyle(color: SS.sand)),
            const SizedBox(height: 16),
            if (recording && context.watch<Voice>().partial.isNotEmpty)
              Text(context.watch<Voice>().partial, style: const TextStyle(color: SS.cream, fontSize: 18)),
            if (heard != null && !recording)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(SS.radius)),
                child: Text(isUploadId ? '🎙 ✓' : '${l.weHeard} “$heard”', style: const TextStyle(color: SS.cream, fontSize: 18)),
              ),
            const Spacer(),
            Row(children: [
              if (field == 'pehchan_id' || field == 'story')
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: SS.cream),
                    onPressed: saving ? null : () => _next(skip: true),
                    child: Text(l.skip),
                  ),
                ),
              if (field == 'pehchan_id' || field == 'story') const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 60,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      disabledBackgroundColor: Colors.white.withValues(alpha: 0.12),
                      disabledForegroundColor: SS.cream.withValues(alpha: 0.5),
                    ),
                    onPressed: saving || recording || (heard == null && field == 'name') ? null : _next,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(step == questions.length - 1 ? l.done : l.next),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
