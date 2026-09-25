import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';

import 'pages.dart';
import 'widgets.dart';

const _apiBase = String.fromEnvironment('API_BASE');

/// Served by the API itself (cloud, /admin/) → same origin; served by a local dev server (:8091) → API on :8000.
String get apiBase {
  if (_apiBase.isNotEmpty) return _apiBase;
  final b = Uri.base;
  return b.scheme == 'https' || b.port == 8000 ? b.origin : '${b.scheme}://${b.host}:8000';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final api = ApiClient(baseUrl: apiBase)..token = prefs.getString('admin_token');
  runApp(AdminApp(api: api, prefs: prefs));
}

class AdminApp extends StatefulWidget {
  const AdminApp({super.key, required this.api, required this.prefs});
  final ApiClient api;
  final SharedPreferences prefs;

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  late bool dark = widget.prefs.getString('theme') == 'dark' ||
      (widget.prefs.getString('theme') == null && WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);

  Future<void> _toggleTheme() async {
    setState(() => dark = !dark);
    await widget.prefs.setString('theme', dark ? 'dark' : 'light');
  }

  @override
  Widget build(BuildContext context) {
    SS.dark = dark;
    return MaterialApp(
    title: 'ShilpSetu Admin',
    debugShowCheckedModeBanner: false,
    theme: SS.theme(),
    // colours are read at build time, so rebuild every page when the theme flips
    builder: (context, child) => KeyedSubtree(key: ValueKey(dark), child: child!),
    home: widget.api.token == null
        ? LoginPage(
            api: widget.api,
            onDone: (t) async {
              await widget.prefs.setString('admin_token', t);
              setState(() {});
            },
          )
        : Shell(
            api: widget.api,
            dark: dark,
            onToggleTheme: _toggleTheme,
            onLogout: () async {
              widget.api.token = null;
              await widget.prefs.remove('admin_token');
              setState(() {});
            },
          ),
  );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.api, required this.onDone});
  final ApiClient api;
  final ValueChanged<String> onDone;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phone = TextEditingController(text: '+919000000000');
  final code = TextEditingController();
  String? demo, error;
  bool sent = false;

  Future<void> _send() async {
    try {
      final r = await widget.api.post('/auth/otp/request', {'phone': phone.text, 'language': 'en'});
      setState(() => (sent = true, demo = r['dev_otp'], error = null));
    } catch (e) {
      setState(() => error = '$e');
    }
  }

  Future<void> _verify() async {
    try {
      final r = await widget.api.post('/auth/otp/verify', {'phone': phone.text, 'code': code.text, 'role': 'admin'});
      if (r['role'] != 'admin') throw ApiException(403, 'not an admin account');
      widget.api.token = r['access_token'];
      widget.onDone(r['access_token']);
    } catch (e) {
      setState(() => error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: SS.tealDeep,
    body: Center(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: SS.white, borderRadius: BorderRadius.circular(SS.radiusLarge)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Wordmark(size: 30),
            Text('Admin · MoSJE / platform staff', style: TextStyle(color: SS.slate)),
            const SizedBox(height: 20),
            TextField(
              controller: phone,
              decoration: const InputDecoration(labelText: 'Admin mobile number'),
            ),
            const SizedBox(height: 12),
            if (sent)
              TextField(
                controller: code,
                decoration: const InputDecoration(labelText: '6-digit code'),
                onSubmitted: (_) => _verify(),
              ),
            if (demo != null)
              TextButton(
                onPressed: () => setState(() => code.text = demo!),
                child: Text('Demo code (mock SMS): $demo'),
              ),
            if (error != null) Text(error!, style: TextStyle(color: SS.danger)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: sent ? _verify : _send, child: Text(sent ? 'Sign in' : 'Send code')),
            ),
            const Footer(),
          ],
        ),
      ),
    ),
  );
}

class Shell extends StatefulWidget {
  const Shell({super.key, required this.api, required this.onLogout, this.dark = false, this.onToggleTheme});
  final ApiClient api;
  final VoidCallback onLogout;
  final bool dark;
  final VoidCallback? onToggleTheme;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;

  static const items = <(IconData, String)>[
    (Icons.insights_rounded, 'Overview'),
    (Icons.public_rounded, 'Impact'),
    (Icons.verified_user_outlined, 'Verification'),
    (Icons.inventory_2_outlined, 'Listings'),
    (Icons.hub_outlined, 'ONDC'),
    (Icons.sms_outlined, 'SMS / IVR'),
    (Icons.storefront_outlined, 'Operators'),
    (Icons.account_balance_outlined, 'Schemes'),
    (Icons.model_training_rounded, 'Models'),
    (Icons.tune_rounded, 'Settings'),
    (Icons.fact_check_outlined, 'Audit'),
  ];

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    final page = switch (index) {
      0 => OverviewPage(api: api),
      1 => ImpactPage(api: api),
      2 => VerificationPage(api: api),
      3 => ListingsPage(api: api),
      4 => OndcPage(api: api),
      5 => NotifyPage(api: api),
      6 => OperatorsPage(api: api),
      7 => SchemesPage(api: api),
      8 => ModelsPage(api: api),
      9 => SettingsPage(api: api),
      _ => AuditPage(api: api),
    };
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: SS.teal,
            extended: MediaQuery.sizeOf(context).width > 1100,
            selectedIndex: index,
            onDestinationSelected: (i) => setState(() => index = i),
            leading: const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Wordmark(size: 22)),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    onPressed: widget.onToggleTheme,
                    tooltip: widget.dark ? 'Light mode' : 'Dark mode',
                    icon: Icon(widget.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: SS.cream),
                  ),
                  IconButton(
                    onPressed: widget.onLogout,
                    tooltip: 'Log out',
                    icon: const Icon(Icons.logout_rounded, color: SS.cream),
                  ),
                ]),
              ),
            ),
            indicatorColor: SS.marigold,
            unselectedIconTheme: IconThemeData(color: SS.sand),
            selectedIconTheme: IconThemeData(color: SS.tealDeep),
            unselectedLabelTextStyle: TextStyle(color: SS.sand, fontFamily: SS.poppins),
            selectedLabelTextStyle: const TextStyle(
              color: SS.cream,
              fontFamily: SS.poppins,
              fontWeight: FontWeight.w600,
            ),
            destinations: [for (final (i, l) in items) NavigationRailDestination(icon: Icon(i), label: Text(l))],
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(child: page),
                const Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
