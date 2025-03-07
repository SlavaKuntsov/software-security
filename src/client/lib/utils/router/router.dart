import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/_auth.dart';
import '../../features/home/_home.dart';
import '../../repositories/auth_repository.dart';
import '../secure_store.dart';

class Routes {
  static const String home = '/';
  static const String auth = '/auth';
}

Route<dynamic> generateRoute(RouteSettings settings) {
  print('Generating route for: ${settings.name}');
  switch (settings.name) {
    case Routes.home:
      return MaterialPageRoute(builder: (context) => MyHomePage());
    case Routes.auth:
      return MaterialPageRoute(builder: (context) => LoginPage());
    default:
      // Если маршрут не найден, возвращаем экран по умолчанию
      return MaterialPageRoute(builder: (context) => LoginPage());
  }
}

Future<String> getInitialRoute() async {
  try {
    final secureStore = SecureStore();
    // final token = await secureStore.get('auth_token');

    final authRepository = GetIt.instance<AuthRepository>();

    final res = await authRepository.auth();

    print('User: $res');

    if (res.data != null) {
      return Routes.home; // Если токен есть, переходим на главный экран
    } else {
      return Routes.auth; // Если токена нет, переходим на экран авторизации
    }
  } catch (e) {
    print('Error checking token: $e');
    return Routes.auth; // В случае ошибки переходим на экран авторизации
  }
}
