import 'package:client/models/user_dto.dart';
import 'package:client/utils/repository_handler.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constants/auth_constants.dart';
import '../models/acccess_token_dto.dart';
import '../models/api_response.dart';
import '../models/google_auth.dart';
import '../utils/secure_store.dart';

class AuthService {
  final dio = GetIt.instance<Dio>();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  Future<ApiResponse<AccessTokenDTO>> login(
    String email,
    String password,
  ) async {
    return RepositoryHandler().handleResponse<AccessTokenDTO>(
      dio.post('/auth/login', data: {'email': email, 'password': password}),
      (json) => AccessTokenDTO.fromJson(json),
    );
  }

  Future<ApiResponse<GoogleAuthResult>> googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final response = await RepositoryHandler()
          .handleResponse<Map<String, dynamic>>(
            dio.get(
              '/auth/google-response',
              options: Options(
                headers: {'Authorization': 'Bearer ${googleAuth.idToken}'},
              ),
            ),
            (json) => json,
          );

      if (response.data == null || response.data!['authResultDto'] == null) {
        throw Exception('Invalid response from server');
      }

      final result = GoogleAuthResult(
        text: response.data!['text'] as String,
        user: UserDTO.fromJson(response.data!['user']),
        tokens: AccessTokenDTO.fromJson(response.data!['authResultDto']),
      );

      // Сохраняем токены сразу в сервисе
      await _saveTokens(result.tokens);

      return ApiResponse<GoogleAuthResult>(
        data: result,
        statusCode: response.statusCode,
        errorMessage: response.errorMessage,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveTokens(AccessTokenDTO tokens) async {
    await SecureStore().write(AuthConstants.accessToken, tokens.accessToken);
    await SecureStore().write(AuthConstants.refreshToken, tokens.refreshToken);
  }

  Future<ApiResponse<UserDTO>> auth() async {
    return RepositoryHandler().handleResponse<UserDTO>(
      dio.get('/auth/authorize'),
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

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    // Дополнительные действия по выходу
  }
}
