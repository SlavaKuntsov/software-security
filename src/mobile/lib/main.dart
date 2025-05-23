import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'core/config/environment_config.dart';
import 'core/config/google_services_config.dart';
import 'core/constants/app_constants.dart';
import 'core/network/secure_http_client.dart';
import 'di/injection_container.dart' as di;
import 'domain/entities/custom_notification.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/navigation_screen.dart';
import 'presentation/screens/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure environment and security
  EnvironmentConfig.setEnvironment(Environment.dev);
  SecureHttpClient.configureSecurity();

  await di.init();

  GoogleServicesConfig.createGoogleSignIn();

  final authProvider = di.sl<AuthProvider>();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<ThemeProvider>()),
        ChangeNotifierProvider(
          create: (_) {
            // Добавляем слушатель для отслеживания изменений статуса аутентификации
            authProvider.addListener(() {
              // Если статус изменился на 'не аутентифицирован' и есть сообщение об ошибке
              if (authProvider.authStatus == AuthStatus.unauthenticated &&
                  authProvider.errorMessage != null &&
                  authProvider.errorMessage!.contains('сессия истекла')) {
                // Показываем сообщение и перенаправляем на экран входа
                _handleSessionExpired(authProvider.errorMessage!);
              }
            });
            return authProvider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// Обработка истечения сессии - показывает сообщение и перенаправляет на экран входа
void _handleSessionExpired(String message) {
  final context = navigatorKey.currentContext;
  if (context != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  void _showNotificationSnackBar(CustomNotification notification) {
    Color backgroundColor;

    switch (notification.type.toLowerCase()) {
      case 'success':
        backgroundColor = Colors.green;
        break;
      case 'error':
        backgroundColor = Colors.red;
        break;
      case 'warn':
        backgroundColor = Colors.orange;
        break;
      case 'info':
      default:
        backgroundColor = Colors.blue;
        break;
    }

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(notification.message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Закрыть',
          textColor: Colors.white,
          onPressed: () {
            scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const NavigationScreen(),
      },
    );
  }
}
