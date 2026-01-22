import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class AuthHttp {
  static Future<http.Response> post(String url, {Map<String, dynamic>? body}) async {
    final token = await AuthStorage.getToken();

    return http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: body != null ? jsonEncode(body) : null,
    );
  }

  static Future<http.Response> get(String url) async {
    final token = await AuthStorage.getToken();

    return http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }
}
