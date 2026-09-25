import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../../core/session.dart';
import '../assistant/assistant.dart';
import '../assistant/greeting_card.dart';
import '../widgets.dart';

/// Buyer storefront home (mockup screen 1): teal bar with marigold wordmark, sand search bar with voice
/// search, "Fresh from the loom & wheel" 2-column grid, then category / cluster / women-led / GI sections.
class StoreHomeScreen extends StatefulWidget {
  const StoreHomeScreen({super.key});

  @override
  State<StoreHomeScreen> createState() => _StoreHomeScreenState();
}

class _StoreHomeScreenState extends State<StoreHomeScreen> {
  Map<String, dynamic>? feed;
  Object? error;
  final greeting = GreetingController();

  @override
  void initState() {
    super.initState();
    _load();
    greeting.load(context.read<Session>());
  }

  @override
  void dispose() {
    greeting.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final s = context.read<Session>();
    try {
      final f = await s.api.get('/storefront/feed', {'lang': s.language, 'state': s.buyerState});
      if (mounted) setState(() => (feed = Map<String, dynamic>.from(f), error = null));
    } catch (e) {
      if (mounted) setState(() => error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreHomeView(
      feed: feed,
      error: error,
      onRetry: _load,
      onSearch: (q) => context.push('/store/search?q=${Uri.encodeQueryComponent(q)}'),
      onVoiceSearch: () async {
        final v = context.voice;
        await v.listen(onFinal: (t) {
          if (t.isNotEmpty && mounted) context.push('/store/search?q=${Uri.encodeQueryComponent(t)}');
        });
      },
      onOpenProduct: (id) => context.push('/store/p/$id'),
      onCategory: (c) => context.push('/store/search?category=${Uri.encodeQueryComponent(c)}'),
      onState: (s) => context.push('/store/search?state=${Uri.encodeQueryComponent(s)}'),
      onCart: () => context.push('/store/cart'),
      onMenu: () => _menu(context),
      header: ListenableBuilder(listenable: greeting, builder: (_, _) => GreetingCard(data: greeting.data)),
      fab: ListenableBuilder(listenable: greeting, builder: (_, _) => AssistantFab(greeting: greeting.data)),
    );
  }

  void _menu(BuildContext context) {
    final l = context.l;
    final s = context.read<Session>();
    void open(String route) {
      Navigator.pop(context); // close the menu first so it is not waiting behind the page
      context.push(route);
    }

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: const Icon(Icons.receipt_long_rounded), title: Text(l.myOrders), onTap: () => open('/store/orders')),
          ListTile(leading: const Icon(Icons.shopping_bag_outlined), title: Text(l.cart), onTap: () => open('/store/cart')),
          ListTile(leading: const Icon(Icons.qr_code_scanner_rounded), title: Text(l.scanQr), onTap: () => open('/store/scan')),
          ListTile(leading: const Icon(Icons.translate_rounded), title: Text(l.chooseLanguage), onTap: () => open('/language')),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_rounded),
            title: Text(l.darkMode),
            value: s.dark,
            onChanged: (v) {
              Navigator.pop(sheet);
              s.setDark(v);
            },
          ),
          ListTile(leading: const Icon(Icons.swap_horiz_rounded), title: Text(l.switchRole), onTap: () async {
            Navigator.pop(context);
            await s.logout();
            if (context.mounted) context.go('/welcome');
          }),
          ListTile(leading: const Icon(Icons.info_outline_rounded), title: Text(l.about), onTap: () => open('/about')),
        ]),
      ),
    );
  }
}

class StoreHomeView extends StatelessWidget {
  const StoreHomeView({
    super.key,
    required this.feed,
    this.error,
    this.onRetry,
    this.onSearch,
    this.onVoiceSearch,
    this.onOpenProduct,
    this.onCategory,
    this.onState,
    this.onCart,
    this.onMenu,
    this.header,
    this.fab,
  });

  final Map<String, dynamic>? feed;
  final Object? error;
  final VoidCallback? onRetry;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onVoiceSearch;
  final ValueChanged<String>? onOpenProduct;
  final ValueChanged<String>? onCategory;
  final ValueChanged<String>? onState;
  final VoidCallback? onCart;
  final VoidCallback? onMenu;
  final Widget? header; // Shilpi's greeting card under the search bar
  final Widget? fab;

