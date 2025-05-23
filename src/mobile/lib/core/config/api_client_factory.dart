import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import './environment_config.dart';
import './ssl_certificate_loader.dart';

class ApiClientFactory {
  // Create and configure a Dio client with proper SSL handling
  static Future<Dio> createDioClient() async {
    final dio = Dio();
    
    // Use different SSL handling based on environment
    if (EnvironmentConfig.isDevelopment()) {
      // In development, we can either bypass SSL checks or use loaded certificates
      dio.httpClientAdapter = HttpClientAdapter();
      (dio.httpClientAdapter as dynamic).onHttpClientCreate = (HttpClient client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };
    } else {
      // In production, use proper certificate validation
      // This depends on how you want to handle certificates in production
      // Example showing one approach (not implemented fully)
      dio.options.headers = {
        'Content-Type': 'application/json',
      };
    }
    
    return dio;
  }
  
  // For Flutter's http package
  static http.Client createHttpClient() {
    // Basic configuration, extend as needed
    return http.Client();
  }
  
  // For Dart's HttpClient
  static Future<HttpClient> createNativeHttpClient() async {
    if (EnvironmentConfig.isDevelopment()) {
      return SSLCertificateLoader.createInsecureHttpClient();
    } else {
      // In production, use the secure client with loaded certificates
      return await SSLCertificateLoader.createSecureHttpClient();
    }
  }
} 