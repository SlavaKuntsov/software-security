import 'package:client/utils/repository_handler.dart';
import 'package:dio/dio.dart';

import '../models/acccess_token_dto.dart';
import '../models/api_response.dart';

class AuthRepository {
  final Dio _dio = Dio();

  Future<ApiResponse<AccessTokenDTO>> login(
    String email,
    String password,
  ) async {
    return RepositoryHandler().handleResponse<AccessTokenDTO>(
      _dio.post(
        'http://10.0.2.2:5000/auth/login',
        data: {'email': email, 'password': password},
      ),
      (json) =>
          AccessTokenDTO.fromJson(json),
    );
  }
}
