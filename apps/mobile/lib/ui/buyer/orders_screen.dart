import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../../core/session.dart';
import '../widgets.dart';

/// Buyer's orders: lifecycle placed → accepted → packed → shipped → delivered → review, with courier tracking.
class BuyerOrdersScreen extends StatefulWidget {
  const BuyerOrdersScreen({super.key});

  @override
  State<BuyerOrdersScreen> createState() => _BuyerOrdersScreenState();
}

class _BuyerOrdersScreenState extends State<BuyerOrdersScreen> {
  List<Map>? orders;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = context.read<Session>();
    if (!s.canShop) {
      WidgetsBinding.instance.addPostFrameCallback((_) => ensureShopper(context, '/store/orders', replace: true));
      return;
    }
    try {
      final r = await s.api.get('/orders', {'lang': s.language});
      if (mounted) setState(() => orders = (r as List).cast<Map>());
    } catch (e) {
      if (!mounted) return;
      spokenError(context, e);
      if (orders == null) setState(() => orders = []); // never leave a spinner behind
    }
  }

  Future<void> _review(Map item) async {
    var rating = 5;
    final text = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: Text(context.l.rateCraft),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => set(() => rating = i),
                  icon: Icon(i <= rating ? Icons.star_rounded : Icons.star_outline_rounded, color: SS.ochre, size: 34),
                ),
            ]),
            TextField(controller: text, maxLines: 3),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l.cancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.l.save)),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await context.read<Session>().api.post('/reviews', {'order_item_id': item['id'], 'rating': rating, 'text': text.text});
      _load();
    } catch (e) {
      if (mounted) spokenError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.myOrders)),
      body: orders == null
          ? const Center(child: CircularProgressIndicator())
          : orders!.isEmpty
              ? Center(child: Text(l.noOrders))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders!.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final o = orders![i];
                      final events = ((o['tracking'] ?? {})['events'] as List? ?? []).cast<Map>();
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Text('#${(o['id'] as String).substring(0, 8)}', style: Theme.of(context).textTheme.bodySmall),
                              const Spacer(),
                              StatusChip(status: o['status'], label: orderStatusLabel(l, o['status'])),
                            ]),
                            for (final it in (o['items'] as List).cast<Map>())
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: SizedBox(width: 52, height: 52, child: CraftImage(it['product']['thumb'], radius: 10)),
                                title: Text(it['product']['title'] ?? ''),
                                subtitle: Text(rupees(it['unit_price'])),
                                trailing: o['status'] == 'delivered' && it['reviewed'] != true
                                    ? TextButton(onPressed: () => _review(it), child: Text(l.rateCraft))
                                    : null,
                              ),
                            if (o['delivery_estimate_days'] != null && o['status'] != 'delivered')
                              Text(l.deliveryIn(o['delivery_estimate_days'] as int), style: Theme.of(context).textTheme.bodySmall),
                            if (events.isNotEmpty)
                              Text('${o['tracking']['carrier']} · ${events.last['status']}',
                                  style: Theme.of(context).textTheme.bodySmall),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
