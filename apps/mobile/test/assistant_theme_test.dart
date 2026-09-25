import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';
import 'package:shilpsetu_mobile/ui/assistant/greeting_card.dart';
import 'package:shilpsetu_mobile/ui/assistant/mascot.dart';
import 'package:shilpsetu_mobile/ui/buyer/product_screen.dart';

import 'mockup_screens_test.dart' show FakeVoice, demoVase, host, vertical;

void main() {
  tearDown(() => SS.dark = false);

  testWidgets('Artisan greeting shows Shilpi, the streak, the daily goal and badges', (tester) async {
    await tester.pumpWidget(host(Scaffold(
      body: GreetingCard(data: {
        'mood': 'cheer',
        'message': 'Goal done for today, Meena!',
        'streak': 6,
        'goal': {'done': 1, 'target': 1},
        'badges': [
          {'key': 'first_listing', 'icon': 'rocket_launch', 'label': 'First listing', 'earned': true},
          {'key': 'streak_7', 'icon': 'local_fire_department', 'label': '7-day streak', 'earned': false},
        ],
      }),
    )));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(Mascot), findsOneWidget);
    expect(find.text('Goal done for today, Meena!'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('1 / 1'), findsOneWidget);
    expect(find.text('First listing'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget); // 7-day streak not earned yet
  });

  testWidgets('Buyer greeting shows the craft of the day', (tester) async {
    await tester.pumpWidget(host(Scaffold(
      body: GreetingCard(data: {
        'message': 'Good morning!',
        'craft_of_day': {'name': 'Warli', 'region': 'Palghar and Thane, Maharashtra', 'fact': 'Only three shapes are used.'},
      }),
    )));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Craft of the day'), findsOneWidget);
    expect(find.textContaining('Only three shapes'), findsOneWidget);
  });

  testWidgets('Product page tells the story of the art form and lists details', (tester) async {
    final p = {
      ...demoVase,
      'details': [
        {'key': 'technique', 'label': 'Technique', 'value': 'Blue Pottery, Hand-painted'},
        {'key': 'time', 'label': 'Time to make', 'value': '6 hours'},
      ],
      'craft': {
        'key': 'blue_pottery', 'name': 'Blue Pottery', 'region': 'Jaipur, Rajasthan', 'gi': 'Jaipur Blue Pottery',
        'history': 'A Turko-Persian art.', 'making': 'It uses no clay.', 'fact': 'Made without clay.',
      },
    };
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(ProductDetailView(product: p), voice: FakeVoice()));
    await tester.scrollUntilVisible(find.text('About this art form'), 300, scrollable: vertical);
    expect(find.text('Product details'), findsOneWidget);
    expect(find.text('Blue Pottery, Hand-painted'), findsOneWidget);
    expect(find.text('It uses no clay.'), findsOneWidget);
    expect(find.text('GI · Jaipur Blue Pottery'), findsOneWidget);
  });

  test('Dark palette swaps page, cards and text but keeps navy panels dark', () {
    SS.dark = false;
    final lightPage = SS.page, lightInk = SS.ink;
    SS.dark = true;
    expect(SS.page, isNot(lightPage));
    expect(SS.ink, isNot(lightInk));
    expect(SS.page.computeLuminance(), lessThan(0.05));
    expect(SS.ink.computeLuminance(), greaterThan(0.6));
    expect(SS.tealDeep.computeLuminance(), lessThan(0.05)); // text on it stays cream in both modes
    expect(SS.theme().brightness, Brightness.dark);
  });
}
