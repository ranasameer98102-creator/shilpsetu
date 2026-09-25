import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../../core/session.dart';
import '../../offline/sync_queue.dart';
import '../assistant/assistant.dart';
import '../assistant/greeting_card.dart';
import '../widgets.dart';

/// Artisan home (audio-first): big tiles that speak their label, sync status, spoken earnings summary.
class ArtisanHomeScreen extends StatefulWidget {
  const ArtisanHomeScreen({super.key});

  @override
  State<ArtisanHomeScreen> createState() => _ArtisanHomeScreenState();
}

class _ArtisanHomeScreenState extends State<ArtisanHomeScreen> {
  Map<String, dynamic>? dash;
  final greeting = GreetingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    greeting.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final s = context.read<Session>();
    greeting.load(s);
    try {
      final d = Map<String, dynamic>.from(await s.api.get('/artisans/me/dashboard'));
      if (!mounted) return;
      setState(() => dash = d);
      context.read<SyncQueue>().run();
    } catch (_) {
      // offline: the home still works; captures queue on the phone
    }
  }

  String _summary() {
    final l = context.l;
    return l.earningsSummary(rupees(dash?['earned_this_month'] ?? 0), (dash?['orders_paid_this_month'] ?? 0) as int);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = context.watch<Session>();
    final speakFirst = s.publicConfig?['tile_tap_mode'] != 'open';
    final name = (dash?['artisan']?['name_native'] ?? dash?['artisan']?['name'] ?? s.profile?['name'] ?? '') as String;
    final open = (dash?['open_orders'] ?? 0) as int;
    final ready = (dash?['products_by_status']?['ready'] ?? 0) as int;
    return Scaffold(
      floatingActionButton: ListenableBuilder(
          listenable: greeting, builder: (_, _) => AssistantFab(greeting: greeting.data)),
      appBar: AppBar(
        title: const Wordmark(),
        actions: [
          IconButton(onPressed: () => context.push('/language'), icon: const Icon(Icons.translate_rounded), tooltip: l.chooseLanguage),
          const ThemeToggle(),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'about') context.push('/about');
              if (v == 'low') await s.setLowData(!s.lowData);
              if (v == 'logout') {
                await s.logout();
                if (context.mounted) context.go('/welcome');
              }
            },
            itemBuilder: (_) => [
              CheckedPopupMenuItem(value: 'low', checked: s.lowData, child: Text(l.lowBandwidth)),
              PopupMenuItem(value: 'about', child: Text(l.about)),
              PopupMenuItem(value: 'logout', child: Text(l.logout)),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), children: [
          ListenableBuilder(
            listenable: greeting,
            builder: (_, _) => greeting.data != null
                ? GreetingCard(data: greeting.data)
                : Row(children: [
                    Expanded(child: Text(l.greeting(name), style: Theme.of(context).textTheme.headlineSmall)),
                    SpeakButton(l.greeting(name)),
                  ]),
          ),
          const SizedBox(height: 8),
          const Align(alignment: Alignment.centerLeft, child: SyncBanner()),
          const SizedBox(height: 16),
          SpeakTile(
            icon: Icons.add_a_photo_rounded,
            label: l.tileAddProduct,
            color: SS.maroon,
            big: true,
            speakFirst: speakFirst,
            onOpen: () => context.push('/artisan/capture'),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: [
              SpeakTile(icon: Icons.inventory_2_rounded, label: l.tileMyProducts, color: SS.teal, speakFirst: speakFirst,
                  badge: ready > 0 ? '$ready' : null, onOpen: () => context.push('/artisan/products')),
              SpeakTile(icon: Icons.receipt_long_rounded, label: l.tileOrders, color: SS.ochre, speakFirst: speakFirst,
                  badge: open > 0 ? '$open' : null, onOpen: () => context.push('/artisan/orders')),
              SpeakTile(icon: Icons.account_balance_wallet_rounded, label: l.tileEarnings, color: SS.verifiedGreen,
                  speakFirst: speakFirst, onOpen: () => context.push('/artisan/earnings')),
              SpeakTile(icon: Icons.support_agent_rounded, label: l.tileHelp, color: SS.slateDark, speakFirst: speakFirst,
                  onOpen: () => context.push('/artisan/help')),
            ],
          ),
          const SizedBox(height: 16),
          if (dash != null)
            Material(
              color: SS.white,
              borderRadius: BorderRadius.circular(SS.radius),
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: Icon(Icons.savings_rounded, color: SS.ochre, size: 40),
                title: Text(_summary(), style: Theme.of(context).textTheme.titleMedium),
                trailing: Icon(Icons.volume_up_rounded, color: SS.heading),
                onTap: () => context.voice.speak(_summary()),
              ),
            ),
        ]),
      ),
    );
  }
}
