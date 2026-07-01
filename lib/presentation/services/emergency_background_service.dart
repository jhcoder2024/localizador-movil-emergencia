import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get_it/get_it.dart';
import 'package:localizador_movil_emergencia/domain/entities/tipo_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/usecases/enviar_ubicacion_usecase.dart';
import 'package:localizador_movil_emergencia/domain/repositories/emergency_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/config_repository.dart';
import 'package:localizador_movil_emergencia/presentation/services/localizador_sonido_service.dart';

Timer? _backgroundTimer;
bool _backgroundActivo = false;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  final locator = GetIt.instance;
  final enviarUbicacion = locator<EnviarUbicacionUseCase>();
  final emergencyRepo = locator<EmergencyRepository>();
  final configRepo = locator<ConfigRepository>();

  service.on('start').listen((event) async {
    if (_backgroundActivo) return;
    _backgroundActivo = true;

    LocalizadorSonidoService.iniciar();

    final tipoIndex = event!['tipoEmergencia'] as int;
    final tipo = TipoEmergencia.values[tipoIndex];

    _backgroundTimer?.cancel();

    final config = await configRepo.obtenerConfiguracion().first;
    final intervalo = Duration(minutes: config.intervaloMinutos);

    // Envío inicial inmediato
    await enviarUbicacion.call(tipo);

    // Envíos periódicos
    _backgroundTimer = Timer.periodic(intervalo, (_) async {
      final estado = await emergencyRepo.obtenerEstado().first;
      if (estado.activa && estado.tipo != null) {
        await enviarUbicacion.call(estado.tipo!);
      }
    });
  });

  service.on('stop').listen((event) {
    _detenerRecursosBackground();
    service.stopSelf();
  });
}

void _detenerRecursosBackground() {
  _backgroundTimer?.cancel();
  _backgroundTimer = null;
  _backgroundActivo = false;
  LocalizadorSonidoService.detener();
}

@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  return true;
}

class EmergencyBackgroundService {
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

  static Future<void> start({required int tipoEmergencia}) async {
    final service = FlutterBackgroundService();
    await service.startService();
    service.invoke('start', {'tipoEmergencia': tipoEmergencia});
  }

  static Future<void> stop() async {
    _detenerRecursosBackground();
    final service = FlutterBackgroundService();
    service.invoke('stop');
  }
}
