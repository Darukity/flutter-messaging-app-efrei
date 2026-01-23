import 'package:dio/dio.dart';
import 'auth_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio _dio;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Ajouter l'interceptor pour le token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Récupérer le token et l'ajouter aux headers
          final token = await AuthStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = 'application/json';
          return handler.next(options);
        },
        onError: (error, handler) {
          // Gérer les erreurs globales
          if (error.response?.statusCode == 401) {
            // Token expiré ou invalide
            AuthStorage.clearToken();
            // Rediriger vers login si besoin
          }
          return handler.next(error);
        },
      ),
    );
  }

  factory DioClient() {
    return _instance;
  }

  Dio get dio => _dio;

  // Méthodes pratiques
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete(path, queryParameters: queryParameters, options: options);
  }
}
