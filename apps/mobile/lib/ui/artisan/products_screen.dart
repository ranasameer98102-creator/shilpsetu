import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../../core/session.dart';
import '../../offline/sync_queue.dart';
import '../widgets.dart';

/// My products: phone-side captures (Queued / Uploading) merged with server listings
/// (Processing / Needs review / Ready / Live), each with a clear status.
class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  List<Map>? server;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    context.read<SyncQueue>().run();
    try {
      final s = context.read<Session>();
      final r = await s.api.get('/products/mine', {'lang': s.language});
      if (mounted) setState(() => server = (r as List).cast<Map>());
    } catch (_) {
      if (mounted) setState(() => server ??= []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final q = context.watch<SyncQueue>();
    final serverIds = {for (final p in server ?? const <Map>[]) p['id']};
    final local = q.items.where((c) => c.productId == null || !serverIds.contains(c.productId)).toList();
    return Scaffold(
      appBar: AppBar(title: Text(l.tileMyProducts)),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: SS.maroon,
        foregroundColor: SS.cream,
        onPressed: () => context.push('/artisan/capture'),
        icon: const Icon(Icons.add_a_photo_rounded),
        label: Text(l.tileAddProduct),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), children: [
          const SyncBanner(),
          const SizedBox(height: 12),
          for (final c in local)
            _row(
              context,
              title: c.title ?? c.deviceTranscript ?? l.tileAddProduct,
              status: c.status,
              price: c.price,
              image: null,
              onTap: () => context.push('/artisan/build/${c.id}'),
            ),
          if (server == null) const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
          for (final p in server ?? const <Map>[])
            _row(
              context,
              title: p['title'] ?? p['transcript'] ?? '',
              status: p['status'],
              price: p['price'],
              image: ((p['media'] as List).cast<Map>().where((m) => m['kind'] == 'thumb').firstOrNull ??
                  (p['media'] as List).cast<Map>().where((m) => m['kind'] == 'original').firstOrNull)?['url'],
              onTap: () => context.push('/artisan/review/${p['id']}'),
            ),
          if (local.isEmpty && (server?.isEmpty ?? false))
            Padding(padding: const EdgeInsets.all(32), child: Text(l.noProducts, textAlign: TextAlign.center)),
        ]),
      ),
    );
  }

  Widget _row(BuildContext context,
          {required String title, required String status, num? price, String? image, VoidCallback? onTap}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: SS.white,
          borderRadius: BorderRadius.circular(SS.radius),
          child: InkWell(
            borderRadius: BorderRadius.circular(SS.radius),
            onTap: onTap,
            onLongPress: () => context.voice.speak('$title. ${statusLabel(context.l, status)}'),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(children: [
                SizedBox(width: 72, height: 72, child: CraftImage(image, radius: 14)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Row(children: [
                      StatusChip(status: status, label: statusLabel(context.l, status)),
                      const Spacer(),
                      if (price != null) Text(rupees(price), style: TextStyle(color: SS.maroon, fontWeight: FontWeight.w700)),
                    ]),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      );
}
