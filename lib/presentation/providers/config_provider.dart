import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:localizador_movil_emergencia/domain/entities/configuracion.dart';
import 'package:localizador_movil_emergencia/domain/entities/contacto_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/repositories/contacto_repository.dart';
import 'package:localizador_movil_emergencia/domain/usecases/guardar_configuracion_usecase.dart';
import 'package:localizador_movil_emergencia/domain/usecases/obtener_configuracion_usecase.dart';

class ConfigProvider extends ChangeNotifier {
  final GuardarConfiguracionUseCase _guardarConfiguracion;
  final ObtenerConfiguracionUseCase _obtenerConfiguracion;
  final ContactoRepository _contactoRepository;
  StreamSubscription? _configSub;

  ConfigProvider({
    required GuardarConfiguracionUseCase guardarConfiguracion,
    required ObtenerConfiguracionUseCase obtenerConfiguracion,
    required ContactoRepository contactoRepository,
  })  : _guardarConfiguracion = guardarConfiguracion,
        _obtenerConfiguracion = obtenerConfiguracion,
        _contactoRepository = contactoRepository;

  Configuracion _configuracion = const Configuracion();
  List<ContactoTelefono> _contactosAgenda = [];
  String? _error;

  Configuracion get configuracion => _configuracion;
  List<ContactoEmergencia> get contactosSeleccionados => _configuracion.contactos;
  List<ContactoTelefono> get contactosAgenda => _contactosAgenda;
  String? get error => _error;
  bool get maxContactosAlcanzado => _configuracion.contactos.length >= 10;
  Future<void> init() async {
    if (_configSub != null) return;
    _configSub = _obtenerConfiguracion().listen((config) {
      _configuracion = config;
      notifyListeners();
    });
    await cargarContactosAgenda();
  }

  Future<void> cargarContactosAgenda() async {
    try {
      _contactosAgenda = await _contactoRepository.obtenerContactosAgenda();
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar contactos: $e';
      notifyListeners();
    }
  }

  Future<void> agregarContacto(ContactoTelefono contacto) async {
    if (maxContactosAlcanzado) return;

    // Normalizar teléfono a formato internacional
    String telefonoNormalizado = contacto.telefono.replaceAll(RegExp(r'[^\d+]'), '');
    if (telefonoNormalizado.startsWith('0')) {
      telefonoNormalizado = '+58${telefonoNormalizado.substring(1)}';
    } else if (!telefonoNormalizado.startsWith('+')) {
      telefonoNormalizado = '+$telefonoNormalizado';
    }

    final nuevo = ContactoEmergencia(
      id: contacto.id,
      nombre: contacto.nombre,
      telefono: telefonoNormalizado,
    );
    final updated = [..._configuracion.contactos, nuevo];
    _configuracion = _configuracion.copyWith(contactos: updated);
    notifyListeners();
    await _autoGuardar();
  }

  Future<void> eliminarContacto(String id) async {
    final updated = _configuracion.contactos.where((c) => c.id != id).toList();
    _configuracion = _configuracion.copyWith(contactos: updated);
    notifyListeners();
    await _autoGuardar();
  }

  Future<void> setIntervalo(int minutos) async {
    _configuracion = _configuracion.copyWith(intervaloMinutos: minutos);
    notifyListeners();
    await _autoGuardar();
  }

  void setTelegramToken(String token) {
    _configuracion = _configuracion.copyWith(telegramToken: token);
    notifyListeners();
  }

  Future<void> _autoGuardar() async {
    if (!_configuracion.esValida) return;
    try {
      await _guardarConfiguracion.call(_configuracion);
      _error = null;
    } catch (e) {
      debugPrint('[Config] Error al auto-guardar: $e');
    }
  }

  @override
  void dispose() {
    _configSub?.cancel();
    super.dispose();
  }
}
