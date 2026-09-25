import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import 'core/languages.dart';
import 'core/session.dart';
import 'core/voice.dart';
import 'l10n/app_localizations.dart';
import 'ui/about_screen.dart';
import 'ui/artisan/build_screen.dart';
import 'ui/artisan/capture_screen.dart';
import 'ui/artisan/earnings_screen.dart';
import 'ui/artisan/help_screen.dart';
import 'ui/artisan/home_screen.dart';
import 'ui/artisan/orders_screen.dart';
import 'ui/artisan/products_screen.dart';
import 'ui/artisan/review_screen.dart';
import 'ui/buyer/cart_screen.dart';
import 'ui/buyer/certificate_screen.dart';
import 'ui/buyer/orders_screen.dart';
import 'ui/buyer/product_screen.dart';
import 'ui/buyer/scan_screen.dart';
import 'ui/buyer/search_screen.dart';
import 'ui/buyer/store_home.dart';
import 'ui/kiosk/kiosk_home.dart';
import 'ui/kiosk/onboard_screen.dart';
import 'ui/start/consent_screen.dart';
import 'ui/start/language_screen.dart';
import 'ui/start/login_screen.dart';
import 'ui/start/voice_profile_screen.dart';
import 'ui/splash.dart';
import 'ui/start/welcome_screen.dart';

GoRouter buildRouter(Session session) => GoRouter(
      refreshListenable: session,
      initialLocation: '/',
      redirect: (context, state) {
        final loc = state.matchedLocation;
        const open = {'/welcome', '/language', '/login', '/about'};
        if (open.contains(loc) || loc.startsWith('/store')) return null;
        if (loc == '/') {
          if (session.role == null) return '/welcome';
          if (session.role == 'buyer') return '/store';
          if (!session.signedIn) return '/login';
          if (session.role == 'operator') return '/kiosk';
          return session.hasProfile ? '/artisan' : '/consent';
        }
        if (!session.signedIn) return '/login?next=${Uri.encodeComponent(state.uri.toString())}';
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
        GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
        GoRoute(path: '/language', builder: (_, s) => LanguageScreen(next: s.uri.queryParameters['next'])),
        GoRoute(path: '/login', builder: (_, s) => LoginScreen(next: s.uri.queryParameters['next'])),
        GoRoute(path: '/consent', builder: (_, _) => const ConsentScreen()),
        GoRoute(
          path: '/profile',
          builder: (_, s) => VoiceProfileScreen(consent: {
            for (final k in ['voice', 'photo', 'location']) k: s.uri.queryParameters[k] != 'false',
          }),
        ),
        GoRoute(path: '/about', builder: (_, _) => const AboutScreen()),
        GoRoute(path: '/artisan', builder: (_, _) => const ArtisanHomeScreen()),
        GoRoute(path: '/artisan/capture', builder: (_, _) => const CaptureScreen()),
        GoRoute(path: '/artisan/build/:id', builder: (_, s) => BuildScreen(captureId: s.pathParameters['id']!)),
        GoRoute(path: '/artisan/review/:id', builder: (_, s) => ReviewScreen(productId: s.pathParameters['id']!)),
        GoRoute(path: '/artisan/products', builder: (_, _) => const MyProductsScreen()),
        GoRoute(path: '/artisan/orders', builder: (_, _) => const ArtisanOrdersScreen()),
        GoRoute(path: '/artisan/earnings', builder: (_, _) => const EarningsScreen()),
        GoRoute(path: '/artisan/help', builder: (_, _) => const HelpScreen()),
        GoRoute(path: '/kiosk', builder: (_, _) => const KioskHomeScreen()),
        GoRoute(path: '/kiosk/onboard', builder: (_, _) => const OnboardArtisanScreen()),
        GoRoute(path: '/store', builder: (_, _) => const StoreHomeScreen()),
        GoRoute(
          path: '/store/search',
          builder: (_, s) => SearchScreen(
              query: s.uri.queryParameters['q'], category: s.uri.queryParameters['category'], state: s.uri.queryParameters['state'],
              sort: s.uri.queryParameters['sort']),
        ),
        GoRoute(path: '/store/p/:id', builder: (_, s) => ProductScreen(productId: s.pathParameters['id']!)),
        GoRoute(path: '/store/cert/:id', builder: (_, s) => CertificateScreen(certId: s.pathParameters['id']!, sig: s.uri.queryParameters['s'])),
        GoRoute(path: '/store/cart', builder: (_, s) => CartScreen(addProductId: s.uri.queryParameters['add'])),
        GoRoute(path: '/store/orders', builder: (_, _) => const BuyerOrdersScreen()),
        GoRoute(path: '/store/scan', builder: (_, _) => const ScanScreen()),
      ],
    );

/// Santali (Ol Chiki) and other locales without Material translations fall back to English Material strings
/// while the app's own strings stay in the chosen language.
class _FallbackMaterialDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _FallbackMaterialDelegate();
  @override
  bool isSupported(Locale l) => !GlobalMaterialLocalizations.delegate.isSupported(l);
  @override
  Future<MaterialLocalizations> load(Locale l) => GlobalMaterialLocalizations.delegate.load(const Locale('en'));
  @override
  bool shouldReload(_) => false;
}

