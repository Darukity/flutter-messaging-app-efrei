import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import './auth_storage.dart';


class AuthService {
  
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.register),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "data": data,
        };
      } else {
        return {
          "success": false,
          "error": data["error"] ?? "Erreur lors de l'inscription",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "error": "Impossible de contacter le serveur",
      };
    }
  }

  // ===== LOGIN (NOUVEAU) =====
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data["token"];
          await AuthStorage.saveToken(token);
          return {"success": true, "data": data};
      } else {
        return {
          "success": false,
          "error": data["error"] ?? "Email ou mot de passe incorrect",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "error": "Impossible de contacter le serveur",
      };
    }
  }
}
