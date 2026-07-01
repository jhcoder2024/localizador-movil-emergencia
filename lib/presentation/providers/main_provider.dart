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
import 'package:localizador_movil_emergencia/presentation/services/localizador_sonido_service.dart';
import 'package:localizador_movil_emergencia/presentation/services/notification_service.dart';

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
    _ubicacionDenegada = !await PermissionUtils.checkLocationPermission();
    _smsDenegado = !await PermissionUtils.checkSmsPermission();
    notifyListeners();
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
      LocalizadorSonidoService.iniciar();

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
      await _enviarUbicacion.call(_tipoPendiente!);

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
      final estado = await _emergencyRepository.obtenerEstado().first;
      if (estado.activa && estado.tipo != null) {
        debugPrint('[MainProvider] Enviando ubicación periódica...');
        await _enviarUbicacion.call(estado.tipo!);
      } else {
        debugPrint('[MainProvider] Emergencia ya no activa, deteniendo envíos periódicos');
        _envioPeriodicoTimer?.cancel();
      }
    });
  }

  Future<void> cancelarEmergenciaActual() async {
    try {
      _envioPeriodicoTimer?.cancel();
      _envioPeriodicoTimer = null;

      await _cancelarEmergencia.call();
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
