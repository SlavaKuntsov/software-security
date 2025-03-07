import 'package:client/utils/router/router.dart';
import 'package:client/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

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

  //
  // @override
  // Widget build(BuildContext context) {
  //   return FutureBuilder<String>(
  //     future: getInitialRoute(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return MaterialApp(
  //           home: Scaffold(body: Center(child: CircularProgressIndicator())),
  //         );
  //       } else {
  //         print(snapshot.data);
  //         final initialRoute = snapshot.data ?? Routes.auth;
  //         print(initialRoute);
  //         return MaterialApp(
  //           title: 'Flutter Demo',
  //           theme: darkTheme,
  //           debugShowCheckedModeBanner: false,
  //           initialRoute: initialRoute,
  //           onGenerateRoute: (settings) {
  //             print("Navigating to: ${settings.name}");
  //             return generateRoute(settings);
  //           },
  //         );
  //       }
  //     },
  //   );
  // }
}
