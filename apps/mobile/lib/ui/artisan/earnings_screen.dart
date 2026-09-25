import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../../core/session.dart';
import '../widgets.dart';

/// Earnings in simple visuals + spoken summary + the payout ledger (gross, fee, shipping, net — every rupee).
class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  Map<String, dynamic>? ledger;
  Map<String, dynamic>? dash;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = context.read<Session>().api;
    try {
      final r = await Future.wait([api.get('/artisans/me/ledger'), api.get('/artisans/me/dashboard')]);
      if (!mounted) return;
      setState(() => (ledger = Map<String, dynamic>.from(r[0]), dash = Map<String, dynamic>.from(r[1])));
      context.voice.speak(_summary());
    } catch (e) {
      if (mounted) spokenError(context, e);
    }
  }

  String _summary() => context.l.earningsSummary(rupees(dash?['earned_this_month'] ?? 0), (dash?['orders_paid_this_month'] ?? 0) as int);

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    if (ledger == null) return Scaffold(appBar: AppBar(title: Text(l.tileEarnings)), body: const Center(child: CircularProgressIndicator()));
    final t = ledger!['totals'] as Map;
    final payouts = (ledger!['payouts'] as List).cast<Map>();
    final gross = (t['gross'] as num).toDouble();
    return Scaffold(
      appBar: AppBar(title: Text(l.tileEarnings), actions: [SpeakButton(_summary(), color: SS.cream)]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: SS.teal, borderRadius: BorderRadius.circular(SS.radius)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_summary(), style: const TextStyle(color: SS.cream, fontSize: 19, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            // coins: one coin per ₹500 received, capped for readability
            Wrap(spacing: 4, runSpacing: 4, children: [
              for (var i = 0; i < ((t['net'] as num) / 500).clamp(0, 40).floor(); i++)
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(color: SS.marigold, shape: BoxShape.circle),
                  child: Icon(Icons.currency_rupee_rounded, color: SS.tealDeep, size: 17),
                ),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        Text(l.everyRupee, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        _bar(context, l.gross, t['gross'], gross, SS.ochre),
        _bar(context, l.commission, t['commission'], gross, SS.sand),
        _bar(context, l.logistics, t['logistics'], gross, SS.sand),
        _bar(context, l.net, t['net'], gross, SS.verifiedGreen),
        const SizedBox(height: 16),
        for (final p in payouts)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              leading: Icon(Icons.payments_rounded, color: SS.verifiedGreen, size: 32),
              title: Text('${l.net}: ${rupees(p['net'])}', style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${l.gross} ${rupees(p['gross'])} − ${l.commission} ${rupees(p['commission'])} − ${l.logistics} ${rupees(p['logistics'])}\n'
                  '${(p['at'] as String).substring(0, 10)}'),
              isThreeLine: true,
              onTap: () => context.voice.speak('${l.net} ${rupees(p['net'])}'),
            ),
          ),
      ]),
    );
  }

  Widget _bar(BuildContext context, String label, num value, double max, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(label)), Text(rupees(value), style: Theme.of(context).textTheme.titleSmall)]),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
                value: max > 0 ? (value / max).clamp(0, 1).toDouble() : 0, minHeight: 14, color: color, backgroundColor: SS.sandLight),
          ),
        ]),
      );
}
