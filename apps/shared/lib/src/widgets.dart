import 'package:flutter/material.dart';

import 'theme.dart';

/// "✓ Verified Artisan" — white pill, green text (overlays hero images).
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.label = 'Verified Artisan', this.compact = false});
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 3 : 6),
        decoration: BoxDecoration(color: SS.white, borderRadius: BorderRadius.circular(99), boxShadow: SS.cardShadow),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_rounded, size: compact ? 14 : 18, color: SS.verifiedGreen),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: SS.verifiedGreen,
                fontWeight: FontWeight.w600,
                fontSize: compact ? 12 : 14,
                fontFamily: SS.poppins,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PricePill extends StatelessWidget {
  const PricePill(this.price, {super.key});
  final num? price;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(color: SS.maroon, borderRadius: BorderRadius.circular(99)),
    child: Text(
      rupees(price),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15, fontFamily: SS.poppins),
    ),
  );
}

/// ₹1,450 in bold maroon next to a struck-through market price (mockup screen 3).
class FairPriceRow extends StatelessWidget {
  const FairPriceRow({super.key, required this.price, this.compareAt, this.size = 30});
  final num? price;
  final num? compareAt;
  final double size;

  @override
  Widget build(BuildContext context) => Wrap(
    crossAxisAlignment: WrapCrossAlignment.end,
    spacing: 10,
    children: [
      Text(
        rupees(price),
        style: TextStyle(
          fontFamily: SS.poppins,
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: SS.maroon,
          height: 1.1,
        ),
      ),
      if (compareAt != null && compareAt! > (price ?? 0))
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(
            rupees(compareAt),
            style: TextStyle(
              fontFamily: SS.poppins,
              fontSize: size * 0.58,
              color: SS.slate,
              decoration: TextDecoration.lineThrough,
              decorationColor: SS.slate,
            ),
          ),
        ),
    ],
  );
}

