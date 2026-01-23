/// 📱 Model pour les réponses d'authentification
class AuthResponse {
  final String token;
  final Map<String, dynamic> user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      user: json['user'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user,
    };
  }
}

/// 📤 Model pour les requêtes de login
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

/// 📝 Model pour les requêtes de signup
class SignupRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  SignupRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
    };
  }
}

/// ✅ Model pour les réponses génériques de succès
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
    );
  }

  factory ApiResponse.error(String error) {
    return ApiResponse(
      success: false,
      error: error,
    );
  }

  @override
  String toString() =>
      'ApiResponse(success: $success, message: $message, error: $error)';
}