class _FallbackCupertinoDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _FallbackCupertinoDelegate();
  @override
  bool isSupported(Locale l) => !GlobalCupertinoLocalizations.delegate.isSupported(l);
  @override
  Future<CupertinoLocalizations> load(Locale l) => GlobalCupertinoLocalizations.delegate.load(const Locale('en'));
  @override
  bool shouldReload(_) => false;
}

class ShilpSetuApp extends StatefulWidget {
  const ShilpSetuApp({super.key});

  /// Opening title animation on launch (tests turn it off).
  static bool showSplash = true;

  @override
  State<ShilpSetuApp> createState() => _ShilpSetuAppState();
}

class _ShilpSetuAppState extends State<ShilpSetuApp> {
  late final GoRouter router = buildRouter(context.read<Session>());
  bool splashDone = !ShilpSetuApp.showSplash;
  final messenger = GlobalKey<ScaffoldMessengerState>();
  late final back = _BackDispatcher(_onBackWithNothingToPop);
  DateTime? _lastBack;

  /// Pages visited, oldest first. Screens opened with `go` replace the navigator stack, so this history is
  /// what lets Android back return to the page the user actually came from.
  final _history = <String>[];

  /// Setup steps never revisited with back (and the welcome/role page once signed in).
  bool _skip(String location, Session s) {
    final path = Uri.parse(location).path;
    return const {'/', '/login', '/language', '/consent', '/profile'}.contains(path) ||
        (path == '/welcome' && s.signedIn);
  }

  void _track() {
    final loc = router.routerDelegate.currentConfiguration.uri.toString();
    if (Uri.parse(loc).path == '/welcome') {
      _history
        ..clear()
        ..add(loc); // logged out / starting over: nothing before this
      return;
    }
    final i = _history.lastIndexOf(loc);
    if (i >= 0) {
      _history.removeRange(i + 1, _history.length); // came back to a page already in the trail
    } else {
      _history.add(loc);
    }
  }

  String _home(Session s) => switch (s.role) {
        'buyer' => '/store',
        'operator' when s.signedIn => '/kiosk',
        'artisan' when s.signedIn => s.hasProfile ? '/artisan' : '/consent',
        _ => '/welcome',
      };

  /// Android back when the navigator has nothing below this screen: go to the previous page in the history;
  /// with no previous page, go home; on the home screen a second press within 2 s exits.
  Future<bool> _onBackWithNothingToPop() async {
    final s = context.read<Session>();
    final here = router.routerDelegate.currentConfiguration.uri.toString();
    for (var i = _history.length - 1; i >= 0; i--) {
      final loc = _history[i];
      if (loc == here || _skip(loc, s)) continue;
      _history.removeRange(i + 1, _history.length);
      router.go(loc);
      return true;
    }
    final path = Uri.parse(here).path;
    final home = _home(s);
    if (path != home && path != '/welcome' && path != '/') {
      router.go(home);
      return true;
    }
    final now = DateTime.now();
    if (_lastBack != null && now.difference(_lastBack!) < const Duration(seconds: 2)) return false; // exit
    _lastBack = now;
    final l = lookupL10n(uiLocaleFor(s.language));
    messenger.currentState
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l.pressBackAgain), duration: const Duration(seconds: 2)));
    return true;
  }

  @override
  void dispose() {
    router.routerDelegate.removeListener(_track);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    router.routerDelegate.addListener(_track);
    // Any microphone failure, on any screen, is explained on screen and aloud in the user's language.
    final voice = context.read<Voice>();
    voice.onProblem = (p) {
      final l = lookupL10n(uiLocaleFor(context.read<Session>().language));
      final text = switch (p) {
        VoiceProblem.permission => l.micPermission,
        VoiceProblem.unavailable => l.micUnavailable,
        VoiceProblem.insecure => l.micInsecure,
        VoiceProblem.noSpeech => l.micNoSpeech,
        VoiceProblem.network => l.micNetwork,
      };
      messenger.currentState
        ?..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.mic_off_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ]),
          duration: const Duration(seconds: 6),
        ));
      voice.speak(text);
    };
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.select<Session, String>((s) => s.language);
    final dark = context.select<Session, bool>((s) => s.dark);
    SS.dark = dark;
    return MaterialApp.router(
      scaffoldMessengerKey: messenger,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      backButtonDispatcher: back,
      title: 'ShilpSetu',
      debugShowCheckedModeBanner: false,
      theme: SS.theme(),
      // colours are read at build time, so rebuild every screen when the theme flips
      builder: (context, child) => Stack(children: [
        KeyedSubtree(key: ValueKey(dark), child: child!),
        if (!splashDone)
          Positioned.fill(
            // above the navigator there is no Material: give the title one so text is not debug-underlined
            child: Material(
              type: MaterialType.transparency,
              child: SplashOverlay(onDone: () => setState(() => splashDone = true)),
            ),
          ),
      ]),
      locale: uiLocaleFor(lang),
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: const [
        ...L10n.localizationsDelegates,
        _FallbackMaterialDelegate(),
        _FallbackCupertinoDelegate(),
      ],
    );
  }
}

/// Runs the normal back (close a sheet, pop a screen) first; only when nothing could be popped does it ask
/// [onUnhandled], which returns true when it handled the press (false lets Android close the app).
class _BackDispatcher extends RootBackButtonDispatcher {
  _BackDispatcher(this.onUnhandled);
  final Future<bool> Function() onUnhandled;

  @override
  Future<bool> didPopRoute() async {
    if (await super.didPopRoute()) return true;
    return onUnhandled();
  }
}
