class AppConstants {
  AppConstants._();

  static const String appName = 'Localizador Móvil de Emergencia';
  static const String appVersion = '1.0.0';
  static const int defaultIntervaloSegundos = 30;
  static const int minIntervaloSegundos = 10;
  static const int maxIntervaloSegundos = 300;
  static const String smsMensajeDefault = '¡EMERGENCIA! Necesito ayuda. Mi ubicación: ';
  static const String telegramMensajeDefault = '🚨 *ALERTA DE EMERGENCIA*\n\nNecesito ayuda urgente.\n\nMi ubicación: ';
  static const String whatsappMensajeDefault = '🚨 EMERGENCIA - Necesito ayuda. Mi ubicación: ';
  static const String dbName = 'localizador_emergencia.db';
}
