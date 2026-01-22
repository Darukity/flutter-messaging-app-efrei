import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class AuthHttp {
  static Future<http.Response> post(String url, {String? body}) async {
    final token = await AuthStorage.getToken();

    return http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: body,
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
