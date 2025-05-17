import 'package:client/utils/router/router.dart';
import 'package:client/utils/service_locator.dart';
import 'package:client/utils/setup_dio.dart';
import 'package:flutter/material.dart';

import 'chat_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupServiceLocator();
  setupDio();

  print('Application start!');
  final auth = await getInitialRoute();
  runApp(ChatApp(initialRoute: auth));
}
