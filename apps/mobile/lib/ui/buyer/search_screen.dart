import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import '../../core/session.dart';
import '../widgets.dart';

/// Search with filters (category, price range, state, verified only, GI only) and sort (ranking/price/newest).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.query, this.category, this.state, this.sort});
  final String? query;
  final String? category;
  final String? state;
  final String? sort; // relevance | price_asc | price_desc | newest

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final _q = TextEditingController(text: widget.query ?? '');
  late String? category = widget.category;
  late String? state = widget.state;
  RangeValues? price;
  bool verified = false, gi = false, womenLed = false;
  late String sort = widget.sort ?? 'relevance';
  Map<String, dynamic>? filters;
  Map<String, dynamic>? results;

  @override
  void initState() {
    super.initState();
    _loadFilters();
    _search();
  }

  Future<void> _loadFilters() async {
    try {
      final f = await context.read<Session>().api.get('/storefront/filters');
      if (mounted) setState(() => filters = Map<String, dynamic>.from(f));
    } catch (_) {}
  }

  Future<void> _search() async {
    final s = context.read<Session>();
    try {
      final r = await s.api.get('/storefront/search', {
        'q': _q.text.trim().isEmpty ? null : _q.text.trim(),
        'category': category,
        'state': state,
        'min_price': price?.start.round(),
        'max_price': price?.end.round(),
        'verified_only': verified,
        'gi_only': gi,
        'women_led': womenLed,
        'sort': sort,
        'lang': s.language,
      });
      if (mounted) setState(() => results = Map<String, dynamic>.from(r));
    } catch (e) {
      if (mounted) spokenError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final items = (results?['items'] as List? ?? []).cast<Map>();
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _q,
          style: TextStyle(color: SS.ink),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          decoration: InputDecoration(
            hintText: l.searchHint,
            isDense: true,
            suffixIcon: IconButton(
              icon: Icon(Icons.mic_rounded, color: SS.maroon),
              onPressed: () => context.voice.listen(onFinal: (t) {
                _q.text = t;
                _search();
              }),
            ),
          ),
        ),
        actions: [IconButton(onPressed: _sheet, tooltip: l.filters, icon: const Icon(Icons.tune_rounded))],
      ),
      body: Column(children: [
        SizedBox(
          height: 56,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), children: [
            FilterChip(label: Text(l.verifiedOnly), selected: verified, onSelected: (v) => setState(() => (verified = v, _search()))),
            const SizedBox(width: 8),
            FilterChip(label: Text(l.giOnly), selected: gi, onSelected: (v) => setState(() => (gi = v, _search()))),
            const SizedBox(width: 8),
            FilterChip(label: Text(l.womenLed), selected: womenLed, onSelected: (v) => setState(() => (womenLed = v, _search()))),
            if (category != null) ...[
              const SizedBox(width: 8),
              InputChip(label: Text(category!), onDeleted: () => setState(() => (category = null, _search()))),
            ],
            if (state != null) ...[
              const SizedBox(width: 8),
              InputChip(label: Text(state!), onDeleted: () => setState(() => (state = null, _search()))),
            ],
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(child: Text(results == null ? '' : l.results(results!['total'] as int), style: Theme.of(context).textTheme.bodySmall)),
            DropdownButton<String>(
              value: sort,
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(value: 'relevance', child: Text(l.sortRelevance)),
                DropdownMenuItem(value: 'price_asc', child: Text(l.sortPriceLow)),
                DropdownMenuItem(value: 'price_desc', child: Text(l.sortPriceHigh)),
                DropdownMenuItem(value: 'newest', child: Text(l.sortNewest)),
              ],
              onChanged: (v) => setState(() => (sort = v!, _search())),
            ),
          ]),
        ),
        Expanded(
          child: results == null
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 240, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.58),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final p = Map<String, dynamic>.from(items[i]);
                    return ProductCard(product: p, verifiedLabel: l.verifiedArtisan, onTap: () => context.push('/store/p/${p['id']}'));
                  },
                ),
        ),
      ]),
    );
  }

  void _sheet() {
    final l = context.l;
    final f = filters ?? {};
    final range = (f['price_range'] as List?)?.cast<num>() ?? [0, 20000];
    var local = price ?? RangeValues(range[0].toDouble(), range[1].toDouble() <= range[0] ? range[0] + 1 : range[1].toDouble());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.filters, style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text('${rupees(local.start)} – ${rupees(local.end)}'),
              RangeSlider(
                values: local,
                min: range[0].toDouble(),
                max: range[1].toDouble() <= range[0] ? range[0] + 1 : range[1].toDouble(),
                onChanged: (v) => set(() => local = v),
              ),
              DropdownButtonFormField<String?>(
                initialValue: category,
                decoration: InputDecoration(labelText: l.category),
                items: [
                  const DropdownMenuItem(value: null, child: Text('—')),
                  for (final c in (f['categories'] as List? ?? []).cast<String>()) DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => category = v,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: state,
                decoration: InputDecoration(labelText: l.state),
                items: [
                  const DropdownMenuItem(value: null, child: Text('—')),
                  for (final s in (f['states'] as List? ?? []).cast<String>()) DropdownMenuItem(value: s, child: Text(s)),
                ],
                onChanged: (v) => state = v,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() => price = local);
                    _search();
                  },
                  child: Text(l.done),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
