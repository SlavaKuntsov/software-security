import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image(height: 150, image: AssetImage('assets/logos/chat_white.png')),
          Text(
            'Welcome back,',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 7),
          Text(
            'The fastest chat in the world!',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
