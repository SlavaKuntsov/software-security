import 'package:client/constants/auth_constants.dart';
import 'package:client/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
    final res = await AuthRepository().login(
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

    final storage = FlutterSecureStorage();

    await storage.write(
      key: AuthConstants.access_token,
      value: res.data?.accessToken,
    );
    await storage.write(
      key: AuthConstants.refresh_token,
      value: res.data?.refreshToken,
    );
  }
}
