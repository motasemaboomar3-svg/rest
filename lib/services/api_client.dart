import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class ApiClient {
  ApiClient({this.token});
  String? token;

  Map<String, String> _headers({bool json = true}) {
    final h = <String, String>{};
    if (json) h['Content-Type'] = 'application/json; charset=utf-8';
    if (token != null && token!.isNotEmpty) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Uri _u(String path, [Map<String, dynamic>? q]) {
    final base = AppConfig.baseUrl.replaceAll(RegExp(r'/$'), '');
    final uri = Uri.parse('$base$path');
    if (q == null) return uri;
    return uri.replace(queryParameters: q.map((k, v) => MapEntry(k, '$v')));
  }

  Future<dynamic> getJson(String path, {Map<String, dynamic>? q}) async {
    final res = await http.get(_u(path, q), headers: _headers()).timeout(AppConfig.apiTimeout);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(utf8.decode(res.bodyBytes));
    }
    throw Exception('HTTP ${res.statusCode}: ${utf8.decode(res.bodyBytes)}');
  }

  Future<dynamic> postJson(String path, Object body) async {
    final res = await http
        .post(_u(path), headers: _headers(), body: json.encode(body))
        .timeout(AppConfig.apiTimeout);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(utf8.decode(res.bodyBytes));
    }
    throw Exception('HTTP ${res.statusCode}: ${utf8.decode(res.bodyBytes)}');
  }
}
