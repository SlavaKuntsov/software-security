import 'package:client/repositories/auth_repository.dart';
import 'package:client/utils/secure_store.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'auth_interceptor.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerSingleton<Dio>(Dio());
  getIt.registerSingleton<AuthRepository>(AuthRepository());
  getIt.registerSingleton<AuthInterceptor>(AuthInterceptor());
}
