import 'dart:io';
import 'package:flutter/services.dart';
import '../config/environment_config.dart';

class CertificateLoader {
  /// Загрузка сертификата в SecurityContext
  static Future<SecurityContext> loadServerCertificate() async {
    try {
      // Создаем новый контекст безопасности
      final securityContext = SecurityContext.defaultContext;
      
      // Путь к PEM-сертификату сервера
      final certPath = '${EnvironmentConfig.sslCertPath}/localhost.pem';
      
      // Загружаем сертификат из ассетов
      final certBytes = await rootBundle.load(certPath);
      securityContext.setTrustedCertificatesBytes(certBytes.buffer.asUint8List());
      
      return securityContext;
    } catch (e) {
      print('Ошибка при загрузке сертификата: $e');
      // При ошибке возвращаем контекст по умолчанию
      return SecurityContext.defaultContext;
    }
  }
  
  /// Создание HttpClient с загруженным сертификатом
  static Future<HttpClient> createSecureClient() async {
    if (EnvironmentConfig.isProduction()) {
      // В продакшене используем сертификаты
      final securityContext = await loadServerCertificate();
      return HttpClient(context: securityContext);
    } else {
      // В разработке принимаем любые сертификаты
      return HttpClient()
        ..badCertificateCallback = 
            (X509Certificate cert, String host, int port) => true;
    }
  }
} 