import 'package:client/router/router.dart';
import 'package:flutter/material.dart';

import 'chat_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp(initialRoute: Routes.auth));
}
