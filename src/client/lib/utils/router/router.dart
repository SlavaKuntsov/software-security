import 'package:flutter/material.dart';

import '../../features/auth/_auth.dart';
import '../../features/home/_home.dart';

class Routes {
  static const String home = '/';
  static const String auth = '/auth';
}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.home:
      return MaterialPageRoute(builder: (context) => MyHomePage());
    case Routes.auth:
      return MaterialPageRoute(builder: (context) => LoginPage());
    default:
      return MaterialPageRoute(builder: (context) => MyHomePage());
  }
}
