import 'package:flutter/foundation.dart';

/// Build-time configuration. Override with --dart-define=API_BASE=https://api.example.in
abstract final class AppConfig {
  static const _apiBase = String.fromEnvironment('API_BASE');

  static String get apiBase {
    if (_apiBase.isNotEmpty) return _apiBase;
    if (kIsWeb) {
      // Served by the API itself (cloud) → same origin; served by a local dev server (:8090) → API on :8000 of that host.
      final b = Uri.base;
      return b.scheme == 'https' || b.port == 8000 ? b.origin : '${b.scheme}://${b.host}:8000';
    }
    // Android emulator reaches the host machine at 10.0.2.2; a phone on the same Wi-Fi needs API_BASE.
    return defaultTargetPlatform == TargetPlatform.android ? 'http://10.0.2.2:8000' : 'http://localhost:8000';
  }

  /// Missed-call / IVR helpdesk number (§9.13).
  static const helpline = String.fromEnvironment('HELPLINE', defaultValue: '+918000000000');

  /// Team ID placeholder shown on the About screen (configurable per §1).
  static const teamId = String.fromEnvironment('TEAM_ID', defaultValue: '[Your Team ID]');
}
