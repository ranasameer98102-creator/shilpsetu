import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shilpsetu_admin/pages.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

void main() {
  testWidgets('overview shows collective analytics from the API', (t) async {
    t.view.physicalSize = const Size(2400, 2000);
    t.view.devicePixelRatio = 1.5;
    addTearDown(t.view.reset);
    final client = MockClient((req) async => http.Response(
        jsonEncode({
          'artisans_onboarded': 10, 'women_pct': 70.0, 'verified_artisans': 8, 'listings_live': 26, 'orders': 10,
          'orders_via_ondc': 1, 'gmv': 71300, 'avg_artisan_share_pct': 86.4,
          'top_crafts': [{'category': 'Pottery & Ceramics', 'listings': 10, 'gmv': 7000}],
          'state_heatmap': [{'state': 'Rajasthan', 'artisans': 4, 'women': 3, 'clusters': ['Jaipur Blue Pottery Cluster'], 'gmv': 12000}],
          'offline_sync_health': {'captured_offline': 10, 'median_hours_offline_before_sync': 2.0, 'median_minutes_capture_to_live': 14, 'sync_jobs': {'done': 30}},
          'listings_by_status': {'live': 26}, 'captured_via': {'app': 20, 'kiosk': 10},
        }),
        200,
        headers: {'content-type': 'application/json'}));
    final api = ApiClient(baseUrl: 'http://x', client: client);
    await t.pumpWidget(MaterialApp(theme: SS.theme(), home: Scaffold(body: OverviewPage(api: api))));
    await t.pumpAndSettle();
    expect(find.text('Collective analytics'), findsOneWidget);
    expect(find.text('70.0%'), findsOneWidget);
    expect(find.text('86.4%'), findsOneWidget);
    expect(find.text('₹71,300'), findsOneWidget);
    expect(find.text('Pottery & Ceramics'), findsOneWidget);
    expect(find.text('Rajasthan'), findsOneWidget);
  });
}
