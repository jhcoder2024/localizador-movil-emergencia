import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageDataSource {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> setTelegramToken(String token) async =>
      await _storage.write(key: 'telegram_token', value: token);

  Future<String?> getTelegramToken() async =>
      await _storage.read(key: 'telegram_token');

  Future<void> deleteTelegramToken() async =>
      await _storage.delete(key: 'telegram_token');

  Future<void> clear() async => await _storage.deleteAll();
}
