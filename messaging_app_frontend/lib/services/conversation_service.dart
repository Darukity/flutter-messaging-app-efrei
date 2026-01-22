import '../config/api_config.dart';
import 'auth_http.dart';
import 'dart:convert';

class ConversationService {
  static Future<List<Map<String, dynamic>>> getConversations() async {
    final response = await AuthHttp.get('${ApiConfig.baseUrl}/conversations');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Impossible de récupérer les conversations');
    }
  }

  // Get all users (temporary until user list feature is implemented)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await AuthHttp.get('${ApiConfig.baseUrl}/users');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Impossible de récupérer les utilisateurs');
    }
  }

  // Get conversation with a specific user
  static Future<Map<String, dynamic>?> getConversation(String userId) async {
    final response = await AuthHttp.get('${ApiConfig.baseUrl}/conversations/$userId');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      return null; // No conversation exists yet
    }
  }

  // Send a message to a user
  static Future<Map<String, dynamic>> sendMessage({
    required String user2Id,
    required String author,
    required String content,
    required String authorImage,
  }) async {
    final response = await AuthHttp.post(
      '${ApiConfig.baseUrl}/conversations/message',
      body: jsonEncode({
        'user2_id': user2Id,
        'author': author,
        'content': content,
        'authorImage': authorImage,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Impossible d\'envoyer le message');
    }
  }

  // Get user details by ID
  static Future<Map<String, dynamic>> getUserById(String userId) async {
    final response = await AuthHttp.get('${ApiConfig.baseUrl}/users/$userId');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Impossible de récupérer les informations de l\'utilisateur');
    }
  }
}
