import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/session.dart';
import '../../offline/sync_queue.dart';
import '../assistant/assistant.dart';
import '../assistant/mascot.dart';
import '../widgets.dart';

/// Assisted kiosk mode (CSC / SHG operator): switch between artisans, capture on their behalf,
/// exhibition batch capture, print certificate tags, bulk sync, own stats.
class KioskHomeScreen extends StatefulWidget {
  const KioskHomeScreen({super.key});

  @override
  State<KioskHomeScreen> createState() => _KioskHomeScreenState();
}

class _KioskHomeScreenState extends State<KioskHomeScreen> {
  List<Map>? artisans;
  Map<String, dynamic>? stats;
  bool batch = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = context.read<Session>().api;
    final prev = api.actAsArtisanId;
    api.actAsArtisanId = null;
    try {
      final r = await Future.wait([api.get('/operators/artisans'), api.get('/operators/stats')]);
      if (!mounted) return;
      setState(() => (artisans = (r[0] as List).cast<Map>(), stats = Map<String, dynamic>.from(r[1])));
    } catch (e) {
      if (mounted) spokenError(context, e);
    } finally {
      api.actAsArtisanId = prev;
    }
  }

  Future<void> _select(Map a) async {
    await context.read<Session>().selectArtisan(a['id'], a['name']);
    if (!mounted) return;
    context.voice.speak(context.l.captureFor(a['name_native'] ?? a['name']));
    if (batch) context.push('/artisan/capture');
  }

  Future<void> _printTags() async {
    final s = context.read<Session>();
    try {
      final mine = await s.api.get('/products/mine');
      final ids = (mine as List).cast<Map>().where((p) => p['status'] == 'live').map((p) => p['id']).join(',');
      if (ids.isEmpty) return;
      await launchUrl(Uri.parse(s.api.uri('/operators/tags.pdf', {'product_ids': ids, 'size': 'label'}).toString()));
    } catch (e) {
      if (mounted) spokenError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = context.watch<Session>();
    final q = context.watch<SyncQueue>();
    return Scaffold(
      appBar: AppBar(
        title: Text('${l.kioskTitle} · ShilpSetu'),
        actions: [
          IconButton(
            tooltip: l.askShilpi,
            onPressed: () => openAssistant(context),
            icon: const SizedBox(width: 30, height: 30, child: Mascot(size: 30)),
          ),
          const ThemeToggle(),
          IconButton(
            tooltip: l.logout,
            onPressed: () async {
              await s.logout();
              if (context.mounted) context.go('/welcome');
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: SS.marigold,
        foregroundColor: SS.tealDeep,
        onPressed: () async {
          await context.push('/kiosk/onboard');
          _load();
        },
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(l.onboardArtisan),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), children: [
          if (stats != null)
            Row(children: [
              _stat(context, '${stats!['artisans_onboarded']}', l.myArtisans),
              const SizedBox(width: 10),
              _stat(context, '${stats!['products_captured']}', l.tileMyProducts),
              const SizedBox(width: 10),
              _stat(context, '${stats!['by_status']?['live'] ?? 0}', l.statusLive),
            ]),
          const SizedBox(height: 12),
          Row(children: [
            const Expanded(child: SyncBanner()),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: () {
                q.online = true;
                q.run();
              },
              icon: const Icon(Icons.sync_rounded),
              label: Text(l.syncAll),
            ),
          ]),
          SwitchListTile(
            value: batch,
            onChanged: (v) => setState(() => batch = v),
            title: Text(l.batchMode),
            secondary: Icon(Icons.collections_rounded, color: SS.ochre),
          ),
          if (s.activeArtisanId != null)
            Card(
              color: SS.teal,
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                title: Text(l.captureFor(s.activeArtisanName ?? ''), style: const TextStyle(color: SS.cream, fontSize: 18)),
                trailing: const Icon(Icons.add_a_photo_rounded, color: SS.marigold, size: 32),
                onTap: () => context.push('/artisan/capture'),
              ),
            ),
          Row(children: [
            Expanded(child: SectionTitle(l.myArtisans)),
            TextButton.icon(onPressed: s.activeArtisanId == null ? null : _printTags, icon: const Icon(Icons.print_rounded), label: Text(l.printTags)),
          ]),
          if (artisans == null) const Center(child: CircularProgressIndicator()),
          for (final a in artisans ?? const <Map>[])
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SS.radius),
                side: BorderSide(color: s.activeArtisanId == a['id'] ? SS.marigold : Colors.transparent, width: 3),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                leading: CircleAvatar(backgroundColor: SS.sandLight, child: Text((a['name'] as String).substring(0, 1))),
                title: Text('${a['name']}${a['name_native'] != null ? ' · ${a['name_native']}' : ''}'),
                subtitle: Text('${a['craft_type'] ?? ''} · ${a['village'] ?? ''} · ${l.productsCount(a['products'] as int)}'),
                trailing: a['verified'] == true ? Icon(Icons.verified_rounded, color: SS.verifiedGreen) : null,
                onTap: () => _select(a),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _stat(BuildContext context, String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: SS.white, borderRadius: BorderRadius.circular(SS.radiusSmall), boxShadow: SS.cardShadow),
          child: Column(children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ]),
        ),
      );
}
