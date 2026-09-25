import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../../core/session.dart';
import '../widgets.dart';

/// Product detail (mockup screen 3).
class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key, required this.productId});
  final String productId;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  Map<String, dynamic>? p;
  Object? error;
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final s = context.read<Session>();
    try {
      final r = await s.api.get('/storefront/products/${widget.productId}', {'lang': s.language});
      if (mounted) setState(() => p = Map<String, dynamic>.from(r));
    } catch (e) {
      if (mounted) setState(() => error = e);
    }
  }

  Future<void> _addToCart() async {
    final s = context.read<Session>();
    final l = context.l;
    if (!await ensureShopper(context, '/store/cart?add=${widget.productId}')) return;
    try {
      await s.api.post('/cart', {'product_id': widget.productId, 'quantity': 1});
      if (!mounted) return;
      spokenMessage(context, l.addedToCart);
      context.push('/store/cart');
    } catch (e) {
      if (mounted) spokenError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (p == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
            child: error != null
                ? FilledButton(onPressed: _load, child: Text(context.l.retry))
                : const CircularProgressIndicator()),
      );
    }
    return ProductDetailView(
      product: p!,
      onAddToCart: _addToCart,
      onOpenCertificate: () {
        final c = p!['certificate'];
        if (c != null) context.push('/store/cert/${c['id']}?s=${Uri.encodeQueryComponent((c['qr_url'] as String).split('s=').last)}');
      },
      onPlayVoice: (url) => _player.play(UrlSource(url)),
      onOpenProduct: (id) => context.push('/store/p/$id'),
      languageCode: context.read<Session>().language,
    );
  }
}

class ProductDetailView extends StatelessWidget {
  const ProductDetailView({
    super.key,
    required this.product,
    this.onAddToCart,
    this.onOpenCertificate,
    this.onPlayVoice,
    this.onOpenProduct,
    this.languageCode = 'en',
  });

  final Map<String, dynamic> product;
  final VoidCallback? onAddToCart;
  final VoidCallback? onOpenCertificate;
  final ValueChanged<String>? onPlayVoice;
  final ValueChanged<String>? onOpenProduct;
  final String languageCode;

  String? get _hero {
    final media = (product['media'] as List? ?? []).cast<Map>();
    final m = media.firstWhere((m) => m['kind'] == 'enhanced_4x5',
        orElse: () => media.firstWhere((m) => m['kind'] == 'enhanced', orElse: () => const {}));
    return m['url'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final p = product;
    final a = Map<String, dynamic>.from(p['artisan'] ?? {});
    final q = p['price_quote'] == null ? null : Map<String, dynamic>.from(p['price_quote']);
    final cert = p['certificate'] == null ? null : Map<String, dynamic>.from(p['certificate']);
    final story = (a['story_translations'] as Map?)?[languageCode]?['text'] ?? a['story_text'];
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 420,
          backgroundColor: SS.teal,
          foregroundColor: SS.cream,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(fit: StackFit.expand, children: [
              CraftImage(_hero, semanticLabel: p['title']),
              if (a['verified'] == true)
                Positioned(left: 16, top: MediaQuery.paddingOf(context).top + 64, child: VerifiedBadge(label: l.verifiedArtisan)),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
          sliver: SliverList.list(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Text(p['title'] ?? '',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: SS.heading, fontWeight: FontWeight.w700)),
              ),
              SpeakButton('${p['title']}. ${rupees(p['price'])}'),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.place_outlined, size: 18, color: SS.ochre),
              const SizedBox(width: 4),
              Expanded(child: Text(p['location'] ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SS.slateDark))),
            ]),
            const SizedBox(height: 14),
            FairPriceRow(price: p['price'], compareAt: p['compare_at_price']),
            const SizedBox(height: 8),
            if ((p['rating_count'] ?? 0) > 0)
              StarRating(
                  rating: (p['rating_avg'] as num?) ?? 0,
                  count: p['rating_count'] as int?,
                  countLabel: (c) => l.reviewsCount(c)),
            const SizedBox(height: 16),
            if (cert != null)
              _CertificateCard(qrUrl: cert['qr_url'] as String, title: l.scanCertificate, subtitle: l.certificateSub,
                  onTap: onOpenCertificate),
            const SizedBox(height: 12),
            if (q != null)
              PriceBreakdown(
                quote: q,
                title: l.howPriceBuilt,
                languageCode: languageCode,
                shareLine: (amount, pct) => l.goesToArtisan(amount, pct),
              ),
            const SizedBox(height: 20),
            if (p['description'] != null) Text(p['description'], style: Theme.of(context).textTheme.bodyLarge),
            if ((p['details'] as List? ?? []).isNotEmpty) ...[
              const SizedBox(height: 22),
              Text(l.productDetails, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              _DetailsCard(rows: (p['details'] as List).cast<Map>()),
            ],
            if (p['craft'] != null) ...[
              const SizedBox(height: 22),
              _CraftStory(craft: Map<String, dynamic>.from(p['craft'])),
            ],
            const SizedBox(height: 22),
            Text(l.meetArtisan, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: SS.white, borderRadius: BorderRadius.circular(SS.radius), boxShadow: SS.cardShadow),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  SizedBox(width: 64, height: 64, child: CraftImage(a['photo_url'], radius: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(a['name'] ?? '', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: SS.heading)),
                      if (a['name_native'] != null && a['name_native'] != a['name'])
                        Text(a['name_native'], style: Theme.of(context).textTheme.bodyMedium),
                      Text([
                        a['craft_type'],
                        if (a['years_practice'] != null) l.yearsOfPractice(a['years_practice'] as int),
                      ].whereType<String>().join(' · '), style: Theme.of(context).textTheme.bodySmall),
                    ]),
                  ),
                ]),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _Fact(Icons.home_work_outlined,
                      [a['village'], a['district'], a['state']].whereType<String>().toSet().join(', ')),
                  if (a['cluster'] != null) _Fact(Icons.groups_2_outlined, a['cluster']),
                  if (a['gi_tag'] != null) _Fact(Icons.workspace_premium_outlined, 'GI: ${a['gi_tag']}'),
                  if (a['live_products'] != null) _Fact(Icons.storefront_outlined, l.productsCount(a['live_products'] as int)),
                ]),
                if (story != null) ...[
                  const SizedBox(height: 12),
                  Text('“$story”', style: SS.story()),
                ],
                if (a['story_audio_url'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: OutlinedButton.icon(
                      onPressed: () => onPlayVoice?.call(a['story_audio_url']),
                      icon: const Icon(Icons.play_circle_outline_rounded),
                      label: Text(l.hearVoice),
                    ),
                  ),
              ]),
            ),
            if ((p['more_from_artisan'] as List? ?? []).isNotEmpty) ...[
              const SizedBox(height: 22),
              Text(l.moreFromArtisan, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              SizedBox(
                height: 310,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: (p['more_from_artisan'] as List).length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final m = Map<String, dynamic>.from((p['more_from_artisan'] as List)[i]);
                    return SizedBox(width: 176, child: ProductCard(product: m, onTap: () => onOpenProduct?.call(m['id'])));
                  },
                ),
              ),
            ],
          ]),
        ),
      ]),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          height: 60,
          child: FilledButton.icon(
            onPressed: onAddToCart,
            icon: const Icon(Icons.shopping_bag_rounded),
            style: FilledButton.styleFrom(backgroundColor: SS.maroon, shape: const StadiumBorder()),
            label: Text(l.addToCart),
          ),
        ),
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({required this.qrUrl, required this.title, required this.subtitle, this.onTap});
  final String qrUrl;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: SS.white,
        borderRadius: BorderRadius.circular(SS.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SS.radius),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(SS.radius), border: Border.all(color: SS.sand)),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: QrImageView(data: qrUrl, size: 64, padding: EdgeInsets.zero,
                    eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: SS.tealDeep),
                    dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: SS.tealDeep)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: SS.heading)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ]),
              ),
              Icon(Icons.chevron_right_rounded, color: SS.slate),
            ]),
          ),
        ),
      );
}


