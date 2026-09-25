import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';
import 'package:shilpsetu_mobile/core/voice.dart';
import 'package:shilpsetu_mobile/l10n/app_localizations.dart';
import 'package:shilpsetu_mobile/ui/artisan/capture_view.dart';
import 'package:shilpsetu_mobile/ui/buyer/product_screen.dart';
import 'package:shilpsetu_mobile/ui/buyer/store_home.dart';

/// Records what would be spoken instead of calling the platform TTS.
class FakeVoice extends Voice {
  final spoken = <String>[];
  @override
  Future<void> speak(String text, {String? lang}) async => spoken.add(text);
}

final vertical = find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).first;

Widget host(Widget child, {Locale locale = const Locale('en'), FakeVoice? voice}) => ChangeNotifierProvider<Voice>.value(
      value: voice ?? FakeVoice(),
      child: MaterialApp(
        theme: SS.theme(),
        locale: locale,
        supportedLocales: L10n.supportedLocales,
        localizationsDelegates: L10n.localizationsDelegates,
        home: child,
      ),
    );

Map<String, dynamic> card(String id, String title, num price, {bool verified = true}) => {
      'id': id, 'title': title, 'price': price, 'thumb': null, 'verified': verified,
      'location': 'Jaipur, Rajasthan', 'category': 'Pottery & Ceramics',
    };

/// Exactly the demo product from the proposal mockup.
final demoVase = <String, dynamic>{
  'id': 'p1',
  'status': 'live',
  'title': 'Hand-painted Pottery Vase',
  'location': 'Jaipur, Rajasthan • GI-linked cluster',
  'price': 1450,
  'compare_at_price': 2100,
  'rating_avg': 5.0,
  'rating_count': 128,
  'description': 'This hand-painted blue pottery vase was made by hand by Meena Devi in Sanganer, Rajasthan.',
  'media': [],
  'certificate': {'id': 'c1', 'qr_url': 'http://localhost:8000/v/c1?s=abc', 'issued_at': '2026-09-01', 'revoked': false},
  'price_quote': {
    'final_price': 1450,
    'artisan_share_amount': 1215,
    'artisan_share_pct': 83.8,
    'breakdown': [
      {'key': 'materials', 'label': 'Materials', 'label_hi': 'सामग्री', 'amount': 150, 'to_artisan': true},
      {'key': 'labour', 'label': 'Artisan labour (fair wage)', 'label_hi': 'मेहनत', 'amount': 760, 'to_artisan': true},
      {'key': 'overheads', 'label': 'Tools, electricity & packaging', 'label_hi': 'औज़ार', 'amount': 109, 'to_artisan': true},
      {'key': 'craft_premium', 'label': 'Craft skill & GI premium', 'label_hi': 'प्रीमियम', 'amount': 234, 'to_artisan': true},
      {'key': 'platform_fee', 'label': 'ShilpSetu platform fee', 'label_hi': 'शुल्क', 'amount': 87, 'to_artisan': false},
      {'key': 'logistics', 'label': 'Shipping & packing', 'label_hi': 'डिलीवरी', 'amount': 110, 'to_artisan': false},
    ],
  },
  'artisan': {
    'name': 'Meena Devi', 'name_native': 'मीना देवी', 'verified': true, 'craft_type': 'Blue pottery', 'years_practice': 18,
    'story_text': 'मैं अठारह साल से नीली पॉटरी बना रही हूँ।', 'story_translations': {}, 'photo_url': null,
    'story_audio_url': 'http://localhost:8000/media/story.wav',
  },
  'more_from_artisan': [],
};

