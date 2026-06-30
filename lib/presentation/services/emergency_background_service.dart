import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get_it/get_it.dart';
import 'package:localizador_movil_emergencia/domain/entities/tipo_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/usecases/enviar_ubicacion_usecase.dart';
import 'package:localizador_movil_emergencia/domain/repositories/emergency_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/config_repository.dart';
import 'package:localizador_movil_emergencia/presentation/services/localizador_sonido_service.dart';

class EmergencyBackgroundService with WidgetsBindingObserver {
  static Timer? _timer;
  static bool _activo = false;

  static Future<void> initialize() async {
    final service = FlutterBackgroundService();
    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'emergency_channel',
        initialNotificationTitle: 'Localizador de Emergencia',
        initialNotificationContent: 'Emergencia activa',
        foregroundServiceNotificationId: 1001,
      ),
    );
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) {
    final locator = GetIt.instance;
    final enviarUbicacion = locator<EnviarUbicacionUseCase>();
    final emergencyRepo = locator<EmergencyRepository>();
    final configRepo = locator<ConfigRepository>();

    service.on('start').listen((event) async {
      if (_activo) return;
      _activo = true;

      LocalizadorSonidoService.iniciar();

      final tipoIndex = event!['tipoEmergencia'] as int;
      final tipo = TipoEmergencia.values[tipoIndex];

      _timer?.cancel();

      final config = await configRepo.obtenerConfiguracion().first;
      final intervalo = Duration(minutes: config.intervaloMinutos);

      // Envío inicial inmediato
      await enviarUbicacion.call(tipo);

      // Envíos periódicos con Timer (no Stream.periodic, más eficiente)
      _timer = Timer.periodic(intervalo, (_) async {
        final estado = await emergencyRepo.obtenerEstado().first;
        if (estado.activa && estado.tipo != null) {
          await enviarUbicacion.call(estado.tipo!);
        }
      });
    });

    service.on('stop').listen((event) {
      _detenerRecursos();
      service.stopSelf();
    });
  }

  static void _detenerRecursos() {
    _timer?.cancel();
    _timer = null;
    _activo = false;
    LocalizadorSonidoService.detener();
    // GPS y wakelock se liberan automáticamente al detener el foreground service
  }

  @pragma('vm:entry-point')
  static bool onIosBackground(ServiceInstance service) {
    return true;
  }

  static Future<void> start({required int tipoEmergencia}) async {
    final service = FlutterBackgroundService();
    await service.startService();
    service.invoke('start', {'tipoEmergencia': tipoEmergencia});
  }

  static Future<void> stop() async {
    _detenerRecursos();
    final service = FlutterBackgroundService();
    service.invoke('stop');
  }
}
