import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../../core/recorder.dart';
import '../../core/session.dart';
import '../../core/voice.dart';
import '../assistant/greeting_card.dart';
import '../widgets.dart';
import 'camera_screen.dart';

/// Step 4 "You Approve": a single review card read aloud, one big Approve button.
/// Secondary: change price by voice, retake photo, re-record.
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, required this.productId});
  final String productId;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  Map<String, dynamic>? p;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    _load(speak: true);
  }

  Future<void> _load({bool speak = false}) async {
    try {
      final s = context.read<Session>();
      final r = Map<String, dynamic>.from(await s.api.get('/products/${widget.productId}', {'lang': s.language}));
      if (!mounted) return;
      setState(() => p = r);
      if (speak) _readAloud();
    } catch (e) {
      if (mounted) spokenError(context, e);
    }
  }

  String _title() {
    final lang = context.read<Session>().language;
    return (p!['translations']?[lang]?['title'] as String?) ?? p!['title'] ?? '';
  }

  void _readAloud() {
    final l = context.l;
    final q = p!['price_quote'];
    context.read<Voice>().speak([
      _title(),
      if (q != null) l.priceSpoken(rupees(q['final_price']), rupees(q['artisan_share_amount'])),
    ].join('. '));
  }

  Future<T?> _run<T>(Future<T> Function() fn) async {
    setState(() => busy = true);
    try {
      return await fn();
    } catch (e) {
      if (mounted) spokenError(context, e);
      return null;
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _approve() async {
    final api = context.read<Session>().api;
    final r = await _run(() => api.post('/products/${widget.productId}/approve'));
    if (r == null || !mounted) return;
    setState(() => p = Map<String, dynamic>.from(r));
    final l = context.l;
    celebrate(context, l.celebrateLive); // Shilpi cheers
    await Future.delayed(const Duration(milliseconds: 3300));
    if (mounted) context.read<Voice>().speak('${l.isLive} ${l.onOndc}. ${l.certificateReady}');
  }

  Future<void> _changePrice() async {
    final v = context.read<Voice>();
    final api = context.read<Session>().api;
    final l = context.l;
    await v.speak(l.sayNewPrice);
    final ok = await v.listen(onFinal: (t) async {
      await v.stopListening();
      final q = await _run(() => api.post('/products/${widget.productId}/price', {'spoken': t}));
      if (q != null) await _load(speak: true);
    });
    if (!ok && mounted) {
      // No recogniser: nudge buttons instead of typing.
      final cur = (p!['price'] as num).toDouble();
      final picked = await showModalBottomSheet<double>(
        context: context,
        builder: (_) => SafeArea(
          child: Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 12, children: [
            for (final d in [-200, -100, -50, 50, 100, 200, 500])
              ActionChip(label: Text('${d > 0 ? '+' : ''}${rupees(d)}'), onPressed: () => Navigator.pop(context, cur + d)),
          ]),
        ),
      );
      if (picked != null) {
        await _run(() => api.post('/products/${widget.productId}/price', {'price': picked}));
        await _load(speak: true);
      }
    }
  }

  Future<String?> _upload(Uint8List bytes, String kind, String ct) async {
    final api = context.read<Session>().api;
    final r = await api.post('/capture/uploads', {
      'idempotency_key': 'rv-${DateTime.now().microsecondsSinceEpoch}', 'kind': kind, 'content_type': ct, 'total_size': bytes.length,
    });
    final id = r['upload_id'] as String;
    await api.putBytes('/capture/uploads/$id', bytes, {'offset': 0});
    await api.post('/capture/uploads/$id/complete');
    return id;
  }

  Future<void> _retake() async {
    final bytes = await CameraScreen.capture(context);
    if (bytes == null || !mounted) return;
    final api = context.read<Session>().api;
    await _run(() async {
      final id = await _upload(bytes, 'photo', 'image/jpeg');
      await api.post('/products/${widget.productId}/retake', [id]);
    });
    if (mounted) context.pushReplacement('/artisan/products');
  }

  Future<void> _rerecord() async {
    final rec = context.read<VoiceRecorder>();
    final v = context.read<Voice>();
    await rec.start();
    await v.listen();
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SS.tealDeep,
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          MicButton(active: true, onTap: () => Navigator.pop(ctx), size: 96),
          ListenableBuilder(listenable: v, builder: (_, _) => Text(v.partial, style: const TextStyle(color: SS.cream))),
        ]),
      ),
    );
    final transcript = v.partial;
    await v.stopListening();
    final audio = await rec.stop();
    if (!mounted) return;
    final api = context.read<Session>().api;
    await _run(() async {
      final id = audio == null ? null : await _upload(audio.$1, 'audio', audio.$2 == 'wav' ? 'audio/wav' : 'audio/webm');
      await api.post('/products/${widget.productId}/rerecord', null, {
        'audio_upload_id': id,
        'device_transcript': transcript.isEmpty ? null : transcript,
      });
    });
    if (mounted) context.pushReplacement('/artisan/products');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    if (p == null) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    final q = p!['price_quote'] == null ? null : Map<String, dynamic>.from(p!['price_quote']);
    final media = (p!['media'] as List).cast<Map>();
    final img = media.where((m) => m['kind'] == 'enhanced').firstOrNull?['url'] ??
        media.where((m) => m['kind'] == 'original').firstOrNull?['url'];
    final live = p!['status'] == 'live';
    final warnings = (q?['warnings'] as List? ?? []);
    return Scaffold(
      appBar: AppBar(title: Text(live ? l.isLive : l.reviewTitle), actions: [SpeakButton(_title(), color: SS.cream)]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (live) _LiveBanner(product: p!),
        AspectRatio(aspectRatio: 1, child: CraftImage(img, radius: SS.radius)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Text(_title(), style: Theme.of(context).textTheme.headlineSmall)),
          IconButton(onPressed: _readAloud, icon: Icon(Icons.volume_up_rounded, color: SS.heading, size: 30)),
        ]),
        Text('${l.category}: ${p!['category_label'] ?? p!['category'] ?? '-'}', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 12),
        if (q != null) ...[
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(child: FairPriceRow(price: q['final_price'], compareAt: p!['compare_at_price'])),
          ]),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFE3F0E8), borderRadius: BorderRadius.circular(SS.radiusSmall)),
            child: Row(children: [
              Icon(Icons.account_balance_wallet_rounded, color: SS.verifiedGreen, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l.youGet(rupees(q['artisan_share_amount']), (q['artisan_share_pct'] as num).toStringAsFixed(0)),
                    style: TextStyle(color: SS.verifiedGreen, fontSize: 19, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
          const SizedBox(height: 6),
          Text(l.marketRate(rupees(q['market_low']), rupees(q['market_high'])), style: Theme.of(context).textTheme.bodySmall),
          if (warnings.contains('below_fair_wage'))
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(l.belowFairWage, style: TextStyle(color: SS.danger, fontWeight: FontWeight.w600)),
            ),
          const SizedBox(height: 12),
          PriceBreakdown(
            quote: q,
            title: l.howPriceBuilt,
            languageCode: context.read<Session>().language,
            shareLine: (a, pct) => l.goesToArtisan(a, pct),
          ),
        ],
        const SizedBox(height: 20),
        if (!live) ...[
          SizedBox(
            height: 76,
            child: FilledButton.icon(
              onPressed: busy ? null : _approve,
              style: FilledButton.styleFrom(backgroundColor: SS.verifiedGreen, shape: const StadiumBorder(),
                  textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              icon: const Icon(Icons.check_rounded, size: 40),
              label: Text(l.approve),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: [
            OutlinedButton.icon(onPressed: busy ? null : _changePrice, icon: const Icon(Icons.currency_rupee_rounded), label: Text(l.changePrice)),
            OutlinedButton.icon(onPressed: busy ? null : _retake, icon: const Icon(Icons.photo_camera_rounded), label: Text(l.retakePhoto)),
            OutlinedButton.icon(onPressed: busy ? null : _rerecord, icon: const Icon(Icons.mic_rounded), label: Text(l.reRecord)),
          ]),
        ] else
          FilledButton(onPressed: () => context.go('/artisan'), child: Text(l.done)),
      ]),
    );
  }
}

class _LiveBanner extends StatelessWidget {
  const _LiveBanner({required this.product});
  final Map<String, dynamic> product;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final cert = product['certificate'];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: SS.teal, borderRadius: BorderRadius.circular(SS.radius)),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('✓ ${l.isLive}', style: const TextStyle(color: SS.marigold, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(l.onOndc, style: const TextStyle(color: SS.cream)),
            Text(l.certificateReady, style: const TextStyle(color: SS.cream)),
          ]),
        ),
        if (cert != null)
          Container(
            color: SS.white,
            padding: const EdgeInsets.all(4),
            child: QrImageView(data: cert['qr_url'], size: 84, padding: EdgeInsets.zero),
          ),
      ]),
    );
  }
}
