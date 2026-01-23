import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/models.dart';
import './auth_storage.dart';

/// Service d'authentification avec gestion des modèles typés
class AuthService {
  
  /// 📝 Créer un compte utilisateur
  /// 
  /// Prend les données d'inscription et retourne une réponse typée AuthResponse
  /// contenant le token et les données utilisateur en cas de succès
  static Future<ApiResponse<AuthResponse>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final request = SignupRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );

      final response = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.register),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(responseData);
        await AuthStorage.saveToken(authResponse.token);
        return ApiResponse<AuthResponse>(
          success: true,
          data: authResponse,
        );
      } else {
        return ApiResponse<AuthResponse>(
          success: false,
          error: responseData["error"] ?? "Erreur lors de l'inscription",
        );
      }
    } catch (e) {
      return ApiResponse<AuthResponse>(
        success: false,
        error: "Impossible de contacter le serveur: $e",
      );
    }
  }

  /// 🔐 Se connecter avec email et mot de passe
  /// 
  /// Vérifie les identifiants et retourne un token JWT en cas de succès
  static Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest(
        email: email,
        password: password,
      );

      final response = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(responseData);
        await AuthStorage.saveToken(authResponse.token);
        return ApiResponse<AuthResponse>(
          success: true,
          data: authResponse,
        );
      } else {
        return ApiResponse<AuthResponse>(
          success: false,
          error: responseData["error"] ?? "Email ou mot de passe incorrect",
        );
      }
    } catch (e) {
      return ApiResponse<AuthResponse>(
        success: false,
        error: "Impossible de contacter le serveur: $e",
      );
    }
  }

  /// 🚪 Déconnecter l'utilisateur
  /// 
  /// Supprime le token stocké localement
  static Future<void> logout() async {
    await AuthStorage.clearToken();
  }
}
