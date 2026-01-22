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
}
