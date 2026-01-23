import '../config/api_config.dart';
import 'dio_client.dart';

class ConversationService {
  static final DioClient _dioClient = DioClient();

  static Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final response = await _dioClient.get('${ApiConfig.baseUrl}/conversations');

      if (response.statusCode == 200) {
        final data = response.data;
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Impossible de récupérer les conversations');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Get all users (temporary until user list feature is implemented)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _dioClient.get('${ApiConfig.baseUrl}/users');

      if (response.statusCode == 200) {
        final data = response.data;
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Impossible de récupérer les utilisateurs');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Get conversation with a specific user
  static Future<Map<String, dynamic>?> getConversation(String userId) async {
    try {
      final response = await _dioClient.get('${ApiConfig.baseUrl}/conversations/$userId');

      if (response.statusCode == 200) {
        final data = response.data;
        return data;
      } else {
        return null; // No conversation exists yet
      }
    } catch (e) {
      return null;
    }
  }

  // Send a message to a user
  static Future<Map<String, dynamic>> sendMessage({
    required String user2Id,
    required String author,
    required String content,
    required String authorImage,
  }) async {
    try {
      final response = await _dioClient.post(
        '${ApiConfig.baseUrl}/conversations/message',
        data: {
          'user2_id': user2Id,
          'author': author,
          'content': content,
          'authorImage': authorImage,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data;
      } else {
        throw Exception('Impossible d\'envoyer le message');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Get user details by ID
  static Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await _dioClient.get('${ApiConfig.baseUrl}/users/$userId');

      if (response.statusCode == 200) {
        final data = response.data;
        return data;
      } else {
        throw Exception('Impossible de récupérer les informations de l\'utilisateur');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}
