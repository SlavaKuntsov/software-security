import 'package:client/utils/interceptors/auth_interceptor.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:get_it/get_it.dart';

import 'interceptors/retry_interceptor.dart';

void setupDio() {
  final cookieJar = CookieJar();
  final dio = GetIt.instance<Dio>();

  dio.interceptors.add(RetryInterceptor(dio: dio, maxRetries: 3));
  dio.interceptors.add(AuthInterceptor());
  dio.interceptors.add(CookieManager(cookieJar));
}
