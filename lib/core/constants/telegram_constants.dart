class TelegramConstants {
  TelegramConstants._();

  static const String baseUrl = 'https://api.telegram.org/bot';
  static const String metodoEnviarMensaje = '/sendMessage';
  static const String metodoEnviarUbicacion = '/sendLocation';
  static const String metodoVerificarToken = '/getMe';
  static const String contentType = 'application/json';
  static const int timeoutSegundos = 15;
}
