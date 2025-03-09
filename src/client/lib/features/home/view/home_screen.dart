import 'package:client/constants/auth_constants.dart';
import 'package:client/utils/secure_store.dart';
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
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Main page'),
              ElevatedButton(
                onPressed: () {
                  logout(context);
                },
                child: Text('logout'),
              ),
              ElevatedButton(
                onPressed:
                    () => SecureStore().delete(AuthConstants.accessToken),
                child: Text('delete access'),
              ),
              ElevatedButton(
                onPressed:
                    () => SecureStore().delete(AuthConstants.refreshToken),
                child: Text('delete refresh'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  logout(context) async {
    await SecureStore().delete(AuthConstants.accessToken);
    await SecureStore().delete(AuthConstants.refreshToken);

    Navigator.of(context).pushReplacementNamed(Routes.auth);
  }
}
