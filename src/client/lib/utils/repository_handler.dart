import 'package:dio/dio.dart';

import '../models/api_response.dart';

class RepositoryHandler {
  Future<ApiResponse<T>> handleResponse<T>(
    Future<Response> request, // Запрос
    T Function(dynamic) fromJson, // Функция для преобразования JSON в объект
  ) async {
    try {
      final response = await request;

      // Успешный ответ
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = fromJson(response.data);
        return ApiResponse.success(data);
      } else {
        // Обработка ошибок (например, 404, 400 и т.д.)
        final errorMessage = response.data['detail'] ?? 'Unknown error';
        return ApiResponse.error(response.statusCode!, errorMessage);
      }
    } on DioException catch (e) {
      // Обработка ошибок Dio (например, сетевые ошибки)
      final errorMessage =
          e.response?.data['detail'] ?? e.message ?? 'Unknown error';
      return ApiResponse.error(e.response?.statusCode ?? 500, errorMessage);
    } catch (e) {
      // Обработка других ошибок
      return ApiResponse.error(500, 'Internal server error');
    }
  }
}
