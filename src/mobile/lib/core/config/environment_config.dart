enum Environment { dev, prod }

class EnvironmentConfig {
  static Environment _environment = Environment.dev;
  static String ipAddress = "192.168.0.104";
  static int port = 5001;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static Environment getEnvironment() {
    return _environment;
  }

  static bool isDevelopment() {
    return _environment == Environment.dev;
  }

  static bool isProduction() {
    return _environment == Environment.prod;
  }

  static String get baseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'https://$ipAddress:$port/api/v1';
      case Environment.prod:
        return 'https://$ipAddress:$port/api/v1';
    }
  }
  
  // URL для WebSocket подключений SignalR
  static String get wsUrl {
    switch (_environment) {
      case Environment.dev:
        // В WSS протоколе нужно указывать полный URL
        return 'wss://$ipAddress:$port/api/v1';
      case Environment.prod:
        return 'wss://$ipAddress:$port/api/v1';
    }
  }
  
  // Путь к папке с сертификатами
  static String get sslCertPath {
    return 'assets/certificates';
  }
}
