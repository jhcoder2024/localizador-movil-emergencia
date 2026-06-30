import 'package:flutter/foundation.dart';
import 'package:localizador_movil_emergencia/data/datasources/remote/telegram_remote_datasource.dart';
import 'package:localizador_movil_emergencia/data/models/telegram_dto.dart';
import 'package:localizador_movil_emergencia/domain/repositories/telegram_repository.dart';

class TelegramRepositoryImpl implements TelegramRepository {
  final TelegramRemoteDataSource _remoteDataSource;

  TelegramRepositoryImpl(this._remoteDataSource);

  @override
  Future<bool> enviarMensajeTelegram(
      String chatId, String mensaje, String token) async {
    try {
      final request = SendMessageRequest(
        chatId: chatId,
        text: mensaje,
      );
      final response = await _remoteDataSource.sendMessage(token, request);
      return response.ok;
    } catch (e) {
      debugPrint('[TelegramRepository] Error: $e');
      return false;
    }
  }

  @override
  Future<bool> verificarToken(String token) async {
    return _remoteDataSource.verifyToken(token);
  }
}
