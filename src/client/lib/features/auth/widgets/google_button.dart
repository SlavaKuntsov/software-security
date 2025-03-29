import 'package:client/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../constants/auth_constants.dart';
import '../../../utils/secure_store.dart';

class GoogleButton extends StatelessWidget {
  final Function(String text)? onSuccess;
  final Function(String error)? onError;

  const GoogleButton({super.key, this.onSuccess, this.onError});

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      final authService = GetIt.instance<AuthService>();
      final response = await authService.googleSignIn();

      if (response.data != null) {
        final result = response.data!;
        onSuccess?.call(result.text ?? 'Google login successful');

        print(result);

        // Сохраняем токены
        await SecureStore().write(
          AuthConstants.accessToken,
          result.tokens.accessToken,
        );
        await SecureStore().write(
          AuthConstants.refreshToken,
          result.tokens.refreshToken,
        );

        // Здесь можно добавить дополнительную обработку:
        // - Сохранить пользователя (result.user)
        // - Обновить состояние приложения
      }
    } catch (error) {
      onError?.call(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _handleSignIn(context),
      icon: Image(image: AssetImage('assets/icons/google.png')),
    );
  }
}
