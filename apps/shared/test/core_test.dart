import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

void main() {
  test('rupees uses Indian digit grouping', () {
    expect(rupees(1450), '₹1,450');
    expect(rupees(2100), '₹2,100');
    expect(rupees(145000), '₹1,45,000');
    expect(rupees(12345678), '₹1,23,45,678');
    expect(rupees(999), '₹999');
  });

  test('api uri prefixes /api/v1 and keeps protocol paths', () {
    final api = ApiClient(baseUrl: 'http://x');
    expect(api.uri('/storefront/feed').toString(), 'http://x/api/v1/storefront/feed');
    expect(api.uri('/ondc/search').toString(), 'http://x/ondc/search');
    expect(api.uri('/storefront/search', {'q': 'vase', 'gi_only': true}).toString(),
        'http://x/api/v1/storefront/search?q=vase&gi_only=true');
  });

  testWidgets('price breakdown shows the artisan share', (t) async {
    await t.pumpWidget(MaterialApp(
      theme: SS.theme(),
      home: Scaffold(
        body: PriceBreakdown(initiallyExpanded: true, quote: const {
          'artisan_share_amount': 1217,
          'artisan_share_pct': 83.9,
          'breakdown': [
            {'key': 'materials', 'label': 'Materials', 'amount': 150, 'to_artisan': true},
            {'key': 'labour', 'label': 'Artisan labour (fair wage)', 'amount': 760, 'to_artisan': true},
            {'key': 'platform_fee', 'label': 'ShilpSetu platform fee', 'amount': 87, 'to_artisan': false},
          ],
        }),
      ),
    ));
    expect(find.textContaining('₹1,217'), findsWidgets);
    expect(find.text('Artisan labour (fair wage)'), findsOneWidget);
  });
}
