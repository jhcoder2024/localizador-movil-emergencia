import 'package:dio/dio.dart';
import 'package:localizador_movil_emergencia/data/models/telegram_dto.dart';

class TelegramRemoteDataSource {
  final Dio _dio;

  TelegramRemoteDataSource(this._dio);

  Future<SendMessageResponse> sendMessage(
      String token, SendMessageRequest request) async {
    final response = await _dio.post(
      'https://api.telegram.org/bot$token/sendMessage',
      data: request.toJson(),
    );
    return SendMessageResponse.fromJson(response.data);
  }

  Future<bool> verifyToken(String token) async {
    try {
      final response =
          await _dio.get('https://api.telegram.org/bot$token/getMe');
      return response.data['ok'] == true;
    } catch (_) {
      return false;
    }
  }
}
