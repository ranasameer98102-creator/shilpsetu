import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../../core/session.dart';
import '../widgets.dart';

/// Artisan orders: accept / decline with one tap (also possible by SMS reply or IVR key press), then pack & ship.
class ArtisanOrdersScreen extends StatefulWidget {
  const ArtisanOrdersScreen({super.key});

  @override
  State<ArtisanOrdersScreen> createState() => _ArtisanOrdersScreenState();
}

class _ArtisanOrdersScreenState extends State<ArtisanOrdersScreen> {
  List<Map>? orders;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = context.read<Session>();
      final r = await s.api.get('/artisan/orders', {'lang': s.language});
      if (!mounted) return;
      setState(() => orders = (r as List).cast<Map>());
      final fresh = orders!.where((o) => o['status'] == 'placed').length;
      if (fresh > 0) context.voice.speak('${context.l.newOrder}: $fresh');
    } catch (e) {
      if (mounted) spokenError(context, e);
    }
  }

  Future<void> _set(Map o, String status) async {
    try {
      await context.read<Session>().api.post('/orders/${o['id']}/status', {'status': status});
      await _load();
    } catch (e) {
      if (mounted) spokenError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.tileOrders)),
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
                      final it = (o['items'] as List).cast<Map>().first;
                      final title = it['product']['title'] ?? '';
                      final status = o['status'] as String;
                      final spoken = '$title. ${rupees(it['unit_price'] * it['quantity'])}. ${orderStatusLabel(l, status)}';
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              SizedBox(width: 64, height: 64, child: CraftImage(it['product']['thumb'], radius: 12)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                                  Text('${rupees(it['unit_price'])} × ${it['quantity']} · ${o['address']?['city'] ?? ''}',
                                      style: Theme.of(context).textTheme.bodySmall),
                                  if (o['channel'] == 'ondc') Text('ONDC', style: TextStyle(color: SS.ochre, fontWeight: FontWeight.w700)),
                                ]),
                              ),
                              SpeakButton(spoken),
                            ]),
                            const SizedBox(height: 10),
                            StatusChip(status: status, label: orderStatusLabel(l, status)),
                            const SizedBox(height: 10),
                            if (status == 'placed')
                              Row(children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 58,
                                    child: FilledButton.icon(
                                      style: FilledButton.styleFrom(backgroundColor: SS.verifiedGreen),
                                      onPressed: () => _set(o, 'accepted'),
                                      icon: const Icon(Icons.check_rounded, size: 28),
                                      label: Text(l.accept),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SizedBox(
                                    height: 58,
                                    child: OutlinedButton.icon(
                                      onPressed: () => _set(o, 'declined'),
                                      icon: const Icon(Icons.close_rounded),
                                      label: Text(l.decline),
                                    ),
                                  ),
                                ),
                              ])
                            else if (status == 'accepted')
                              FilledButton.icon(onPressed: () => _set(o, 'packed'), icon: const Icon(Icons.inventory_2_rounded), label: Text(l.markPacked))
                            else if (status == 'packed')
                              FilledButton.icon(onPressed: () => _set(o, 'shipped'), icon: const Icon(Icons.local_shipping_rounded), label: Text(l.markShipped)),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
