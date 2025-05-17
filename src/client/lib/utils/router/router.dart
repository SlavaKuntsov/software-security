import 'package:client/constants/auth_constants.dart';
import 'package:client/utils/secure_store.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/_auth.dart';
import '../../features/home/_home.dart';
import '../../services/auth_service.dart';

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
      return MaterialPageRoute(builder: (context) => LoginScreen());
    default:
      return MaterialPageRoute(builder: (context) => LoginScreen());
  }
}

Future<String> getInitialRoute() async {
  try {
    final authRepository = GetIt.instance<AuthService>();

    final access = await SecureStore().get(AuthConstants.accessToken);
    final refresh = await SecureStore().get(AuthConstants.refreshToken);

    print(access);
    print(refresh);

    final res = await authRepository.auth();

    print('User: $res');

    if (res.data != null) {
      return Routes.home;
    } else {
      return Routes.auth;
    }
  } catch (e) {
    print('Error checking token: $e');

    return Routes.auth;
  }
}
