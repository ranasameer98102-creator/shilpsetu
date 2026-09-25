import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

/// White rounded panel with a teal title.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.title, required this.child, this.action, this.subtitle});
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: SS.white,
      borderRadius: BorderRadius.circular(SS.radius),
      boxShadow: SS.cardShadow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: SS.heading)),
                  if (subtitle != null) Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            ?action,
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

/// Headline number (a stat tile — not every number needs a chart).
class KpiTile extends StatelessWidget {
  const KpiTile({super.key, required this.label, required this.value, this.note, this.icon});
  final String label;
  final String value;
  final String? note;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 210,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: SS.white,
      borderRadius: BorderRadius.circular(SS.radius),
      boxShadow: SS.cardShadow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) Icon(icon, size: 18, color: SS.slate),
            if (icon != null) const SizedBox(width: 6),
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(fontFamily: SS.poppins, fontSize: 28, fontWeight: FontWeight.w700, color: SS.ink),
        ),
        if (note != null) Text(note!, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}

/// Single-series horizontal bar chart: one hue, bars anchored at the baseline with 4 px rounded data-ends,
/// 2 px gaps, recessive track, values in text ink, hover tooltip per bar. No legend (the title names it).
class BarList extends StatelessWidget {
  const BarList({
    super.key,
    required this.rows,
    this.format = _plain,
    this.color,
    this.barHeight = 18,
    this.tooltips,
  });
  final List<(String, num)> rows;
  final List<String>? tooltips;
  final String Function(num) format;
  final Color? color; // default: heading colour
  final double barHeight;

  static String _plain(num v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 1);

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const Text('—');
    final max = rows.map((r) => r.$2).fold<num>(0, math.max);
    return Column(
      children: [
        for (final (i, (label, v)) in rows.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1), // 2 px gap between adjacent bars
            child: Tooltip(
              message: '$label: ${format(v)}${tooltips != null ? '\n${tooltips![i]}' : ''}',
              child: Row(
                children: [
                  SizedBox(
                    width: 170,
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: SS.slateDark),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (_, c) => Stack(
                        children: [
                          Container(
                            height: barHeight + 8,
                            color: Colors.transparent,
                          ), // hit target bigger than the mark
                          Positioned(
                            top: 4,
                            left: 0,
                            child: Container(
                              width: max == 0 ? 0 : math.max(2, c.maxWidth * (v / max)),
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: color ?? SS.heading,
                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Text(
                      format(v),
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 13, color: SS.ink, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Status with icon + label (status colour is never used alone).
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});
  final String? status;

  @override
  Widget build(BuildContext context) {
    final s = status ?? '—';
    final (IconData icon, Color c) = switch (s) {
      'live' ||
      'synced' ||
      'verified' ||
      'sent' ||
      'delivered' ||
      'done' ||
      'paid' => (Icons.check_circle_rounded, SS.verifiedGreen),
      'failed' || 'rejected' || 'revoked' => (Icons.error_rounded, SS.danger),
      'queued' ||
      'pending' ||
      'open' ||
      'processing' ||
      'ready' ||
      'needs_review' => (Icons.schedule_rounded, SS.ochre),
      _ => (Icons.circle_outlined, SS.slate),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: c),
        const SizedBox(width: 4),
        Text(s.replaceAll('_', ' '), style: TextStyle(fontSize: 13, color: SS.ink)),
      ],
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) => const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Credits());
}
