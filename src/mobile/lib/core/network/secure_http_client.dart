import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/environment_config.dart';
import 'certificate_loader.dart';

class SecureHttpClient {
  static void configureSecurity() {
    // Применяем обход проверки SSL только в режиме разработки
    if (EnvironmentConfig.isDevelopment()) {
      HttpOverrides.global = _DevCertificateHttpOverrides();
    }
  }

  static Future<Dio> createDio() async {
    final dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    
    // Настраиваем валидацию статусов ответа
    dio.options.validateStatus = (status) {
      return status != null && status < 500;
    };
    
    // Добавляем базовый URL для всех запросов
    dio.options.baseUrl = EnvironmentConfig.baseUrl;
    
    // Add auth token interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get the token from shared preferences
          final token = prefs.getString('access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
    
    if (EnvironmentConfig.isProduction()) {
      // В продакшене настраиваем Dio использовать наши сертификаты
      // HttpClient с загруженными сертификатами создается через CertificateLoader
      // Для Dio это сложнее настроить напрямую, обычно используют дополнительные пакеты
    }
    
    return dio;
  }
}

class _DevCertificateHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = 
          (X509Certificate cert, String host, int port) => true;
  }
} 