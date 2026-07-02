import 'package:flutter_background_service/flutter_background_service.dart';

/// Servicio en primer plano que mantiene la app viva en segundo plano.
/// No ejecuta lógica de negocio (eso lo hace MainProvider).
/// Su única función es evitar que Android mate el proceso,
/// permitiendo que el sonido de alarma y los timers sigan funcionando.
class EmergencyBackgroundService {
  static bool _inicializado = false;

  static Future<void> initialize() async {
    if (_inicializado) return;
    _inicializado = true;

    final service = FlutterBackgroundService();
    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: (_) => true,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'emergency_channel',
        initialNotificationTitle: 'Localizador de Emergencia',
        initialNotificationContent: 'Emergencia activa',
        foregroundServiceNotificationId: 1002,
      ),
    );
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) {
    // Este servicio solo mantiene el proceso vivo.
    // No necesita dependencias de GetIt.
    service.on('stop').listen((event) {
      service.stopSelf();
    });
  }

  static Future<void> start() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  static Future<void> stop() async {
    final service = FlutterBackgroundService();
    service.invoke('stop');
  }
}
