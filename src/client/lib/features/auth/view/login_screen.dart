import 'package:client/constants/auth_constants.dart';
import 'package:client/repositories/auth_repository.dart';
import 'package:client/utils/secure_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../../utils/router/router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController(
    text: 'example@email.com',
  );
  TextEditingController passwordController = TextEditingController(
    text: 'qweQWE123',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',

                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () => login(context),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  login(context) async {
    final authRepository = GetIt.instance<AuthRepository>();

    final res = await authRepository.login(
      emailController.text,
      passwordController.text,
    );

    if (!res.isSuccess) {
      print('Error: ${res.errorMessage}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${res.errorMessage}')));

      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Login successful!')));
    Navigator.of(context).pushReplacementNamed(Routes.home);

    await SecureStore().write(
      AuthConstants.access_token,
      res.data!.accessToken,
    );
    await SecureStore().write(
      AuthConstants.refresh_token,
      res.data!.refreshToken,
    );
  }
}
