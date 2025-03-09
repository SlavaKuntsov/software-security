import 'package:client/constants/auth_constants.dart';
import 'package:client/utils/secure_store.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../services/auth_service.dart';

class AuthInterceptor extends Interceptor {
  final dio = GetIt.instance<Dio>();
  final authRepository = GetIt.instance<AuthService>();

  AuthInterceptor();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStore().get(AuthConstants.accessToken);

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final newToken = await _refreshToken();

      if (newToken != null) {
        await SecureStore().write(AuthConstants.accessToken, newToken);

        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newToken';

        try {
          final response = await Dio().fetch(options);
          handler.resolve(response);
        } catch (e) {
          handler.reject(err);
        }
        return;
      }
    }

    handler.next(err);
  }

  Future<String?> _refreshToken() async {
    final refreshToken = await SecureStore().get(AuthConstants.refreshToken);
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    final res = await authRepository.refreshToken(refreshToken);

    if (res.data != null) {
      await SecureStore().write(
        AuthConstants.accessToken,
        res.data!.accessToken,
      );
      await SecureStore().write(
        AuthConstants.refreshToken,
        res.data!.refreshToken,
      );

      return res.data!.accessToken;
    }
    return null;
  }
}
