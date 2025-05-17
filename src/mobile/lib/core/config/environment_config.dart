enum Environment { dev, staging, prod }

class EnvironmentConfig {
  static Environment _environment = Environment.dev;

  // Установка текущего окружения
  static void setEnvironment(Environment env) {
    _environment = env;
  }

  // Получение текущего окружения
  static Environment getEnvironment() {
    return _environment;
  }

  // Проверка на окружение разработки
  static bool isDevelopment() {
    return _environment == Environment.dev;
  }

  // Проверка на продакшн
  static bool isProduction() {
    return _environment == Environment.prod;
  }

  // Базовый URL для сервиса пользователей
  static String get userServiceBaseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'http://10.0.2.2:5000/api/v1';
      // return 'https://localhost:7001';
      case Environment.staging:
        return 'https://staging-api.yourapp.com/user-service';
      case Environment.prod:
        return 'https://api.yourapp.com/user-service';
    }
  }
}
