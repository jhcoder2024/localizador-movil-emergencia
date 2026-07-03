import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:localizador_movil_emergencia/core/utils/permission_utils.dart';
import 'package:localizador_movil_emergencia/domain/entities/configuracion.dart';
import 'package:localizador_movil_emergencia/domain/entities/estado_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/entities/tipo_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/repositories/emergency_repository.dart';
import 'package:localizador_movil_emergencia/domain/usecases/activar_emergencia_usecase.dart';
import 'package:localizador_movil_emergencia/domain/usecases/cancelar_emergencia_usecase.dart';
import 'package:localizador_movil_emergencia/domain/usecases/enviar_ubicacion_usecase.dart';
import 'package:localizador_movil_emergencia/domain/usecases/obtener_configuracion_usecase.dart';
import 'package:localizador_movil_emergencia/presentation/services/emergency_background_service.dart';
import 'package:localizador_movil_emergencia/presentation/services/localizador_sonido_service.dart';
import 'package:localizador_movil_emergencia/presentation/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class MainProvider extends ChangeNotifier {
  final ActivarEmergenciaUseCase _activarEmergencia;
  final CancelarEmergenciaUseCase _cancelarEmergencia;
  final EnviarUbicacionUseCase _enviarUbicacion;
  final ObtenerConfiguracionUseCase _obtenerConfiguracion;
  final EmergencyRepository _emergencyRepository;

  Timer? _envioPeriodicoTimer;

  MainProvider({
    required ActivarEmergenciaUseCase activarEmergencia,
    required CancelarEmergenciaUseCase cancelarEmergencia,
    required EnviarUbicacionUseCase enviarUbicacion,
    required ObtenerConfiguracionUseCase obtenerConfiguracion,
    required EmergencyRepository emergencyRepository,
  })  : _activarEmergencia = activarEmergencia,
        _cancelarEmergencia = cancelarEmergencia,
        _enviarUbicacion = enviarUbicacion,
        _obtenerConfiguracion = obtenerConfiguracion,
        _emergencyRepository = emergencyRepository;

  EstadoEmergencia _estado = const EstadoEmergencia();
  Configuracion _configuracion = const Configuracion();
  bool _cargando = false;
  String? _error;
  bool _mostrarDialogoConfirmacion = false;
  TipoEmergencia? _tipoPendiente;
  bool _autoEjecutando = false;
  bool _ubicacionDenegada = false;
  bool _smsDenegado = false;
  StreamSubscription? _estadoSub;
  StreamSubscription? _configSub;

  EstadoEmergencia get estado => _estado;
  Configuracion get configuracion => _configuracion;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get mostrarDialogo => _mostrarDialogoConfirmacion;
  TipoEmergencia? get tipoPendiente => _tipoPendiente;
  bool get autoEjecutando => _autoEjecutando;
  bool get ubicacionDenegada => _ubicacionDenegada;
  bool get smsDenegado => _smsDenegado;
  bool get contactosFaltantes =>
      _configuracion.contactos.isEmpty;
  bool get hayAdvertencias =>
      _ubicacionDenegada || contactosFaltantes;

  Future<void> init() async {
    if (_estadoSub != null) return;
    _estadoSub = _emergencyRepository.obtenerEstado().listen((estado) {
      _estado = estado;
      notifyListeners();
    });
    _configSub = _obtenerConfiguracion().listen((config) {
      _configuracion = config;
      notifyListeners();
    });
    await _verificarPermisos();
  }

  Future<void> _verificarPermisos() async {
    // Verificar ubicación
    _ubicacionDenegada = !await PermissionUtils.checkLocationPermission();
    if (_ubicacionDenegada) {
      // Solicitar permiso de ubicación
      final otorgado = await PermissionUtils.requestLocationPermission();
      _ubicacionDenegada = !otorgado;
    }
    
    // Verificar SMS
    _smsDenegado = !await PermissionUtils.checkSmsPermission();
    if (_smsDenegado) {
      await PermissionUtils.requestSmsPermission();
      _smsDenegado = !await PermissionUtils.checkSmsPermission();
    }
    
    notifyListeners();
  }

  Future<void> reverificarPermisos() async {
    await _verificarPermisos();
  }

  void solicitarConfirmacion(TipoEmergencia tipo) {
    _tipoPendiente = tipo;
    _mostrarDialogoConfirmacion = true;
    notifyListeners();
  }

  void cancelarDialogo() {
    _mostrarDialogoConfirmacion = false;
    _tipoPendiente = null;
    _autoEjecutando = false;
    notifyListeners();
  }

  Future<void> confirmarEmergencia() async {
    if (_tipoPendiente == null) return;
    _autoEjecutando = true;
    _cargando = true;
    _mostrarDialogoConfirmacion = false;
    notifyListeners();

    try {
      await _activarEmergencia.call(_tipoPendiente!);
      // Primer sonido con duración = mitad del intervalo
      final duracionSonido = (_configuracion.intervaloMinutos * 60) ~/ 2;
      LocalizadorSonidoService.iniciar(duracionSegundos: duracionSonido);

      // Iniciar foreground service para mantener la app en segundo plano
      try {
        await EmergencyBackgroundService.start();
      } catch (e) {
        debugPrint('[MainProvider] Error al iniciar foreground service: $e');
      }

      // Configurar callbacks de la notificación
      NotificationService.onCancelEmergencia = () {
        cancelarEmergenciaActual();
      };
      // Solicitar permiso de notificaciones (Android 14+)
      try {
        await Permission.notification.request();
      } catch (e) {
        debugPrint('[MainProvider] Error solicitando permiso notificación: $e');
      }

      // Mostrar notificación permanente
      try {
        await NotificationService.showEmergencyNotification(
          tipo: _tipoPendiente!,
          tiempoTranscurrido: '0h 0m',
        );
      } catch (e) {
        debugPrint('[MainProvider] Error al mostrar notificación: $e');
      }

      // Envío inicial inmediato
      try {
        await _enviarUbicacion.call(_tipoPendiente!);
      } catch (e) {
        debugPrint('[MainProvider] Error en envío inicial: $e');
        // Si falla por timeout de ubicación, verificar permisos
        if (e.toString().contains('Timeout') || e.toString().contains('location')) {
          _ubicacionDenegada = true;
          notifyListeners();
        }
      }

      // Iniciar envíos periódicos
      _iniciarEnviosPeriodicos(_tipoPendiente!);

      _error = null;
    } catch (e) {
      _error = 'Error al activar emergencia: $e';
    }

    _cargando = false;
    _tipoPendiente = null;
    _autoEjecutando = false;
    notifyListeners();
  }

  void _iniciarEnviosPeriodicos(TipoEmergencia tipo) {
    _envioPeriodicoTimer?.cancel();
    final intervalo = Duration(minutes: _configuracion.intervaloMinutos);
    debugPrint('[MainProvider] Envíos periódicos cada ${_configuracion.intervaloMinutos} minuto(s)');

    _envioPeriodicoTimer = Timer.periodic(intervalo, (_) async {
      // Usar _estado cacheado en lugar de obtenerEstado().first que se cuelga
      if (_estado.activa && _estado.tipo != null) {
        debugPrint('[MainProvider] Enviando ubicación periódica...');
        await _enviarUbicacion.call(_estado.tipo!);

        // Reiniciar sonido con duración = mitad del intervalo
        final duracionSonido = (_configuracion.intervaloMinutos * 60) ~/ 2;
        LocalizadorSonidoService.iniciar(duracionSegundos: duracionSonido);
        debugPrint('[MainProvider] Sonido reactivado por ${duracionSonido}s');

        // Actualizar tiempo en el estado
        if (_estado.inicioTimestamp != null) {
          final diff = DateTime.now().difference(_estado.inicioTimestamp!);
          final tiempo = '${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
          try {
            await NotificationService.updateNotificationTime(tiempo);
          } catch (e) {
            debugPrint('[MainProvider] Error actualizando notificación: $e');
          }
        }
      } else {
        debugPrint('[MainProvider] Emergencia ya no activa, deteniendo envíos periódicos');
        _envioPeriodicoTimer?.cancel();
      }
    });
  }

  /// Obtiene el intervalo actual de envíos en minutos
  int get intervaloMinutos => _configuracion.intervaloMinutos;

  Future<void> cancelarEmergenciaActual() async {
    try {
      _envioPeriodicoTimer?.cancel();
      _envioPeriodicoTimer = null;

      await _cancelarEmergencia.call();

      try {
        await EmergencyBackgroundService.stop();
      } catch (e) {
        debugPrint('[MainProvider] Error al detener foreground service: $e');
      }

      LocalizadorSonidoService.detener();

      try {
        await NotificationService.cancelNotification();
      } catch (e) {
        debugPrint('[MainProvider] Error al cancelar notificación: $e');
      }
    } catch (e) {
      _error = 'Error al cancelar emergencia: $e';
      notifyListeners();
    }
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _envioPeriodicoTimer?.cancel();
    _estadoSub?.cancel();
    _configSub?.cancel();
    super.dispose();
  }
}
