import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../core/config.dart';
import '../core/session.dart';
import 'widgets.dart';

/// About / Credits (§1): identity, problem, promise, and "ShilpSetu · SIH 2026 · PS ID SIH26090 · Team HACKER LOBBY".
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context).textTheme;
    Widget fact(IconData i, String title, String body) => Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: Icon(i, color: SS.ochre, size: 32),
            title: Text(title, style: t.titleSmall),
            subtitle: Text(body),
          ),
        );
    return Scaffold(
      appBar: AppBar(title: Text(l.about)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Wordmark(size: 34),
        Text(l.tagline, style: t.titleMedium),
        const SizedBox(height: 10),
        Text(l.heroLine, style: SS.story(19)),
        const SizedBox(height: 10),
        Text(l.promise, style: t.bodyLarge),
        const SizedBox(height: 18),
        Text('Why', style: t.titleLarge),
        const SizedBox(height: 8),
        fact(Icons.event_busy_rounded, 'Market access only a few days a year',
            'Government exhibitions remain the main sales channel. Between fairs there is almost no way to reach buyers.'),
        const SizedBox(height: 8),
        fact(Icons.money_off_rounded, 'Middlemen absorb most of the margin',
            '66% of handloom weavers earn under ₹5,000 a month (All-India Handloom Census 2019-20). Pricing is opaque.'),
        const SizedBox(height: 8),
        fact(Icons.phonelink_off_rounded, 'Mainstream e-commerce stays out of reach',
            'Low digital literacy and language barriers keep artisans off the platforms that already sell everything else.'),
        const SizedBox(height: 18),
        Text(l.howToUse, style: t.titleLarge),
        const SizedBox(height: 6),
        Text(l.fiveSteps, style: t.bodyLarge),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: SS.teal, borderRadius: BorderRadius.circular(SS.radius)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Smart India Hackathon 2026', style: TextStyle(color: SS.marigold, fontWeight: FontWeight.w700, fontSize: 17)),
            SizedBox(height: 6),
            Text('Problem Statement SIH26090 · Ministry of Social Justice & Empowerment (MoSJE)\nTheme: Heritage & Culture · Category: Software',
                style: TextStyle(color: SS.cream)),
          ]),
        ),
        const SizedBox(height: 18),
        const _PhotoCredits(),
        const SizedBox(height: 12),
        const _ServerAddress(),
        const SizedBox(height: 18),
        const Credits(teamId: AppConfig.teamId),
      ]),
    );
  }
}

/// Lets a helper point the installed app at a new server address (e.g. when the laptop's Wi-Fi IP changes).
class _ServerAddress extends StatefulWidget {
  const _ServerAddress();

  @override
  State<_ServerAddress> createState() => _ServerAddressState();
}

class _ServerAddressState extends State<_ServerAddress> {
  late final _c = TextEditingController(text: context.read<Session>().api.baseUrl);

  Future<void> _save() async {
    final url = _c.text.trim();
    if (!RegExp(r'^https?://').hasMatch(url)) return;
    await context.read<Session>().setApiBase(url);
    if (mounted) spokenMessage(context, context.l.saved);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.serverAddress, style: Theme.of(context).textTheme.titleSmall),
          Text(l.serverAddressHint, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: _c, keyboardType: TextInputType.url, decoration: const InputDecoration(isDense: true))),
            const SizedBox(width: 8),
            FilledButton(onPressed: _save, child: Text(l.save)),
          ]),
        ]),
      ),
    );
  }
}

/// Wikimedia Commons photographers credited as their licences require.
class _PhotoCredits extends StatefulWidget {
  const _PhotoCredits();

  @override
  State<_PhotoCredits> createState() => _PhotoCreditsState();
}

class _PhotoCreditsState extends State<_PhotoCredits> {
  List<Map>? credits;

  Future<void> _load() async {
    if (credits != null) return;
    try {
      final r = await context.read<Session>().api.get('/photo-credits');
      if (mounted) setState(() => credits = (r as List).cast<Map>());
    } catch (_) {
      if (mounted) setState(() => credits = const []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Card(
      child: ExpansionTile(
        leading: Icon(Icons.photo_library_outlined, color: SS.ochre),
        title: Text(l.photoCredits),
        subtitle: Text(l.photoCreditsSub, style: Theme.of(context).textTheme.bodySmall),
        onExpansionChanged: (open) => open ? _load() : null,
        children: [
          if (credits == null) const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
          for (final c in credits ?? const <Map>[])
            ListTile(
              dense: true,
              title: Text('${c['title']}', maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text('${c['author']} · ${c['license']}'),
              trailing: const Icon(Icons.open_in_new_rounded, size: 18),
              onTap: () => launchUrl(Uri.parse('${c['source']}'), mode: LaunchMode.externalApplication),
            ),
        ],
      ),
    );
  }
}