/// Label/value rows: technique, materials, colours, time to make, size, GI tag, care.
class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.rows});
  final List<Map> rows;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: SS.white, borderRadius: BorderRadius.circular(SS.radius), boxShadow: SS.cardShadow),
        child: Column(children: [
          for (final (i, r) in rows.indexed)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  border: i == rows.length - 1 ? null : Border(bottom: BorderSide(color: SS.sandLight))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  width: 124,
                  child: Text('${r['label']}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SS.slate)),
                ),
                Expanded(child: Text('${r['value']}', style: Theme.of(context).textTheme.bodyMedium)),
              ]),
            ),
        ]),
      );
}

/// "About this art form": history, how it is made and a did-you-know, readable aloud.
class _CraftStory extends StatelessWidget {
  const _CraftStory({required this.craft});
  final Map<String, dynamic> craft;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SS.radius),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [SS.teal, SS.tealDeep]),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.auto_stories_rounded, color: SS.marigold),
          const SizedBox(width: 8),
          Expanded(child: Text(l.aboutArtForm, style: text.labelLarge?.copyWith(color: SS.marigold))),
          SpeakButton('${craft['name']}. ${craft['history']} ${craft['making']} ${craft['fact']}', color: SS.cream),
        ]),
        const SizedBox(height: 6),
        Text('${craft['name']}', style: text.headlineSmall?.copyWith(color: SS.cream)),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 6, children: [
          _Pill(Icons.place_outlined, '${craft['region']}'),
          if (craft['gi'] != null) _Pill(Icons.workspace_premium_outlined, 'GI · ${craft['gi']}'),
        ]),
        const SizedBox(height: 14),
        Text('${craft['history']}', style: SS.story(16).copyWith(color: SS.cream)),
        const SizedBox(height: 14),
        Text(l.howItsMade, style: text.titleSmall?.copyWith(color: SS.marigold)),
        const SizedBox(height: 4),
        Text('${craft['making']}', style: text.bodyMedium?.copyWith(color: SS.cream, height: 1.5)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SS.marigold.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(SS.radiusSmall),
            border: Border.all(color: SS.marigold.withValues(alpha: 0.5)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.lightbulb_outline_rounded, color: SS.marigold),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: '${l.didYouKnow} ', style: const TextStyle(fontWeight: FontWeight.w700, color: SS.marigold)),
                  TextSpan(text: '${craft['fact']}', style: const TextStyle(color: SS.cream)),
                ]),
                style: text.bodyMedium,
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(99)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: SS.sand),
          const SizedBox(width: 4),
          Flexible(child: Text(label, style: TextStyle(color: SS.sand, fontSize: 13, fontFamily: SS.poppins))),
        ]),
      );
}

class _Fact extends StatelessWidget {
  const _Fact(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: SS.sandLight, borderRadius: BorderRadius.circular(99)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: SS.ochre),
          const SizedBox(width: 5),
          Flexible(child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: SS.slateDark))),
        ]),
      );
}
