import '../config/api_config.dart';
import 'dio_client.dart';
import '../models/models.dart';

class ConversationService {
  static final DioClient _dioClient = DioClient();

  /// 📋 Obtenir toutes les conversations avec typage fort
  static Future<List<Conversation>> getConversations() async {
    try {
      final response = await _dioClient.get('${ApiConfig.baseUrl}/conversations');

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data
            .map((item) => Conversation.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Impossible de récupérer les conversations');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// 👥 Obtenir tous les utilisateurs avec typage fort
  static Future<List<User>> getAllUsers() async {
    try {
      final response = await _dioClient.get('${ApiConfig.baseUrl}/users');

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data
            .map((item) => User.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Impossible de récupérer les utilisateurs');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// 💬 Obtenir une conversation spécifique avec typage fort
  static Future<Conversation?> getConversation(String userId) async {
    try {
      final response = await _dioClient.get('${ApiConfig.baseUrl}/conversations/$userId');

      if (response.statusCode == 200) {
        return Conversation.fromJson(response.data as Map<String, dynamic>);
      } else {
        return null; // No conversation exists yet
      }
    } catch (e) {
      return null;
    }
  }

  /// 📤 Envoyer un message avec model typé
  static Future<Conversation> sendMessage({
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
        return Conversation.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Impossible d\'envoyer le message');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// 👤 Obtenir un utilisateur par ID avec typage fort
  static Future<User> getUserById(String userId) async {
    try {
      final response = await _dioClient.get('${ApiConfig.baseUrl}/users/$userId');

      if (response.statusCode == 200) {
        return User.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Impossible de récupérer les informations de l\'utilisateur');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}
