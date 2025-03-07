import 'package:client/constants/auth_constants.dart';
import 'package:client/repositories/auth_repository.dart';
import 'package:client/utils/secure_store.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class AuthInterceptor extends Interceptor {
  final dio = GetIt.instance<Dio>();
  final authRepository = GetIt.instance<AuthRepository>();

  AuthInterceptor();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // secureStore.delete(AuthConstants.access_token);
    // secureStore.delete(AuthConstants.refresh_token);
    final token = await SecureStore().get(AuthConstants.access_token);
    final token2 = await SecureStore().get(AuthConstants.refresh_token);

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    // Если ошибка связана с авторизацией (например, статус 401)
    if (err.response?.statusCode == 401) {
      // Пытаемся обновить токен
      final newToken = await _refreshToken();

      if (newToken != null) {
        // Сохраняем новый токен в SecureStore
        await secureStore.write(AuthConstants.access_token, newToken);

        // Повторяем запрос с новым токеном
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newToken';

        try {
          // Повторяем запрос
          final response = await Dio().fetch(options);
          handler.resolve(response);
        } catch (e) {
          handler.reject(err);
        }
        return;
      }
    }

    // Если токен не удалось обновить, передаем ошибку дальше
    handler.next(err);
  }

  Future<String?> _refreshToken() async {
    // Получаем refresh token из secure store (убедитесь, что вы сохраняете его под этим ключом)
    final refreshToken = await secureStore.get(AuthConstants.refresh_token);
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    // Вызываем API для обновления токена
    final apiResponse = await authRepository.refreshToken(refreshToken);

    // Если запрос успешен и получен новый access token, возвращаем его
    if (apiResponse.data != null) {
      return apiResponse.data!.accessToken;
    }
    return null;
  }
}
