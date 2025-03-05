import 'package:flutter/material.dart';

import '../../../utils/router/router.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat'), automaticallyImplyLeading: false),
      body: Center(
        child: Container(
          width: 200,
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Main page'),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(Routes.auth);
                },
                child: Text('login back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
