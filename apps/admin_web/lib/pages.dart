import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets.dart';

/// Loads one endpoint and rebuilds; every page is a thin view over the admin API.
abstract class ApiPage extends StatefulWidget {
  const ApiPage({super.key, required this.api});
  final ApiClient api;
}

abstract class ApiPageState<T extends ApiPage> extends State<T> {
  dynamic data;
  Object? error;
  String get endpoint;

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    try {
      final r = await widget.api.get(endpoint);
      if (mounted) setState(() => (data = r, error = null));
    } catch (e) {
      if (mounted) setState(() => error = e);
    }
  }

  Future<void> act(Future<dynamic> Function() fn, [String? done]) async {
    try {
      await fn();
      if (done != null && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done)));
      await reload();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Widget page(String title, List<Widget> children, {String? subtitle, List<Widget> actions = const []}) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                if (subtitle != null)
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SS.slate)),
              ],
            ),
          ),
          ...actions,
          IconButton(onPressed: reload, tooltip: 'Refresh', icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      const SizedBox(height: 18),
      if (error != null) Text('$error', style: TextStyle(color: SS.danger)),
      if (data == null && error == null) const Center(child: CircularProgressIndicator()),
      if (data != null) ...children,
    ],
  );

  Widget table(List<String> cols, List<List<Widget>> rows) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      headingTextStyle: TextStyle(fontWeight: FontWeight.w600, color: SS.heading, fontFamily: SS.poppins),
      columns: [for (final c in cols) DataColumn(label: Text(c))],
      rows: [
        for (final r in rows) DataRow(cells: [for (final w in r) DataCell(w)]),
      ],
    ),
  );
}

// ---------------------------------------------------------------- overview
class OverviewPage extends ApiPage {
  const OverviewPage({super.key, required super.api});
  @override
  State<OverviewPage> createState() => _OverviewState();
}

class _OverviewState extends ApiPageState<OverviewPage> {
  @override
  String get endpoint => '/admin/analytics';

