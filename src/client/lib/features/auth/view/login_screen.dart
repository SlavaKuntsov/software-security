import 'package:flutter/material.dart';

import '../widgets/_widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 20, bottom: 50, right: 30, left: 30),
          child: Column(
            children: [
              /// Header
              LoginHeader(),

              /// Form
              LoginForm(),

              /// Divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Divider(
                        color: Colors.white38,
                        thickness: 0.5,
                        indent: 60,
                        endIndent: 5,
                      ),
                    ),
                    Text(
                      'Or Sign In With',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    Flexible(
                      child: Divider(
                        color: Colors.white38,
                        thickness: 0.5,
                        indent: 5,
                        endIndent: 60,
                      ),
                    ),
                  ],
                ),
              ),

              /// Google
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white30),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Image(
                        image: AssetImage('assets/icons/google.png'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   TextEditingController emailController = TextEditingController(
//     text: 'example@email.com',
//   );
//   TextEditingController passwordController = TextEditingController(
//     text: 'qweQWE123',
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('Login'),
//         automaticallyImplyLeading: false,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(
//                 labelText: 'Email',
//
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             TextField(
//               controller: passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: 'Password',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 24.0),
//             ElevatedButton(
//               onPressed: () => login(context),
//               child: const Text('Login'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   login(context) async {
//     final authRepository = GetIt.instance<AuthService>();
//
//     final res = await authRepository.login(
//       emailController.text,
//       passwordController.text,
//     );
//
//     if (!res.isSuccess) {
//       print('Error: ${res.errorMessage}');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: ${res.errorMessage}')));
//
//       return;
//     }
//
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('Login successful!')));
//     Navigator.of(context).pushReplacementNamed(Routes.home);
//
//     await SecureStore().write(
//       AuthConstants.access_token,
//       res.data!.accessToken,
//     );
//     await SecureStore().write(
//       AuthConstants.refresh_token,
//       res.data!.refreshToken,
//     );
//   }
// }