class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating, this.count, this.size = 20, this.countLabel});
  final num rating;
  final int? count;
  final double size;
  final String Function(int)? countLabel;

  @override
  Widget build(BuildContext context) {
    final stars = List.generate(5, (i) {
      final v = rating - i;
      return Icon(
        v >= 0.75 ? Icons.star_rounded : (v >= 0.25 ? Icons.star_half_rounded : Icons.star_outline_rounded),
        color: SS.ochre,
        size: size,
      );
    });
    return Semantics(
      label: '${rating.toStringAsFixed(1)} of 5',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...stars,
          if (count != null) ...[
            const SizedBox(width: 6),
            Text(countLabel?.call(count!) ?? '($count reviews)', style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// Network image with the maroon→ochre gradient placeholder the spec asks for when an image is missing.
class CraftImage extends StatelessWidget {
  const CraftImage(this.url, {super.key, this.fit = BoxFit.cover, this.radius = 0, this.semanticLabel});
  final String? url;
  final BoxFit fit;
  final double radius;
  final String? semanticLabel;

  static final gradient = LinearGradient(
    colors: [SS.maroon, SS.ochre],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      decoration: BoxDecoration(gradient: gradient),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Color(0x88F6EFE2), size: 40),
    );
    final child = (url == null || url!.isEmpty)
        ? placeholder
        : Image.network(
            url!,
            fit: fit,
            semanticLabel: semanticLabel,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => placeholder,
            // Show the placeholder until the first frame is decoded (slow 2G/3G would otherwise show blank white).
            frameBuilder: (_, child, frame, sync) => sync || frame != null ? child : placeholder,
          );
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: child);
  }
}

/// Storefront grid card: image, title, price pill, small circular verified indicator (mockup screen 1).
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.onTap, this.verifiedLabel = 'Verified Artisan'});
  final Map<String, dynamic> product;
  final VoidCallback? onTap;
  final String verifiedLabel;

  @override
  Widget build(BuildContext context) {
    final p = product;
    return Semantics(
      button: true,
      label: '${p['title']}, ${rupees(p['price'])}',
      child: DecoratedBox(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(SS.radius), boxShadow: SS.cardShadow),
        child: Material(
          color: SS.white,
          borderRadius: BorderRadius.circular(SS.radius),
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CraftImage(p['thumb'] ?? p['image'], semanticLabel: p['title']),
                      if (p['verified'] == true)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Tooltip(
                            message: verifiedLabel,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: SS.white,
                                shape: BoxShape.circle,
                                boxShadow: SS.cardShadow,
                              ),
                              child: Icon(Icons.verified_rounded, color: SS.verifiedGreen, size: 20),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p['title'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: SS.poppins,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: SS.heading,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          p['location'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontFamily: SS.poppins, fontSize: 12.5, color: SS.slate),
                        ),
                        const Spacer(),
                        PricePill(p['price']),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "How this price is built": every rupee line, and how much reaches the artisan.
class PriceBreakdown extends StatelessWidget {
  const PriceBreakdown({
    super.key,
    required this.quote,
    this.title = 'How this price is built',
    this.shareLine,
    this.languageCode = 'en',
    this.initiallyExpanded = false,
  });

  final Map<String, dynamic> quote;
  final String title;
  final String Function(String amount, String pct)? shareLine;
  final String languageCode;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final lines = (quote['breakdown'] as List? ?? []).cast<Map>();
    final share = rupees(quote['artisan_share_amount']);
    final pct = (quote['artisan_share_pct'] as num?)?.toStringAsFixed(0) ?? '';
    final shareText = shareLine?.call(share, pct) ?? '$share of this goes directly to the artisan ($pct%)';
    final total = lines.fold<num>(0, (a, l) => a + (l['amount'] as num));
    return Material(
      color: SS.white,
      borderRadius: BorderRadius.circular(SS.radius),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shadowColor: const Color(0x33261F18),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Icon(Icons.receipt_long_rounded, color: SS.heading),
          title: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: SS.heading)),
          subtitle: Text(
            shareText,
            style: TextStyle(color: SS.verifiedGreen, fontWeight: FontWeight.w600, fontFamily: SS.poppins),
          ),
          children: [
            for (final l in lines) _row(context, l, total),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(child: Text(rupees(total), style: Theme.of(context).textTheme.titleMedium)),
                Text(
                  shareText,
                  style: TextStyle(fontSize: 13, color: SS.verifiedGreen, fontFamily: SS.poppins),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, Map l, num total) {
    final label = (languageCode == 'hi' && l['label_hi'] != null) ? l['label_hi'] : l['label'];
    final toArtisan = l['to_artisan'] == true;
    final frac = total > 0 ? ((l['amount'] as num) / total).clamp(0, 1).toDouble() : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                toArtisan ? Icons.person_rounded : Icons.local_shipping_outlined,
                size: 18,
                color: toArtisan ? SS.verifiedGreen : SS.slate,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text('$label', style: Theme.of(context).textTheme.bodyMedium)),
              Text(rupees(l['amount'] as num), style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: frac,
              minHeight: 6,
              backgroundColor: SS.sandLight,
              color: toArtisan ? SS.verifiedGreen : SS.sand,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status chip for a capture/listing: Queued / Uploading / Processing / Needs review / Ready / Live.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, required this.label});
  final String status;
  final String label;

  static (Color, IconData) style(String s) => switch (s) {
    'queued' => (SS.slate, Icons.schedule_rounded),
    'uploading' => (SS.ochre, Icons.cloud_upload_outlined),
    'processing' => (SS.marigold, Icons.auto_awesome_rounded),
    'needs_review' => (SS.danger, Icons.error_outline_rounded),
    'ready' => (SS.heading, Icons.thumb_up_alt_outlined),
    'live' => (SS.verifiedGreen, Icons.public_rounded),
    'unpublished' => (SS.slateDark, Icons.visibility_off_outlined),
    'failed' => (SS.danger, Icons.sync_problem_rounded),
    // order lifecycle
    'placed' => (SS.heading, Icons.fiber_new_rounded),
    'accepted' => (SS.heading, Icons.thumb_up_alt_outlined),
    'packed' => (SS.ochre, Icons.inventory_2_outlined),
    'shipped' => (SS.marigold, Icons.local_shipping_outlined),
    'delivered' => (SS.verifiedGreen, Icons.check_circle_rounded),
    'declined' || 'cancelled' => (SS.slateDark, Icons.block_rounded),
    'returned' => (SS.danger, Icons.assignment_return_outlined),
    _ => (SS.slate, Icons.circle_outlined),
  };

  @override
  Widget build(BuildContext context) {
    final (c, icon) = style(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: c.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: c),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 13, fontFamily: SS.poppins),
          ),
        ],
      ),
    );
  }
}

/// Brand wordmark: "ShilpSetu" in marigold Poppins bold.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 24});
  final double size;

  @override
  Widget build(BuildContext context) => Text(
    'ShilpSetu',
    style: TextStyle(
      fontFamily: SS.poppins,
      fontWeight: FontWeight.w700,
      fontSize: size,
      color: SS.marigold,
      letterSpacing: .2,
    ),
  );
}

class Credits extends StatelessWidget {
  const Credits({super.key, this.teamId, this.color});
  final String? teamId;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontFamily: SS.poppins, fontSize: 12.5, color: color ?? SS.slate);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('ShilpSetu · SIH 2026 · PS ID SIH26090', style: style, textAlign: TextAlign.center),
        Text(
          'Team HACKER LOBBY${teamId != null ? ' · Team ID $teamId' : ''}',
          style: style,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
