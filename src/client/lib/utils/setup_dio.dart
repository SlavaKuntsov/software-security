import 'package:client/utils/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:get_it/get_it.dart';


void setupDio() {
  final cookieJar = CookieJar();
  final dio = GetIt.instance<Dio>();

  dio.interceptors.add(AuthInterceptor());
  dio.interceptors.add(CookieManager(cookieJar));
}