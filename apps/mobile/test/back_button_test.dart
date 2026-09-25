import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';
import 'package:shilpsetu_mobile/app.dart';
import 'package:shilpsetu_mobile/core/session.dart';
import 'package:shilpsetu_mobile/core/voice.dart';
import 'package:shilpsetu_mobile/ui/about_screen.dart';
import 'package:shilpsetu_mobile/ui/buyer/search_screen.dart';
import 'package:shilpsetu_mobile/ui/buyer/store_home.dart';

import 'mockup_screens_test.dart' show FakeVoice;

void main() {
  testWidgets('Android back goes to the previous page; home needs a second press to exit', (tester) async {
    ShilpSetuApp.showSplash = false;
    SharedPreferences.setMockInitialValues({'role': 'buyer', 'language': 'en', 'theme': 'light'});
    final prefs = await SharedPreferences.getInstance();
    final offline = MockClient((_) async => http.Response('{"detail":"offline"}', 503));
    final session = Session(prefs, api: ApiClient(baseUrl: 'http://test', client: offline));
    var exited = 0;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'SystemNavigator.pop') exited++;
      return null;
    });

    await tester.pumpWidget(MultiProvider(providers: [
      ChangeNotifierProvider.value(value: session),
      ChangeNotifierProvider<Voice>.value(value: FakeVoice()),
    ], child: const ShilpSetuApp()));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(StoreHomeView), findsOneWidget);

    // Screens opened with go() replace the stack; back must still return to the page the user came from.
    final router = GoRouter.of(tester.element(find.byType(StoreHomeView)));
    router.go('/store/search?q=warli');
    await tester.pump(const Duration(seconds: 1));
    router.go('/language'); // a setup page: never returned to with back
    await tester.pump(const Duration(seconds: 1));
    router.go('/about');
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(AboutScreen), findsOneWidget);

    await tester.binding.handlePopRoute(); // back -> previous page (search), skipping the language page
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(SearchScreen), findsOneWidget);
    expect(exited, 0);

    await tester.binding.handlePopRoute(); // back -> store
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(StoreHomeView), findsOneWidget);
    expect(exited, 0);

    // A page pushed on top pops normally.
    router.push('/about');
    await tester.pump(const Duration(seconds: 1));
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(StoreHomeView), findsOneWidget);

    await tester.binding.handlePopRoute(); // back on home -> hint only
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Press back again to exit'), findsOneWidget);
    expect(exited, 0);

    await tester.binding.handlePopRoute(); // second press within 2 s -> exit
    await tester.pump();
    expect(exited, 1);
    await tester.pump(const Duration(seconds: 3));
  });
}
