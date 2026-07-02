import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:localizador_movil_emergencia/domain/entities/tipo_emergencia.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Callback que se ejecuta cuando el usuario toca "Cancelar" en la notificación
  static VoidCallback? onCancelEmergencia;

  /// Callback que se ejecuta cuando el usuario toca la notificación (vuelve a la app)
  static VoidCallback? onNotificationTapped;

  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    // Handler para cuando el usuario interactúa con la notificación
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationResponse,
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

  /// Maneja la respuesta cuando el usuario toca una acción de la notificación
  static void _onNotificationResponse(NotificationResponse response) {
    debugPrint('[NotificationService] Acción: ${response.actionId}, payload: ${response.payload}');

    if (response.actionId == 'cancelar_emergencia') {
      onCancelEmergencia?.call();
    } else if (response.actionId == 'reenviar_sms') {
      onNotificationTapped?.call();
    }
  }

  static Future<void> showEmergencyNotification({
    required TipoEmergencia tipo,
    required String tiempoTranscurrido,
  }) async {
    // Acciones de la notificación
    final reenviarAction = AndroidNotificationAction(
      'reenviar_sms',
      'RE-ENVIAR SMS',
      showsUserInterface: true,
    );
    final cancelAction = AndroidNotificationAction(
      'cancelar_emergencia',
      'CANCELAR',
      showsUserInterface: true,
      cancelNotification: true,
    );

    await _plugin.show(
      1001,
      '🚨 Localizador activo - ${tipo.displayName}',
      'Tiempo: $tiempoTranscurrido — Toca para re-enviar SMS',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'localizador_channel',
          'Localizador',
          importance: Importance.high,
          priority: Priority.high,
          ongoing: true,
          autoCancel: false,
          actions: [reenviarAction, cancelAction],
        ),
      ),
      payload: 'emergencia_activa',
    );
  }

  /// Actualiza la notificación con el tiempo transcurrido
  static Future<void> updateNotificationTime(String tiempo) async {
    await _plugin.show(
      1001,
      '🚨 LOCALIZADOR ACTIVO',
      'Tiempo: $tiempo — Toca para re-enviar SMS',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'localizador_channel',
          'Localizador',
          importance: Importance.high,
          priority: Priority.high,
          ongoing: true,
          autoCancel: false,
        ),
      ),
      payload: 'emergencia_activa',
    );
  }

  static Future<void> cancelNotification() async {
    await _plugin.cancel(1001);
  }
}