  @override
  Widget build(BuildContext context) {
    final d = (data ?? {}) as Map;
    final heat = (d['state_heatmap'] as List? ?? []).cast<Map>();
    final crafts = (d['top_crafts'] as List? ?? []).cast<Map>();
    final health = (d['offline_sync_health'] ?? {}) as Map;
    return page(
      'Collective analytics',
      subtitle: 'Anonymised, aggregated — also available as CSV for government and bulk buyers',
      actions: [
        TextButton.icon(
          onPressed: () => launchUrl(Uri.parse('${widget.api.uri('/admin/analytics/export.csv')}')),
          icon: const Icon(Icons.download_rounded),
          label: const Text('CSV'),
        ),
      ],
      [
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            KpiTile(
              label: 'Artisans onboarded',
              value: '${d['artisans_onboarded'] ?? 0}',
              icon: Icons.groups_rounded,
              note: '${d['verified_artisans'] ?? 0} verified',
            ),
            KpiTile(
              label: 'Women artisans',
              value: '${d['women_pct'] ?? '—'}%',
              icon: Icons.woman_rounded,
              note: 'self-declared',
            ),
            KpiTile(label: 'Listings live', value: '${d['listings_live'] ?? 0}', icon: Icons.storefront_rounded),
            KpiTile(
              label: 'Orders',
              value: '${d['orders'] ?? 0}',
              icon: Icons.receipt_long_rounded,
              note: '${d['orders_via_ondc'] ?? 0} via ONDC',
            ),
            KpiTile(label: 'GMV', value: rupees(d['gmv'] ?? 0), icon: Icons.currency_rupee_rounded),
            KpiTile(
              label: 'Avg. artisan share of price',
              value: '${d['avg_artisan_share_pct'] ?? '—'}%',
              icon: Icons.handshake_rounded,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: [
            SizedBox(
              width: 560,
              child: Panel(
                title: 'Live listings by craft',
                child: BarList(rows: [for (final c in crafts) ('${c['category']}', c['listings'] as num)]),
              ),
            ),
            SizedBox(
              width: 560,
              child: Panel(
                title: 'Artisans by state',
                subtitle: 'Cluster heatmap — hover a bar for clusters, GMV and women artisans',
                child: BarList(
                  color: SS.ochre,
                  rows: [for (final s in heat) ('${s['state']}', s['artisans'] as num)],
                  tooltips: [
                    for (final s in heat)
                      'Clusters: ${(s['clusters'] as List).join(', ')}\nGMV ${rupees(s['gmv'])} · women ${s['women']}',
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 560,
              child: Panel(
                title: 'Offline-sync health',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    KpiTile(label: 'Captured offline', value: '${health['captured_offline'] ?? 0}'),
                    KpiTile(
                      label: 'Median hours offline before sync',
                      value: '${health['median_hours_offline_before_sync'] ?? '—'}',
                    ),
                    KpiTile(
                      label: 'Median minutes capture → live',
                      value: '${health['median_minutes_capture_to_live'] ?? '—'}',
                    ),
                    for (final e in ((health['sync_jobs'] ?? {}) as Map).entries)
                      Row(mainAxisSize: MainAxisSize.min, children: [StatusBadge(e.key), Text('  ${e.value}')]),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 560,
              child: Panel(
                title: 'Listings by status & capture channel',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 18,
                      runSpacing: 8,
                      children: [
                        for (final e in ((d['listings_by_status'] ?? {}) as Map).entries)
                          Row(mainAxisSize: MainAxisSize.min, children: [StatusBadge(e.key), Text('  ${e.value}')]),
                      ],
                    ),
                    const SizedBox(height: 10),
                    BarList(
                      rows: [
                        for (final e in ((d['captured_via'] ?? {}) as Map).entries)
                          (e.key == 'kiosk' ? 'Assisted kiosk' : 'Artisan app', e.value as num),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- impact
class ImpactPage extends ApiPage {
  const ImpactPage({super.key, required super.api});
  @override
  State<ImpactPage> createState() => _ImpactState();
}

class _ImpactState extends ApiPageState<ImpactPage> {
  @override
  String get endpoint => '/admin/impact';

  @override
  Widget build(BuildContext context) {
    final m = ((data ?? {})['market'] ?? {}) as Map;
    final p = ((data ?? {})['platform'] ?? {}) as Map;
    return page('Impact & market opportunity', [
      Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          KpiTile(
            label: 'Handicraft export growth',
            value: '${m['export_growth_pct']}%',
            note: '${m['export_growth_period']}',
          ),
          KpiTile(label: 'Handicraft exports', value: '₹${m['export_value_cr']} Cr', note: '${m['export_value_year']}'),
          KpiTile(
            label: 'Women artisans',
            value: '${m['women_artisans_pct']}%',
            note: '${m['women_handloom_weavers_pct']}% among handloom weavers',
          ),
          KpiTile(
            label: 'Handloom weavers earning < ₹5,000/month',
            value: '${m['weavers_under_5000_pct']}%',
            note: 'All-India Handloom Census 2019-20',
          ),
        ],
      ),
      const SizedBox(height: 16),
      Panel(
        title: 'Why now',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${m['policy']}', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text('“${m['framing']}”', style: SS.story(18)),
            const SizedBox(height: 8),
            Text('Sources: ${(m['sources'] as List? ?? []).join(' · ')}', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Panel(
        title: 'On ShilpSetu so far',
        child: Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            KpiTile(label: 'Artisans', value: '${p['artisans_onboarded']}'),
            KpiTile(label: 'Women', value: '${p['women_pct']}%'),
            KpiTile(label: 'Listings live', value: '${p['listings_live']}'),
            KpiTile(label: 'GMV', value: rupees(p['gmv'] ?? 0)),
            KpiTile(
              label: 'Artisan share of final price',
              value: '${p['avg_artisan_share_pct']}%',
              note: 'vs. middleman-led channels',
            ),
          ],
        ),
      ),
    ]);
  }
}

// ---------------------------------------------------------------- verification
class VerificationPage extends ApiPage {
  const VerificationPage({super.key, required super.api});
  @override
  State<VerificationPage> createState() => _VerificationState();
}

class _VerificationState extends ApiPageState<VerificationPage> {
  @override
  String get endpoint => '/admin/verification-queue';

  @override
  Widget build(BuildContext context) {
    final rows = ((data ?? []) as List).cast<Map>();
    return page('Artisan verification queue', subtitle: 'Pehchan ID check, documents, kiosk-operator attestation', [
      if (rows.isEmpty) const Text('Nothing waiting.'),
      for (final a in rows)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Panel(
            title: '${a['name']}${a['name_native'] != null ? '  ·  ${a['name_native']}' : ''}',
            subtitle:
                '${a['craft_type'] ?? ''} · ${a['village'] ?? ''}, ${a['state'] ?? ''} · cluster ${a['cluster'] ?? '—'}',
            action: Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => act(
                    () => widget.api.post('/admin/artisans/${a['id']}/verify', {'status': 'rejected'}),
                    'Rejected',
                  ),
                  child: const Text('Reject'),
                ),
                FilledButton(
                  onPressed: () => act(
                    () => widget.api.post('/admin/artisans/${a['id']}/verify', {
                      'status': 'verified',
                      'pehchan_verified': a['pehchan_id'] != null,
                    }),
                    'Verified',
                  ),
                  style: FilledButton.styleFrom(backgroundColor: SS.verifiedGreen),
                  child: const Text('Verify'),
                ),
              ],
            ),
            child: Wrap(
              spacing: 24,
              runSpacing: 6,
              children: [
                Text('Pehchan ID: ${a['pehchan_id'] ?? 'not linked'}'),
                Text(
                  'Consent: ${(a['consent_flags'] as Map?)?.entries.where((e) => e.value == true).map((e) => e.key).join(', ') ?? '—'}',
                ),
                if (a['operator'] != null)
                  Text(
                    'Onboarded by ${a['operator']['name']} (${a['operator']['csc_id'] ?? ''}) — “${a['operator']['attestation']}”',
                  ),
              ],
            ),
          ),
        ),
    ]);
  }
}

// ---------------------------------------------------------------- listings
class ListingsPage extends ApiPage {
  const ListingsPage({super.key, required super.api});
  @override
  State<ListingsPage> createState() => _ListingsState();
}

class _ListingsState extends ApiPageState<ListingsPage> {
  @override
  String get endpoint => '/admin/listings';

  Future<void> _revoke(Map p) async {
    final reason = TextEditingController(text: 'Provenance could not be confirmed');
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Revoke certificate'),
        content: TextField(
          controller: reason,
          decoration: const InputDecoration(labelText: 'Reason'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Revoke')),
        ],
      ),
    );
    if (ok != true) return;
    await act(
      () => widget.api.post('/admin/certificates/${p['certificate_id']}/revoke', {'reason': reason.text}),
      'Revoked',
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = ((data ?? []) as List).cast<Map>();
    return page('Listing moderation', subtitle: 'Flag, unpublish or republish listings; revoke certificates', [
      table(
        ['', 'Title', 'Artisan', 'Price', 'Status', 'Review flags', 'ONDC', 'Certificate', 'Actions'],
        [
          for (final p in rows)
            [
              SizedBox(width: 44, height: 44, child: CraftImage(p['thumb'], radius: 8)),
              SizedBox(width: 220, child: Text('${p['title']}', overflow: TextOverflow.ellipsis)),
              Text('${p['artisan_name']}'),
              Text(rupees(p['price'])),
              StatusBadge(p['status']),
              Text((p['needs_review_fields'] as List).join(', ')),
              StatusBadge(p['ondc_status']),
              p['certificate_id'] == null
                  ? const Text('—')
                  : StatusBadge(p['certificate_revoked'] == true ? 'revoked' : 'verified'),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (p['status'] == 'live')
                    TextButton(
                      onPressed: () => act(
                        () => widget.api.post('/admin/listings/${p['id']}/moderate', {
                          'action': 'unpublish',
                          'reason': 'moderation',
                        }),
                      ),
                      child: const Text('Unpublish'),
                    )
                  else if (p['status'] == 'unpublished')
                    TextButton(
                      onPressed: () =>
                          act(() => widget.api.post('/admin/listings/${p['id']}/moderate', {'action': 'republish'})),
                      child: const Text('Republish'),
                    ),
                  TextButton(
                    onPressed: () => act(
                      () => widget.api.post('/admin/listings/${p['id']}/moderate', {
                        'action': 'flag',
                        'reason': 'check photo',
                      }),
                      'Flagged',
                    ),
                    child: const Text('Flag'),
                  ),
                  if (p['certificate_id'] != null && p['certificate_revoked'] != true)
                    TextButton(
                      onPressed: () => _revoke(p),
                      child: Text('Revoke', style: TextStyle(color: SS.danger)),
                    ),
                ],
              ),
            ],
        ],
      ),
    ]);
  }
}

// ---------------------------------------------------------------- ONDC
class OndcPage extends ApiPage {
  const OndcPage({super.key, required super.api});
  @override
  State<OndcPage> createState() => _OndcState();
}

class _OndcState extends ApiPageState<OndcPage> {
  @override
  String get endpoint => '/admin/ondc';

  @override
  Widget build(BuildContext context) {
    final d = (data ?? {}) as Map;
    final rows = (d['listings'] as List? ?? []).cast<Map>();
    final log = (d['network_log'] as List? ?? []).cast<Map>();
    return page(
      'ONDC distribution',
      subtitle: 'Mode: ${d['mode']} · ${d['indexed_on_network'] ?? 0} items seen by the gateway',
      actions: [
        TextButton.icon(
          onPressed: () => launchUrl(Uri.parse(widget.api.absolute('/ondc-mock/buyer'))),
          icon: const Icon(Icons.open_in_new_rounded),
          label: const Text('Mock buyer app'),
        ),
        FilledButton.tonal(
          onPressed: () => act(() => widget.api.post('/admin/ondc/sync-all'), 'Synced'),
          child: const Text('Sync all'),
        ),
      ],
      [
        table(
          ['Listing', 'Status', 'Attempts', 'Last error', 'Updated', ''],
          [
            for (final r in rows)
              [
                SizedBox(width: 260, child: Text('${r['title']}', overflow: TextOverflow.ellipsis)),
                StatusBadge(r['status']),
                Text('${r['attempts']}'),
                SizedBox(width: 200, child: Text('${r['last_error'] ?? ''}', overflow: TextOverflow.ellipsis)),
                Text('${r['updated_at']}'.substring(0, 16)),
                TextButton(
                  onPressed: () => act(() => widget.api.post('/admin/ondc/${r['product_id']}/retry'), 'Retried'),
                  child: const Text('Retry'),
                ),
              ],
          ],
        ),
        const SizedBox(height: 16),
        Panel(
          title: 'Beckn network log (mock gateway)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final e in log)
                Text(
                  '${'${e['at']}'.substring(11, 19)}   ${e['direction']}   ${e['action']}   ${e['transaction_id']}',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- notifications
class NotifyPage extends ApiPage {
  const NotifyPage({super.key, required super.api});
  @override
  State<NotifyPage> createState() => _NotifyState();
}

class _NotifyState extends ApiPageState<NotifyPage> {
  @override
  String get endpoint => '/admin/notifications';
  final phone = TextEditingController(text: '+919000000002');
  final digits = TextEditingController(text: '12');
  List<Map> transcript = [];
  List<Map> callbacks = [];

  @override
  Future<void> reload() async {
    await super.reload();
    try {
      final c = await widget.api.get('/admin/helpdesk');
      if (mounted) setState(() => callbacks = (c as List).cast<Map>());
    } catch (_) {}
  }

  Future<void> _simulate() async {
    final r = await widget.api.post('/notify/ivr/simulate', {'phone': phone.text, 'digits': digits.text});
    setState(() => transcript = (r['transcript'] as List).cast<Map>());
    await reload();
  }

  @override
  Widget build(BuildContext context) {
    final rows = ((data ?? []) as List).cast<Map>();
    return page(
      'SMS / IVR helpdesk',
      subtitle: 'Every message sent in the artisan\'s language (mock gateway logs here)',
      [
        Panel(
          title: 'IVR simulator',
          subtitle:
              'Press 1 Hindi · 2 English · 3 Bengali · 4 Marathi, then 1 latest orders · 2 earnings · 3 call back',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 220,
                    child: TextField(
                      controller: phone,
                      decoration: const InputDecoration(labelText: 'Caller'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: digits,
                      decoration: const InputDecoration(labelText: 'Keys'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _simulate,
                    icon: const Icon(Icons.phone_rounded),
                    label: const Text('Call'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (final t in transcript)
                Text(
                  '${t['pressed'] == null ? '☎' : '▶ ${t['pressed']}'}  [${t['language']}]  ${(t['prompts'] as List).join(' / ')}',
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (callbacks.isNotEmpty)
          Panel(
            title: 'Callback requests',
            child: table(
              ['When', 'Language', 'Reason', 'Status'],
              [
                for (final c in callbacks)
                  [
                    Text('${c['at']}'.substring(0, 16)),
                    Text('${c['language']}'),
                    Text('${c['reason']}'),
                    StatusBadge(c['status']),
                  ],
              ],
            ),
          ),
        const SizedBox(height: 16),
        table(
          ['When', 'Channel', 'Template', 'Lang', 'To', 'Message', 'Status'],
          [
            for (final n in rows)
              [
                Text('${n['at']}'.substring(5, 16)),
                Icon(
                  n['channel'] == 'sms' ? Icons.sms_outlined : Icons.phone_in_talk_outlined,
                  size: 18,
                  color: SS.heading,
                ),
                Text('${n['template']}'),
                Text('${n['language']}'),
                Text('${n['to'] ?? ''}'),
                SizedBox(width: 420, child: Text('${n['body']}', maxLines: 2, overflow: TextOverflow.ellipsis)),
                StatusBadge(n['status']),
              ],
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- operators
class OperatorsPage extends ApiPage {
  const OperatorsPage({super.key, required super.api});
  @override
  State<OperatorsPage> createState() => _OperatorsState();
}

class _OperatorsState extends ApiPageState<OperatorsPage> {
  @override
  String get endpoint => '/admin/operators';

  /// Operators cannot self-register; an admin registers each CSC / SHG helper by phone number.
  Future<void> _register() async {
    final phone = TextEditingController(),
        name = TextEditingController(),
        id = TextEditingController(),
        region = TextEditingController();
    var kind = 'csc';
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => AlertDialog(
          title: const Text('Register kiosk operator'),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: kind,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'csc', child: Text('Common Service Centre (CSC)')),
                    DropdownMenuItem(value: 'shg', child: Text('Self-Help Group (SHG)')),
                  ],
                  onChanged: (v) => set(() => kind = v!),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phone,
                  decoration: const InputDecoration(labelText: 'Mobile number'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: id,
                  decoration: InputDecoration(labelText: kind == 'csc' ? 'CSC ID' : 'SHG ID'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: region,
                  decoration: const InputDecoration(labelText: 'Region'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Register')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    await act(
      () => widget.api.post('/admin/operators', {
        'phone': phone.text,
        'name': name.text,
        'kind': kind,
        if (kind == 'csc') 'csc_id': id.text else 'shg_id': id.text,
        'region': region.text,
      }),
      'Operator registered — they can now sign in to kiosk mode',
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = ((data ?? []) as List).cast<Map>();
    return page(
      'Kiosk operators (CSC / SHG)',
      actions: [
        FilledButton.icon(
          onPressed: _register,
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Register operator'),
        ),
      ],
      [
        table(
          ['Operator', 'Type', 'ID', 'Region', 'Artisans onboarded', 'Products captured', 'Live'],
          [
            for (final o in rows)
              [
                Text('${o['name']}'),
                Text('${o['kind']}'.toUpperCase()),
                Text('${o['csc_id'] ?? o['shg_id'] ?? ''}'),
                Text('${o['region'] ?? ''}'),
                Text('${o['artisans_onboarded']}'),
                Text('${o['products_captured']}'),
                Text('${o['products_live']}'),
              ],
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- schemes
class SchemesPage extends ApiPage {
  const SchemesPage({super.key, required super.api});
  @override
  State<SchemesPage> createState() => _SchemesState();
}

class _SchemesState extends ApiPageState<SchemesPage> {
  @override
  String get endpoint => '/admin/schemes';
  String scheme = 'NHDP';
  final cluster = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final report = ((data ?? {})['report'] ?? {}) as Map;
    const names = {
      'NHDP': 'National Handloom Development Programme',
      'CHCDS': 'Comprehensive Handicrafts Cluster Development Scheme',
      'SFURTI': 'Scheme of Fund for Regeneration of Traditional Industries',
    };
    return page('Scheme tagging', subtitle: 'Link artisans / clusters to schemes for reporting', [
      Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          for (final e in report.entries)
            SizedBox(
              width: 330,
              child: Panel(
                title: e.key,
                subtitle: names[e.key],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${e.value['artisans']} artisans · GMV ${rupees(e.value['gmv'])}'),
                    Text(
                      'Clusters: ${(e.value['clusters'] as List).join(', ')}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 16),
      Panel(
        title: 'Tag a cluster',
        child: Row(
          children: [
            DropdownButton<String>(
              value: scheme,
              items: [for (final s in names.keys) DropdownMenuItem(value: s, child: Text(s))],
              onChanged: (v) => setState(() => scheme = v!),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 320,
              child: TextField(
                controller: cluster,
                decoration: const InputDecoration(labelText: 'Cluster name'),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: () =>
                  act(() => widget.api.post('/admin/schemes', {'scheme': scheme, 'cluster': cluster.text}), 'Linked'),
              child: const Text('Link'),
            ),
          ],
        ),
      ),
    ]);
  }
}

// ---------------------------------------------------------------- models
class ModelsPage extends ApiPage {
  const ModelsPage({super.key, required super.api});
  @override
  State<ModelsPage> createState() => _ModelsState();
}

class _ModelsState extends ApiPageState<ModelsPage> {
  @override
  String get endpoint => '/admin/models';

  @override
  Widget build(BuildContext context) {
    final rows = ((data ?? []) as List).cast<Map>();
    return page(
      'Learning loop',
      subtitle: 'Buyer views, carts, orders, returns and sale prices retrain the price and ranking models nightly',
      actions: [
        FilledButton.icon(
          onPressed: () => act(() => widget.api.post('/admin/models/retrain'), 'New model versions trained'),
          icon: const Icon(Icons.model_training_rounded),
          label: const Text('Retrain now'),
        ),
      ],
      [
        table(
          ['Version', 'Kind', 'Active', 'Trained on', 'Metrics', 'Quotes priced', 'Created'],
          [
            for (final m in rows)
              [
                Text('${m['id']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${m['kind']}'),
                m['active'] == true ? const StatusBadge('live') : const Text(''),
                Text(jsonEncode(m['trained_on'])),
                SizedBox(
                  width: 260,
                  child: Text(
                    m['kind'] == 'ranking' ? jsonEncode(m['params']?['coef'] ?? {}) : jsonEncode(m['metrics']),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text('${m['quotes_priced']}'),
                Text('${m['created_at']}'.substring(0, 16)),
              ],
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- settings
class SettingsPage extends ApiPage {
  const SettingsPage({super.key, required super.api});
  @override
  State<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends ApiPageState<SettingsPage> {
  @override
  String get endpoint => '/admin/settings';
  final commission = TextEditingController();
  final wageDefault = TextEditingController();
  final teamId = TextEditingController();
  Map<String, TextEditingController> wages = {};
  Map<String, String> providers = {};
  List<String> languages = [];

  @override
  Future<void> reload() async {
    await super.reload();
    final d = (data ?? {}) as Map;
    commission.text = '${d['commission_pct']}';
    wageDefault.text = '${d['fair_wage_default']}';
    teamId.text = '${d['team_id'] ?? ''}';
    wages = {
      for (final e in ((d['fair_wage_by_state'] ?? {}) as Map).entries)
        e.key as String: TextEditingController(text: '${e.value}'),
    };
    providers = {for (final e in ((d['providers'] ?? {}) as Map).entries) e.key as String: '${e.value}'};
    languages = ((d['supported_languages'] ?? []) as List).cast<String>();
    if (mounted) setState(() {});
  }

  static const options = {
    'asr': ['mock', 'bhashini', 'ai4bharat'],
    'nlu': ['mock', 'claude'],
    'translation': ['mock', 'bhashini', 'indictrans2'],
    'sms': ['mock', 'twilio', 'exotel'],
    'ivr': ['mock', 'twilio', 'exotel'],
    'payment': ['mock', 'razorpay'],
    'ondc': ['mock', 'sandbox', 'production'],
  };

  @override
  Widget build(BuildContext context) {
    return page(
      'Settings',
      actions: [
        FilledButton.icon(
          onPressed: () => act(
            () => widget.api.put('/admin/settings', {
              'commission_pct': double.tryParse(commission.text),
              'fair_wage_default': double.tryParse(wageDefault.text),
              'fair_wage_by_state': {for (final e in wages.entries) e.key: double.tryParse(e.value.text) ?? 0},
              'providers': providers,
              'supported_languages': languages,
              'team_id': teamId.text,
            }),
            'Saved',
          ),
          icon: const Icon(Icons.save_rounded),
          label: const Text('Save'),
        ),
      ],
      [
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: [
            SizedBox(
              width: 420,
              child: Panel(
                title: 'Commission & fair wage',
                subtitle: 'Commission is shown to every buyer and artisan. Wage floors are at or above state skilled minimum wage.',
                child: Column(
                  children: [
                    TextField(
                      controller: commission,
                      decoration: const InputDecoration(labelText: 'Platform commission %'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: wageDefault,
                      decoration: const InputDecoration(labelText: 'Default fair wage ₹/hour'),
                    ),
                    const SizedBox(height: 10),
                    for (final e in wages.entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(child: Text(e.key)),
                            SizedBox(
                              width: 110,
                              child: TextField(
                                controller: e.value,
                                decoration: const InputDecoration(isDense: true, suffixText: '₹/h'),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 420,
              child: Panel(
                title: 'AI & gateway providers',
                subtitle:
                    'Mock runs everything locally with no keys; switch to real adapters once keys are configured.',
                child: Column(
                  children: [
                    for (final e in options.entries)
                      Row(
                        children: [
                          Expanded(child: Text(e.key.toUpperCase())),
                          DropdownButton<String>(
                            value: e.value.contains(providers[e.key]) ? providers[e.key] : e.value.first,
                            items: [for (final o in e.value) DropdownMenuItem(value: o, child: Text(o))],
                            onChanged: (v) => setState(() => providers[e.key] = v!),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 420,
              child: Panel(
                title: 'Languages & identity',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final l in const [
                          'hi',
                          'en',
                          'bn',
                          'mr',
                          'te',
                          'ta',
                          'gu',
                          'ur',
                          'kn',
                          'or',
                          'ml',
                          'pa',
                          'as',
                          'sat',
                          'brx',
                          'doi',
                          'ks',
                          'kok',
                          'mai',
                          'mni',
                          'ne',
                          'sa',
                          'sd',
                        ])
                          FilterChip(
                            label: Text(l),
                            selected: languages.contains(l),
                            onSelected: (v) => setState(() => v ? languages.add(l) : languages.remove(l)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: teamId,
                      decoration: const InputDecoration(labelText: 'Team ID (shown on About screens)'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- audit
class AuditPage extends ApiPage {
  const AuditPage({super.key, required super.api});
  @override
  State<AuditPage> createState() => _AuditState();
}

class _AuditState extends ApiPageState<AuditPage> {
  @override
  String get endpoint => '/admin/audit';

  @override
  Widget build(BuildContext context) {
    final d = (data ?? {}) as Map;
    final rows = (d['entries'] as List? ?? []).cast<Map>();
    return page('Audit log', subtitle: 'Append-only; every row chains the SHA-256 of the previous one', [
      Row(
        children: [
          StatusBadge(d['chain_valid'] == true ? 'verified' : 'failed'),
          Text(d['chain_valid'] == true ? '  Hash chain intact' : '  Chain broken at row ${d['first_bad_row']}'),
        ],
      ),
      const SizedBox(height: 12),
      table(
        ['#', 'Time', 'Action', 'Entity', 'Actor', 'Data', 'Hash'],
        [
          for (final r in rows)
            [
              Text('${r['id']}'),
              Text('${r['ts']}'.substring(0, 19)),
              Text('${r['action']}'),
              Text('${r['entity']} ${'${r['entity_id']}'.substring(0, 8)}'),
              Text('${r['actor'] ?? ''}'.padRight(8).substring(0, 8)),
              SizedBox(width: 300, child: Text(jsonEncode(r['data']), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Text('${r['hash']}', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ],
        ],
      ),
    ]);
  }
}
