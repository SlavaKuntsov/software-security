import 'package:client/models/user_dto.dart';
import 'package:client/utils/repository_handler.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../models/acccess_token_dto.dart';
import '../models/api_response.dart';

class AuthService {
  final dio = GetIt.instance<Dio>();

  Future<ApiResponse<AccessTokenDTO>> login(
    String email,
    String password,
  ) async {
    return RepositoryHandler().handleResponse<AccessTokenDTO>(
      dio.post('/auth/login', data: {'email': email, 'password': password}),
      (json) => AccessTokenDTO.fromJson(json),
    );
  }

  Future<dynamic> auth() async {
    final response = dio.get('/auth/authorize');
    return RepositoryHandler().handleResponse(
      response,
      (json) => UserDTO.fromJson(json),
    );
  }

  Future<ApiResponse<AccessTokenDTO>> refreshToken(String refreshToken) async {
    return RepositoryHandler().handleResponse<AccessTokenDTO>(
      dio.get(
        '/auth/refresh-token',
        options: Options(headers: {'Cookie': 'yummy-cackes=$refreshToken'}),
      ),
      (json) => AccessTokenDTO.fromJson(json),
    );
  }
}
