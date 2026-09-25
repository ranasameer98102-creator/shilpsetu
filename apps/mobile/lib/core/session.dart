import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shilpsetu_core/shilpsetu_core.dart';
import 'package:uuid/uuid.dart';

import 'config.dart';

/// Who is using the app, in which language, and whether they are signed in. Persisted across restarts.
class Session extends ChangeNotifier {
  Session(this.prefs, {ApiClient? api}) : api = api ?? ApiClient(baseUrl: AppConfig.apiBase) {
    token = prefs.getString('token');
    role = prefs.getString('role');
    // Artisans default to Hindi on the phone; the web storefront is mostly used by buyers, so English.
    language = prefs.getString('language') ?? (kIsWeb ? 'en' : 'hi');
    hasProfile = prefs.getBool('has_profile') ?? false;
    lowData = prefs.getBool('low_data') ?? false;
    // First launch follows the phone's own light/dark setting.
    final theme = prefs.getString('theme');
    dark = theme == null ? WidgetsBinding.instance.platformDispatcher.platformBrightness.name == 'dark' : theme == 'dark';
    deviceId = prefs.getString('device_id') ?? const Uuid().v4();
    prefs.setString('device_id', deviceId);
    this.api.token = token;
    final savedBase = prefs.getString('api_base');
    if (savedBase != null && savedBase.isNotEmpty) this.api.baseUrl = savedBase;
    activeArtisanId = prefs.getString('active_artisan_id');
    activeArtisanName = prefs.getString('active_artisan_name');
    this.api.actAsArtisanId = role == 'operator' ? activeArtisanId : null;
  }

  final SharedPreferences prefs;
  final ApiClient api;
  String? token;
  String? role; // artisan | buyer | operator
  late String language;
  late String deviceId;
  bool hasProfile = false;
  bool lowData = false;
  bool dark = false; // dark theme
  bool languageChosen = false;
  String? activeArtisanId; // kiosk: artisan being served
  String? activeArtisanName;
  Map<String, dynamic>? profile;
  Map<String, dynamic>? publicConfig;

  bool get signedIn => token != null;

  /// Buyers and artisans can shop (one phone number = one account); kiosk operators and admins cannot.
  bool get canShop => signedIn && (role == 'buyer' || role == 'artisan');

  Future<void> setRole(String r) async {
    role = r;
    await prefs.setString('role', r);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    language = code;
    languageChosen = true;
    await prefs.setString('language', code);
    if (signedIn) {
      try {
        await api.patch('/auth/me', {'language': code});
      } catch (_) {}
    }
    notifyListeners();
  }

  /// Point the app at a different server (e.g. the laptop's new Wi-Fi address) without rebuilding the APK.
  Future<void> setApiBase(String url) async {
    final clean = url.trim().replaceAll(RegExp(r'/+$'), '');
    api.baseUrl = clean;
    await prefs.setString('api_base', clean);
    notifyListeners();
  }

  /// Remembered from the last checkout so the storefront can show "Near you".
  String? get buyerState => prefs.getString('buyer_state');
  Future<void> setBuyerState(String s) => prefs.setString('buyer_state', s);

  Future<void> setDark(bool v) async {
    dark = v;
    await prefs.setString('theme', v ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setLowData(bool v) async {
    lowData = v;
    await prefs.setBool('low_data', v);
    notifyListeners();
  }

  Future<Map<String, dynamic>> requestOtp(String phone) async =>
      Map<String, dynamic>.from(await api.post('/auth/otp/request', {'phone': phone, 'language': language}));

  Future<void> verifyOtp(String phone, String code) async {
    final r = Map<String, dynamic>.from(await api.post('/auth/otp/verify',
        {'phone': phone, 'code': code, 'role': role ?? 'artisan', 'language': language}));
    token = r['access_token'];
    role = r['role'];
    hasProfile = r['has_profile'] == true;
    api.token = token;
    await prefs.setString('token', token!);
    await prefs.setString('role', role!);
    await prefs.setBool('has_profile', hasProfile);
    notifyListeners();
  }

  Future<void> markProfileDone(Map<String, dynamic> p) async {
    profile = p;
    hasProfile = true;
    await prefs.setBool('has_profile', true);
    notifyListeners();
  }

  Future<Map<String, dynamic>?> loadProfile() async {
    if (!signedIn || role == 'buyer') return null;
    try {
      profile = Map<String, dynamic>.from(await api.get('/artisans/me'));
      notifyListeners();
    } on ApiException catch (e) {
      if (e.status == 401) await logout();
    }
    return profile;
  }

  Future<void> selectArtisan(String? id, String? name) async {
    activeArtisanId = id;
    activeArtisanName = name;
    api.actAsArtisanId = id;
    if (id == null) {
      await prefs.remove('active_artisan_id');
      await prefs.remove('active_artisan_name');
    } else {
      await prefs.setString('active_artisan_id', id);
      await prefs.setString('active_artisan_name', name ?? '');
    }
    notifyListeners();
  }

  Future<void> logout() async {
    token = null;
    role = null;
    hasProfile = false;
    profile = null;
    api.token = null;
    api.actAsArtisanId = null;
    for (final k in ['token', 'role', 'has_profile', 'active_artisan_id', 'active_artisan_name']) {
      await prefs.remove(k);
    }
    notifyListeners();
  }
}
