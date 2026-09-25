import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/session.dart';
import '../widgets.dart';

/// In-app provenance certificate: verifies the Ed25519 signature server-side and shows who made the item.
class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key, required this.certId, this.sig});
  final String certId;
  final String? sig;

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  Map<String, dynamic>? v;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = context.read<Session>();
    try {
      final r = await s.api.get('/certificates/${widget.certId}/verify', {'s': widget.sig});
      if (!mounted) return;
      setState(() => v = Map<String, dynamic>.from(r));
      final l = context.l;
      context.voice.speak(v!['valid'] == true ? l.certValid : l.certInvalid);
    } catch (e) {
      if (mounted) spokenError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final api = context.read<Session>().api;
    if (v == null) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    final ok = v!['valid'] == true;
    final c = v!['certificate'] as Map?;
    final p = c?['payload'] as Map?;
    final a = p?['artisan'] as Map?;
    final fp = p?['fair_price'] as Map?;
    return Scaffold(
      appBar: AppBar(title: Text(l.scanCertificate, style: const TextStyle(fontSize: 17))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: ok ? const Color(0xFFE3F0E8) : const Color(0xFFF6E1DF), borderRadius: BorderRadius.circular(SS.radius)),
          child: Row(children: [
            Icon(ok ? Icons.verified_rounded : Icons.gpp_bad_rounded, color: ok ? SS.verifiedGreen : SS.danger, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Text(ok ? l.certValid : '${l.certInvalid}: ${(v!['reasons'] as List).join(', ')}',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: ok ? SS.verifiedGreen : SS.danger)),
            ),
          ]),
        ),
        if (p != null) ...[
          const SizedBox(height: 16),
          Text(p['product']['title'], style: Theme.of(context).textTheme.headlineSmall),
          Text(p['location'] ?? '', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          _card(context, l.meetArtisan, [
            Text('${a!['name']}${a['name_native'] != null && a['name_native'] != a['name'] ? '  ·  ${a['name_native']}' : ''}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Wrap(spacing: 8, children: [
              if (a['verified'] == true) VerifiedBadge(label: l.verifiedArtisan, compact: true),
              if (a['pehchan_verified'] == true)
                const Chip(label: Text('Pehchan ID ✓'), visualDensity: VisualDensity.compact),
            ]),
            if ((p['story'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('“${p['story']}”', style: SS.story(16)),
            ],
          ]),
          _card(context, l.certificateSub, [
            Text('${p['craft'] ?? ''}${p['gi'] != null ? ' · GI: ${p['gi']}' : ''}'),
            Text((p['materials'] as List).join(', ')),
            const SizedBox(height: 10),
            FairPriceRow(price: fp!['price'], size: 26),
            Text(l.goesToArtisan(rupees(fp['artisan_share_amount']), '${(fp['artisan_share_pct'] as num?)?.round() ?? ''}'),
                style: TextStyle(color: SS.verifiedGreen, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            for (final b in (fp['basis'] as List).cast<Map>())
              Row(children: [Expanded(child: Text('${b['label']}')), Text(rupees(b['amount']))]),
          ]),
          _card(context, 'Ed25519 · SHA-256', [
            Center(child: QrImageView(data: c!['signature'] == null ? '' : '${api.baseUrl}/v/${widget.certId}?s=${c['signature']}', size: 160)),
            SelectableText('SHA-256 ${c['sha256']}', style: const TextStyle(fontSize: 11)),
            Text('Key ${c['key_id']} · ${p['issued_at'].toString().substring(0, 10)}', style: const TextStyle(fontSize: 11)),
            TextButton.icon(
              onPressed: () => launchUrl(Uri.parse(api.absolute('/api/v1/certificates/${widget.certId}/pdf'))),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('PDF'),
            ),
          ]),
        ],
      ]),
    );
  }

  Widget _card(BuildContext context, String title, List<Widget> children) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: SS.white, borderRadius: BorderRadius.circular(SS.radius), boxShadow: SS.cardShadow),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          ...children,
        ]),
      );
}