void main() {
  testWidgets('Mockup 1 — storefront home', (t) async {
    t.view.physicalSize = const Size(1080, 2400);
    t.view.devicePixelRatio = 2.6;
    addTearDown(t.view.reset);
    await t.pumpWidget(host(StoreHomeView(feed: {
      'sections': [
        {'key': 'fresh', 'title': 'Fresh', 'items': [card('p1', 'Hand-painted Pottery Vase', 1450), card('p2', 'Handloom Red Saree', 11450, verified: false)]},
        {'key': 'women_led', 'title': 'Women', 'items': [card('p3', 'Kantha Stitch Stole', 3900)]},
        {'key': 'gi', 'title': 'GI', 'items': [card('p4', 'Dhokra Horse Figurine', 9250)]},
      ],
      'categories': [{'name': 'Pottery & Ceramics', 'count': 12}],
      'clusters': [{'state': 'Rajasthan', 'cluster': 'Jaipur Blue Pottery Cluster', 'count': 12}],
    })));
    await t.pumpAndSettle();

    expect(find.text('ShilpSetu'), findsOneWidget); // marigold wordmark in the teal bar
    final wordmark = t.widget<Text>(find.text('ShilpSetu'));
    expect(wordmark.style?.color, SS.marigold);
    expect(find.text('Fresh from the loom & wheel'), findsOneWidget);
    expect(find.text('Search crafts, states, artisans'), findsOneWidget);
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget); // voice search
    expect(find.text('Hand-painted Pottery Vase'), findsOneWidget);
    expect(find.text('₹1,450'), findsOneWidget); // maroon price pill
    expect(find.byType(ProductCard), findsWidgets);
    expect(find.byIcon(Icons.verified_rounded), findsWidgets);
    final appBar = t.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, SS.teal);
    await t.scrollUntilVisible(find.text('Women-led collectives'), 300, scrollable: vertical);
    expect(find.text('Women-led collectives'), findsOneWidget);
    await t.scrollUntilVisible(find.text('GI-tagged crafts'), 300, scrollable: vertical);
    expect(find.text('GI-tagged crafts'), findsOneWidget);
  });

  testWidgets('Mockup 2 — Add a Product (voice + photo capture)', (t) async {
    t.view.physicalSize = const Size(1080, 2400);
    t.view.devicePixelRatio = 2.6;
    addTearDown(t.view.reset);
    var tapped = 0;
    await t.pumpWidget(host(CaptureView(
      listening: true,
      languageName: 'Hindi',
      transcript: 'Blue pottery vase, hand-painted',
      levels: List.generate(28, (i) => (i % 7) / 7 + 0.1),
      photos: [Uint8List.fromList(_png)],
      onMicTap: () => tapped++,
    )));
    await t.pump(const Duration(milliseconds: 300));

    final scaffold = t.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, SS.tealDeep);
    expect(find.text('Add a Product'), findsOneWidget);
    expect(find.text('Speak in your own language'), findsOneWidget);
    expect(find.text('Listening in Hindi…'), findsOneWidget);
    expect(find.text('Blue pottery vase, hand-painted'), findsOneWidget);
    expect(find.text('Photo captured — enhancing background & light automatically'), findsOneWidget);
    expect(find.byIcon(Icons.stop_rounded), findsOneWidget); // recording state on the maroon mic
    await t.tap(find.byIcon(Icons.stop_rounded));
    expect(tapped, 1);

    // idle state: mic glyph, and the listing button enabled because a photo exists
    await t.pumpWidget(host(CaptureView(
        listening: false, languageName: 'Hindi', transcript: '', levels: List.filled(28, 0.1), photos: const [])));
    await t.pump();
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    expect(find.text('Take a photo'), findsOneWidget);
  });

  testWidgets('Mockup 3 — product detail with fair price and certificate', (t) async {
    t.view.physicalSize = const Size(1080, 2400);
    t.view.devicePixelRatio = 2.6;
    addTearDown(t.view.reset);
    var added = false;
    var certOpened = false;
    await t.pumpWidget(host(ProductDetailView(
      product: demoVase,
      onAddToCart: () => added = true,
      onOpenCertificate: () => certOpened = true,
    )));
    await t.pumpAndSettle();

    expect(find.text('Verified Artisan'), findsOneWidget); // badge on the hero image
    expect(find.text('Hand-painted Pottery Vase'), findsOneWidget);
    expect(find.text('Jaipur, Rajasthan • GI-linked cluster'), findsOneWidget);
    final price = t.widget<Text>(find.text('₹1,450'));
    expect(price.style?.color, SS.maroon);
    final struck = t.widget<Text>(find.text('₹2,100'));
    expect(struck.style?.decoration, TextDecoration.lineThrough);
    expect(find.text('(128 reviews)'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
    expect(find.text('Scan for Artisan Provenance Certificate'), findsOneWidget);
    expect(find.text('Materials, story & fair-price basis'), findsOneWidget);
    expect(find.text('How this price is built'), findsOneWidget);
    expect(find.textContaining('₹1,215 of this goes directly to the artisan'), findsWidgets);

    await t.tap(find.text('Scan for Artisan Provenance Certificate'));
    expect(certOpened, isTrue);
    await t.tap(find.text('Add to Cart'));
    expect(added, isTrue);

    await t.scrollUntilVisible(find.text('Hear their voice'), 300, scrollable: vertical);
    expect(find.text('Meet the artisan'), findsOneWidget);
    expect(find.text('Meena Devi'), findsOneWidget);
    expect(find.text('Hear their voice'), findsOneWidget);
  });

  testWidgets('UI is translated: Add Product screen in Hindi and Bengali', (t) async {
    await t.pumpWidget(host(
        CaptureView(listening: false, languageName: 'हिन्दी', transcript: '', levels: List.filled(28, 0.1), photos: const []),
        locale: const Locale('hi')));
    await t.pump();
    expect(find.text('उत्पाद जोड़ें'), findsOneWidget);
    await t.pumpWidget(host(
        CaptureView(listening: false, languageName: 'বাংলা', transcript: '', levels: List.filled(28, 0.1), photos: const []),
        locale: const Locale('bn')));
    await t.pump();
    expect(find.text('পণ্য যোগ করুন'), findsOneWidget);
  });
}

// 1x1 transparent PNG
const _png = [
  137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0,
  0, 0, 13, 73, 68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130,
];
