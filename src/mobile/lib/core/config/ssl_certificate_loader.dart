import 'dart:io';
import 'package:flutter/services.dart';

class SSLCertificateLoader {
  // Method to load certificate and create security context
  static Future<SecurityContext> loadCertificate() async {
    final sslCert = await rootBundle.load('assets/certificates/localhost.crt');
    SecurityContext securityContext = SecurityContext.defaultContext;
    securityContext.setTrustedCertificatesBytes(sslCert.buffer.asUint8List());
    return securityContext;
  }
  
  // Configure HttpClient to use the SSL certificates
  static Future<HttpClient> createSecureHttpClient() async {
    final securityContext = await loadCertificate();
    final client = HttpClient(context: securityContext);
    return client;
  }
  
  // Helper method that can be used in development to bypass certificate validation
  // Only use in development, never in production
  static HttpClient createInsecureHttpClient() {
    HttpClient client = HttpClient();
    client.badCertificateCallback = 
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
} 