  static const _catIcons = {
    'Textiles & Handloom': Icons.checkroom_rounded,
    'Pottery & Ceramics': Icons.local_florist_rounded,
    'Metalcraft': Icons.hardware_rounded,
    'Woodcraft': Icons.carpenter_rounded,
    'Bamboo & Cane': Icons.grass_rounded,
    'Jewellery': Icons.diamond_outlined,
    'Paintings & Folk Art': Icons.palette_outlined,
    'Toys & Dolls': Icons.toys_outlined,
    'Home Décor': Icons.chair_outlined,
    'Leather': Icons.hiking_rounded,
    'Stone Craft': Icons.landscape_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final sections = (feed?['sections'] as List? ?? []).cast<Map>();
    final fresh = sections.firstWhere((s) => s['key'] == 'fresh', orElse: () => {'items': []});
    final others = sections.where((s) => s['key'] != 'fresh').toList();
    final titles = {'women_led': l.womenLed, 'gi': l.giTagged, 'near_you': l.nearYou};
    return Scaffold(
      floatingActionButton: fab,
      appBar: AppBar(
        backgroundColor: SS.teal,
        title: const Wordmark(size: 26),
        actions: [
          IconButton(onPressed: onCart, tooltip: l.cart, icon: const Icon(Icons.shopping_bag_outlined)),
          IconButton(onPressed: onMenu, tooltip: l.about, icon: const Icon(Icons.menu_rounded)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => onRetry?.call(),
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                textInputAction: TextInputAction.search,
                onSubmitted: onSearch,
                decoration: InputDecoration(
                  hintText: l.searchHint,
                  prefixIcon: Icon(Icons.search_rounded, color: SS.slate),
                  suffixIcon: IconButton(
                      tooltip: l.tapToSpeak, onPressed: onVoiceSearch, icon: Icon(Icons.mic_rounded, color: SS.maroon)),
                ),
              ),
            ),
          ),
          if (header != null)
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 0), child: header)),
          if (error != null && feed == null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.wifi_off_rounded, size: 48, color: SS.slate),
                  const SizedBox(height: 12),
                  Text(l.errorNetwork, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: onRetry, child: Text(l.retry)),
                ]),
              ),
            )
          else if (feed == null)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else ...[
            SliverToBoxAdapter(child: SectionTitle(l.freshFromLoom)),
            _grid(context, (fresh['items'] as List).cast<Map>()),
            SliverToBoxAdapter(child: SectionTitle(l.byCraft)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 104,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    for (final c in (feed!['categories'] as List? ?? []).cast<Map>())
                      _CategoryChip(
                        icon: _catIcons[c['name']] ?? Icons.category_outlined,
                        label: c['name'] as String,
                        count: c['count'] as int,
                        onTap: () => onCategory?.call(c['name'] as String),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SectionTitle(l.byState)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final c in (feed!['clusters'] as List? ?? []).cast<Map>())
                    ActionChip(
                      avatar: Icon(Icons.place_outlined, size: 18, color: SS.ochre),
                      label: Text('${c['cluster'] ?? c['state']} · ${c['state']}'),
                      onPressed: () => onState?.call(c['state'] as String),
                    ),
                ]),
              ),
            ),
            for (final s in others) ...[
              SliverToBoxAdapter(child: SectionTitle(titles[s['key']] ?? '${s['title']}')),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 310,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: (s['items'] as List).length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final p = Map<String, dynamic>.from((s['items'] as List)[i]);
                      return SizedBox(
                          width: 176,
                          child: ProductCard(product: p, verifiedLabel: l.verifiedArtisan, onTap: () => onOpenProduct?.call(p['id'])));
                    },
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ]),
      ),
    );
  }

  Widget _grid(BuildContext context, List<Map> items) => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.58),
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              final p = Map<String, dynamic>.from(items[i]);
              return ProductCard(product: p, verifiedLabel: context.l.verifiedArtisan, onTap: () => onOpenProduct?.call(p['id']));
            },
            childCount: items.length,
          ),
        ),
      );
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.icon, required this.label, required this.count, this.onTap});
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SS.radius),
          child: Container(
            width: 112,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: SS.white, borderRadius: BorderRadius.circular(SS.radius), boxShadow: SS.cardShadow),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, color: SS.ochre, size: 30),
              const SizedBox(height: 6),
              Text(label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: SS.heading, fontFamily: SS.poppins)),
            ]),
          ),
        ),
      );
}
