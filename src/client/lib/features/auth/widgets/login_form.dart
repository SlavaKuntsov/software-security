import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../constants/auth_constants.dart';
import '../../../services/auth_service.dart';
import '../../../utils/router/router.dart';
import '../../../utils/secure_store.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController emailController = TextEditingController(
    text: 'example@email.com',
  );
  TextEditingController passwordController = TextEditingController(
    text: 'qweQWE123',
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 40),
      child: Form(
        child: Column(
          children: [
            TextFormField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.send),
                labelText: 'Login',
              ),
            ),

            const SizedBox(height: 18),

            TextFormField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.password),
                suffixIcon: Icon(Icons.remove_red_eye),
                labelText: 'Password',
              ),
            ),

            const SizedBox(height: 24),

            /// Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('Sign In', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('Registration', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  login(context) async {
    final authRepository = GetIt.instance<AuthService>();

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

    await SecureStore().write(AuthConstants.accessToken, res.data!.accessToken);
    await SecureStore().write(
      AuthConstants.refreshToken,
      res.data!.refreshToken,
    );
  }
}
