import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class AuthStorage {
  static const String _tokenKey = "jwt_token";
  static const String _userDataKey = 'user_data';

  // Sauvegarder le token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    debugPrint('💾 Token sauvegardé: ${token.substring(0, 20)}...');
  }

  // Récupérer le token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    debugPrint('🔍 Token récupéré: ${token != null ? "${token.substring(0, 20)}..." : "null"}');
    return token;
  }

  // Supprimer le token (logout)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
    debugPrint('🗑️ Token et données utilisateur supprimés');
  }

  // Save user data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(userData);
    await prefs.setString(_userDataKey, jsonString);
    debugPrint('💾 Données utilisateur sauvegardées:');
    debugPrint('   ${userData.keys.join(", ")}');
    debugPrint('   ID: ${userData['_id']}');
    debugPrint('   Nom: ${userData['firstName']} ${userData['lastName']}');
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    debugPrint('🔍 Récupération données utilisateur: ${userDataString != null ? "trouvées" : "null"}');
    
    if (userDataString != null) {
      final data = jsonDecode(userDataString);
      debugPrint('   ID: ${data['_id']}');
      debugPrint('   Nom: ${data['firstName']} ${data['lastName']}');
      return data;
    }
    return null;
  }
}
