import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:localizador_movil_emergencia/domain/entities/tipo_emergencia.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Canal para notificaciones del localizador activo
    const localizadorChannel = AndroidNotificationChannel(
      'localizador_channel',
      'Localizador',
      description: 'Notificaciones del localizador activo',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(localizadorChannel);

    // Canal para el foreground service (emergency_channel)
    // Este canal es usado por flutter_background_service para la notificación permanente
    const emergencyChannel = AndroidNotificationChannel(
      'emergency_channel',
      'Emergencia',
      description: 'Notificación permanente del servicio de emergencia',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(emergencyChannel);
  }

  static Future<void> showEmergencyNotification({
    required TipoEmergencia tipo,
    required String tiempoTranscurrido,
  }) async {
    await _plugin.show(
      1001,
      '🚨 Localizador activo - ${tipo.displayName}',
      'Tiempo: $tiempoTranscurrido',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'localizador_channel',
          'Localizador',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
        ),
      ),
    );
  }

  static Future<void> cancelNotification() async {
    await _plugin.cancel(1001);
  }
}
