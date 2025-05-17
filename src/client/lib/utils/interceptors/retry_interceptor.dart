import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Function()? onMaxRetriesExceeded;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.onMaxRetriesExceeded,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
      if (retryCount < maxRetries) {
        await Future.delayed(Duration(seconds: 1));
        err.requestOptions.extra['retryCount'] = retryCount + 1;
        try {
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      }
    }

    if (onMaxRetriesExceeded != null) {
      onMaxRetriesExceeded!();
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Повторяем запрос только для определенных ошибок (например, таймаут или сетевая ошибка)
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.unknown;
  }
}
