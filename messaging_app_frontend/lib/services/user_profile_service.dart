import '../config/api_config.dart';
import '../models/models.dart';
import 'dio_client.dart';

/// Service de gestion du profil utilisateur avec modèles typés
class UserProfileService {
  static final DioClient _dioClient = DioClient();

  /// 👤 Récupérer le profil utilisateur courant
  /// 
  /// Récupère les données du profil de l'utilisateur connecté
  /// Le backend utilise req.user du token JWT pour identifier l'utilisateur
  static Future<ApiResponse<User>> getCurrentProfile() async {
    try {
      final response = await _dioClient.get(
        '${ApiConfig.baseUrl}/users/profile',
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data);
        return ApiResponse<User>(
          success: true,
          data: user,
        );
      } else {
        return ApiResponse<User>(
          success: false,
          error: 'Impossible de récupérer le profil',
        );
      }
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        error: 'Erreur: $e',
      );
    }
  }

  /// 📝 Mettre à jour les données du profil
  /// 
  /// Met à jour les informations personnelles et professionnelles
  static Future<ApiResponse<User>> updateProfileData({
    required String firstName,
    required String lastName,
    required String email,
    String? profession,
    String? employer,
    String? location,
    List<String>? skills,
  }) async {
    try {
      final request = UpdateProfileRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        profession: profession,
        employer: employer,
        location: location,
        skills: skills,
      );

      final response = await _dioClient.put(
        '${ApiConfig.baseUrl}/users/profile_data',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data);
        return ApiResponse<User>(
          success: true,
          data: user,
        );
      } else {
        return ApiResponse<User>(
          success: false,
          error: 'Impossible de mettre à jour le profil',
        );
      }
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        error: 'Erreur: $e',
      );
    }
  }

  /// 💬 Mettre à jour la biographie
  /// 
  /// Met à jour le champ "À propos" du profil utilisateur
  static Future<ApiResponse<User>> updateAbout(String aboutUser) async {
    try {
      final request = UpdateAboutRequest(
        aboutUser: aboutUser,
      );

      final response = await _dioClient.put(
        '${ApiConfig.baseUrl}/users/profile_about',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data);
        return ApiResponse<User>(
          success: true,
          data: user,
        );
      } else {
        return ApiResponse<User>(
          success: false,
          error: 'Impossible de mettre à jour la bio',
        );
      }
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        error: 'Erreur: $e',
      );
    }
  }
}
