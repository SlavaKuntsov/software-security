import 'dart:convert';

import 'package:client/models/user_dto.dart';
import 'package:client/utils/repository_handler.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../models/acccess_token_dto.dart';
import '../models/api_response.dart';

class AuthRepository {
  final dio = GetIt.instance<Dio>();

  Future<ApiResponse<AccessTokenDTO>> login(
    String email,
    String password,
  ) async {
    return RepositoryHandler().handleResponse<AccessTokenDTO>(
      dio.post(
        'http://10.0.2.2:5000/auth/login',
        data: {'email': email, 'password': password},
      ),
      (json) => AccessTokenDTO.fromJson(json),
    );
  }

  Future<dynamic> auth() async {
    // Ожидаем завершения запроса
    final response = dio.get('http://10.0.2.2:5000/auth/authorize');
    return RepositoryHandler().handleResponse(
      response, // Передаем Response, а не Future<Response>
          (json) => UserDTO.fromJson(json),
    );
  }

  Future<ApiResponse<AccessTokenDTO>> refreshToken(String refreshToken) async {
    return RepositoryHandler().handleResponse<AccessTokenDTO>(
      dio.get('http://10.0.0.2:5000/auth/refresh-token'),
      (json) => AccessTokenDTO.fromJson(json),
    );
  }
}
