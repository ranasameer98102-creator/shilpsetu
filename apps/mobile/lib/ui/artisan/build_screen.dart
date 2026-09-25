import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../../core/recorder.dart';
import '../../core/session.dart';
import '../../core/voice.dart';
import '../../l10n/app_localizations.dart';
import '../../offline/sync_queue.dart';
import '../widgets.dart';

/// Step 3 "AI Builds It": visible + spoken progress. While offline the capture waits on the phone.
/// If information is missing the AI asks follow-up questions, answered by voice.
class BuildScreen extends StatefulWidget {
  const BuildScreen({super.key, required this.captureId});
  final String captureId;

  @override
  State<BuildScreen> createState() => _BuildScreenState();
}

class _BuildScreenState extends State<BuildScreen> {
  Map<String, dynamic>? info;
  Timer? _poll;
  final _spoken = <String>{};
  final _typed = <String, TextEditingController>{};
  bool answering = false;
  String? recordingField; // set while recording an answer on phones without speech recognition

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(milliseconds: 1500), (_) => _refresh());
    _refresh();
  }

  @override
  void dispose() {
    _poll?.cancel();
    for (final c in _typed.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? get productId {
    final q = context.read<SyncQueue>();
    return q.items.where((c) => c.id == widget.captureId).firstOrNull?.productId;
  }

  static String stepLabel(L10n l, String key) => switch (key) {
        'asr' => l.stepAsr,
        'nlu' => l.stepNlu,
        'listing' => l.stepListing,
        'translation' => l.stepTranslation,
        'image' => l.stepImage,
        'price' => l.stepPrice,
        'certificate' => l.stepCertificate,
        _ => key,
      };

  Future<void> _refresh() async {
    final q = context.read<SyncQueue>();
    if (productId == null) {
      if (q.online) await q.run();
      return;
    }
    try {
      final r = Map<String, dynamic>.from(await context.read<Session>().api.get('/products/$productId/build'));
      if (!mounted) return;
      setState(() => info = r);
      final l = context.l;
      for (final s in (r['pipeline']?['steps'] as List? ?? []).cast<Map>()) {
        if (s['status'] == 'running' && _spoken.add(s['key'])) context.read<Voice>().speak(stepLabel(l, s['key']));
      }
      final done = r['pipeline']?['done'] == true && !{'queued', 'processing'}.contains(r['status']);
      final questions = (r['pipeline']?['questions'] as List? ?? []);
      if (done && questions.isNotEmpty && _spoken.add('q-${questions.first['field']}')) {
        context.read<Voice>().speak('${l.quickQuestions}. ${questions.first['text']}');
      }
      if (done) _poll?.cancel();
    } catch (_) {}
  }

  Future<void> _answer(Map q) async {
    final field = q['field'] as String;
    final rec = context.read<VoiceRecorder>();
    // Second tap while recording (no-recogniser path): stop and send the audio for server-side ASR.
    if (recordingField == field) {
      final audio = await rec.stop();
      setState(() => recordingField = null);
      if (audio != null) await _sendAudio(field, audio.$1, audio.$2);
      return;
    }
    final v = context.read<Voice>();
    setState(() => answering = true);
    var sent = false;
    final ok = await v.listen(quiet: true, onFinal: (t) async {
      if (t.trim().isEmpty) return;
      sent = true;
      await _send(field, t);
    });
    if (ok) {
      // If the recogniser stops without hearing an answer, let the artisan tap the mic again.
      void ended() {
        if (v.listening) return;
        v.removeListener(ended);
        if (!sent && mounted) setState(() => answering = false);
      }
      v.addListener(ended);
    }
    if (!ok && mounted) {
      // No on-device recogniser: record the spoken answer; the server transcribes it.
      setState(() => answering = false);
      if (await rec.start()) setState(() => recordingField = field);
    }
  }

  Future<void> _sendAudio(String field, Uint8List bytes, String ext) async {
    final api = context.read<Session>().api;
    try {
      final up = await api.post('/capture/uploads', {
        'idempotency_key': 'ans-$productId-$field-${DateTime.now().millisecondsSinceEpoch}', 'kind': 'audio',
        'content_type': ext == 'wav' ? 'audio/wav' : 'audio/webm', 'total_size': bytes.length,
      });
      await api.putBytes('/capture/uploads/${up['upload_id']}', bytes, {'offset': 0});
      await api.post('/capture/uploads/${up['upload_id']}/complete');
      await _send(field, null, uploadId: up['upload_id'] as String);
    } catch (e) {
      if (mounted) spokenError(context, e);
    }
  }

  Future<void> _send(String field, String? text, {String? uploadId}) async {
    try {
      await context.read<Session>().api.post('/products/$productId/answers', [
        {'field': field, 'text': text, 'upload_id': uploadId}
      ]);
      _spoken.removeWhere((k) => k.startsWith('q-'));
      setState(() => (answering = false, info = null));
      _poll?.cancel();
      _poll = Timer.periodic(const Duration(milliseconds: 1500), (_) => _refresh());
    } catch (e) {
      if (mounted) spokenError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final q = context.watch<SyncQueue>();
    final cap = q.items.where((c) => c.id == widget.captureId).firstOrNull;
    final steps = (info?['pipeline']?['steps'] as List? ?? []).cast<Map>();
    final done = info?['pipeline']?['done'] == true && !{'queued', 'processing'}.contains(info?['status']);
    final questions = (info?['pipeline']?['questions'] as List? ?? []).cast<Map>();
    return Scaffold(
      backgroundColor: SS.tealDeep,
      appBar: AppBar(backgroundColor: SS.tealDeep, title: Text(l.aiBuilding)),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const SyncBanner(dark: true),
        const SizedBox(height: 20),
        if (cap?.productId == null)
          _LocalStatus(status: cap?.status ?? 'queued', error: cap?.lastError, onRetry: () => q.retryNow(widget.captureId))
        else
          for (final s in steps) _StepRow(label: stepLabel(l, s['key']), status: s['status']),
        if (done && questions.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(l.quickQuestions, style: const TextStyle(color: SS.marigold, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          for (final question in questions)
            Card(
              color: SS.teal,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
                child: Column(children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    title: Text(question['text'], style: const TextStyle(color: SS.cream, fontSize: 18)),
                    subtitle: Text(recordingField == question['field'] ? l.stopRecording : l.answerBySpeaking,
                        style: TextStyle(color: SS.sand)),
                    trailing: IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: SS.maroon, minimumSize: const Size(56, 56)),
                      onPressed: answering && recordingField == null ? null : () => _answer(question),
                      icon: Icon(recordingField == question['field'] ? Icons.stop_rounded : Icons.mic_rounded,
                          color: SS.cream),
                    ),
                    onTap: () => context.read<Voice>().speak(question['text']),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      controller: _typed.putIfAbsent(question['field'] as String, TextEditingController.new),
                      style: TextStyle(color: SS.ink),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (t) => t.trim().isEmpty ? null : _send(question['field'], t.trim()),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: l.typeInstead,
                        suffixIcon: IconButton(
                          tooltip: l.send,
                          icon: Icon(Icons.send_rounded, color: SS.maroon),
                          onPressed: () {
                            final t = _typed[question['field']]!.text.trim();
                            if (t.isNotEmpty) _send(question['field'], t);
                          },
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          if (answering) Text(context.watch<Voice>().partial, style: const TextStyle(color: SS.cream, fontSize: 18)),
        ],
        const SizedBox(height: 28),
        if (done)
          SizedBox(
            height: 64,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: SS.marigold, foregroundColor: SS.tealDeep, shape: const StadiumBorder()),
              onPressed: () => context.pushReplacement('/artisan/review/$productId'),
              icon: const Icon(Icons.fact_check_rounded),
              label: Text(l.reviewTitle),
            ),
          ),
      ]),
    );
  }
}

class _LocalStatus extends StatelessWidget {
  const _LocalStatus({required this.status, this.error, this.onRetry});
  final String status;
  final String? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Column(children: [
      StatusChip(status: status, label: statusLabel(l, status)),
      const SizedBox(height: 16),
      Text(l.savedOnPhone, textAlign: TextAlign.center, style: const TextStyle(color: SS.cream, fontSize: 18)),
      if (status == 'failed' || error != null) ...[
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(foregroundColor: SS.cream),
          onPressed: onRetry,
          child: Text(l.retry),
        ),
      ],
    ]);
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.label, required this.status});
  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      'done' => (Icons.check_circle_rounded, SS.verifiedGreen),
      'running' => (Icons.autorenew_rounded, SS.marigold),
      'failed' => (Icons.error_rounded, SS.ochre),
      'skipped' => (Icons.remove_circle_outline_rounded, SS.slate),
      _ => (Icons.radio_button_unchecked_rounded, SS.slate),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        status == 'running'
            ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3))
            : Icon(icon, color: color, size: 28),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: TextStyle(color: status == 'pending' ? SS.sand : SS.cream, fontSize: 18))),
      ]),
    );
  }
}
