class ApiResponse<T> {
  final T? data; // Успешный ответ
  final int? statusCode; // Код ошибки
  final String? errorMessage; // Сообщение об ошибке

  ApiResponse({this.data, this.statusCode, this.errorMessage});

  // Проверка, успешен ли ответ
  bool get isSuccess => statusCode == null;

  // Фабричный метод для успешного ответа
  factory ApiResponse.success(T data) {
    return ApiResponse(data: data);
  }

  // Фабричный метод для ошибки
  factory ApiResponse.error(int statusCode, String errorMessage) {
    return ApiResponse(statusCode: statusCode, errorMessage: errorMessage);
  }
}
