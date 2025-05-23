enum Environment { dev, prod }

class EnvironmentConfig {
  static Environment _environment = Environment.dev;
  static String ipAddress = "192.168.0.103";

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
        return 'http://$ipAddress:5000/api/v1';
      case Environment.prod:
        return 'https://$ipAddress:5001/api/v1';
    }
  }
  
  // Путь к папке с сертификатами
  static String get sslCertPath {
    return 'assets/certificates';
  }
}
