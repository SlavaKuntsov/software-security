import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  final storage = FlutterSecureStorage();

  Future<void> write(String key, String data) async {
    await storage.write(key: key, value: data);
  }

  Future<String?> get(String key) async {
    return await storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await storage.delete(key: key);
  }
}
