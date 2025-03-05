import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  final storage = FlutterSecureStorage();

  Future<void> write(String key, String data) async {
    await storage.write(key: 'auth_token', value: data);
  }

  Future<String?> get(String key) async {
    return await storage.read(key: 'auth_token');
  }

  Future<void> delete(String key) async {
    await storage.delete(key: 'auth_token');
  }
}
