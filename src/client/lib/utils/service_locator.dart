import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../services/auth_service.dart';
import 'interceptors/auth_interceptor.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:5000/api/v1',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  getIt.registerSingleton<Dio>(dio);
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<AuthInterceptor>(AuthInterceptor());
}
