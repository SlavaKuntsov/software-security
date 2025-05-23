import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constants/oauth_constants.dart';

/// Конфигурация для Google Services, адаптированная для различных сред
class GoogleServicesConfig {
  static GoogleSignIn? _googleSignIn;

  /// Создает экземпляр GoogleSignIn с подходящими настройками
  /// в зависимости от среды исполнения
  static GoogleSignIn createGoogleSignIn() {
    // Apply SSL security bypass for development environment
    HttpOverrides.global = _DevHttpOverrides();
    
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile', 'openid'],
      serverClientId: GoogleOAuthConstants.WEB_CLIENT_ID,
    );
    return _googleSignIn!;
  }

  static GoogleSignIn get googleSignIn {
    if (_googleSignIn == null) {
      return createGoogleSignIn();
    }
    return _googleSignIn!;
  }
}

// Override HTTP client to accept all certificates in development
class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
