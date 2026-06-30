abstract class TelegramRepository {
  Future<bool> enviarMensajeTelegram(String chatId, String mensaje, String token);
  Future<bool> verificarToken(String token);
}
