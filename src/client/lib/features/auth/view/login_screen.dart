// import 'package:firebase_auth/firebase_auth.dart';
import 'package:client/features/auth/widgets/google_button.dart';
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
                    child: GoogleButton(),
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
