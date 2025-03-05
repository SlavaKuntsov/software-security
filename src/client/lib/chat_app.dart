import 'package:client/utils/router/router.dart';
import 'package:client/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  final String initialRoute;

  MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      onGenerateRoute: generateRoute,
    );
  }
}
