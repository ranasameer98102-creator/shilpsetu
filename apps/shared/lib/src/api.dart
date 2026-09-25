import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.status, this.message);
  final int status;
  final String message;
  bool get isNetwork => status == 0;
  @override
  String toString() => 'ApiException($status): $message';
}

/// Thin JSON client for the ShilpSetu API (/api/v1). Token and "act as artisan" (kiosk) are mutable.
class ApiClient {
  ApiClient({required this.baseUrl, http.Client? client}) : _http = client ?? http.Client();

  String baseUrl; // changeable at runtime (Settings > Server address)
  final http.Client _http;
  String? token;
  String? actAsArtisanId;
  Duration timeout = const Duration(seconds: 90); // a sleeping free cloud instance takes ~1 min to wake

  Uri uri(String path, [Map<String, dynamic>? query]) {
    final full =
        path.startsWith('/api/') || path.startsWith('/ondc') || path.startsWith('/v/') || path.startsWith('/media')
        ? path
        : '/api/v1$path';
    final q = query?.map((k, v) => MapEntry(k, v.toString()))?..removeWhere((k, v) => v == 'null');
    return Uri.parse('$baseUrl$full').replace(queryParameters: (q == null || q.isEmpty) ? null : q);
  }

  Map<String, String> _headers([Map<String, String>? extra]) => {
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
    'X-Artisan-Id': ?actAsArtisanId,
    ...?extra,
  };

  Future<dynamic> _send(Future<http.Response> Function() fn) async {
    http.Response r;
    try {
      r = await fn().timeout(timeout);
    } catch (e) {
      throw ApiException(0, 'network: $e');
    }
    final body = r.body.isEmpty ? null : _decode(r);
    if (r.statusCode >= 400) {
      final detail = body is Map && body['detail'] != null ? body['detail'].toString() : r.reasonPhrase ?? 'error';
      throw ApiException(r.statusCode, detail);
    }
    return body;
  }

  dynamic _decode(http.Response r) {
    final ct = r.headers['content-type'] ?? '';
    if (!ct.contains('json')) return r.body;
    return jsonDecode(utf8.decode(r.bodyBytes));
  }

  Future<dynamic> get(String path, [Map<String, dynamic>? query]) =>
      _send(() => _http.get(uri(path, query), headers: _headers()));

  Future<dynamic> post(String path, [Object? body, Map<String, dynamic>? query]) => _send(
    () => _http.post(
      uri(path, query),
      headers: _headers({'Content-Type': 'application/json'}),
      body: jsonEncode(body ?? {}),
    ),
  );

  Future<dynamic> put(String path, Object? body) => _send(
    () => _http.put(uri(path), headers: _headers({'Content-Type': 'application/json'}), body: jsonEncode(body)),
  );

  Future<dynamic> patch(String path, Object? body) => _send(
    () => _http.patch(uri(path), headers: _headers({'Content-Type': 'application/json'}), body: jsonEncode(body)),
  );

  Future<dynamic> delete(String path) => _send(() => _http.delete(uri(path), headers: _headers()));

  Future<dynamic> putBytes(String path, Uint8List bytes, Map<String, dynamic> query) => _send(
    () => _http.put(uri(path, query), headers: _headers({'Content-Type': 'application/octet-stream'}), body: bytes),
  );

  Future<dynamic> postForm(String path, Map<String, String> fields) =>
      _send(() => _http.post(uri(path), headers: _headers(), body: fields));

  String absolute(String pathOrUrl) => pathOrUrl.startsWith('http') ? pathOrUrl : '$baseUrl$pathOrUrl';
}
