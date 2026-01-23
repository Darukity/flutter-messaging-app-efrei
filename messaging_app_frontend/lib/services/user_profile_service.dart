import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'dio_client.dart';

class UserProfileService {
  static final DioClient _dioClient = DioClient();

  // Récupérer le profil actuel
  static Future<Map<String, dynamic>> getCurrentProfile() async {
    try {
      // Pas d'ID fourni, le backend utilisera req.user du token
      final response = await _dioClient.get(
        '${ApiConfig.baseUrl}/users/profile',
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Impossible de récupérer le profil');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Mettre à jour les données du profil
  static Future<Map<String, dynamic>> updateProfileData({
    required String firstName,
    required String lastName,
    required String email,
    String? profession,
    String? employer,
    String? location,
    List<String>? skills,
  }) async {
    try {
      final response = await _dioClient.put(
        '${ApiConfig.baseUrl}/users/profile_data',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'profession': profession,
          'employer': employer,
          'location': location,
          'skills': skills,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Impossible de mettre à jour le profil');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Mettre à jour la bio
  static Future<Map<String, dynamic>> updateAbout(String aboutText) async {
    try {
      final response = await _dioClient.put(
        '${ApiConfig.baseUrl}/users/profile_about',
        data: {
          'aboutText': aboutText,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Impossible de mettre à jour la bio');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}
