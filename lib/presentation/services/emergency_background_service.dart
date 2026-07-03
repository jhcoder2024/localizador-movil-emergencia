import 'package:flutter_background_service/flutter_background_service.dart';

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
    // Es OBLIGATORIO llamar a setAsForegroundService inmediatamente
    // para que Android no mate el servicio
    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
      service.setForegroundNotificationInfo(
        title: '🚨 Localizador de Emergencia',
        content: 'Emergencia activa - Seguimiento en segundo plano',
      );
    }

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
