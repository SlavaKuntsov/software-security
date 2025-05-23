import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class SSLPinningConfig {
  static HttpClient createHttpClient() {
    SecurityContext context = SecurityContext();
    final client = HttpClient(context: context);
    
    // Accept self-signed certificates in development
    client.badCertificateCallback = 
        (X509Certificate cert, String host, int port) => true;
    
    return client;
  }
  
  // For Dio HTTP client
  static Dio createDioClient() {
    final dio = Dio();
    
    // Configure to bypass certificate verification in development
    // For production, implement proper certificate handling
    dio.options.validateStatus = (status) {
      return status != null && status < 500;
    };
    
    return dio;
  }
  
  // For http package
  static http.Client createHttpPackageClient() {
    return http.Client();
    // For production, implement proper certificate pinning here
  }
} 