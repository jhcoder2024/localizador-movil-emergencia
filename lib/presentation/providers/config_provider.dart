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
  bool _cargando = false;
  String? _error;
  bool _guardado = false;

  Configuracion get configuracion => _configuracion;
  List<ContactoEmergencia> get contactosSeleccionados => _configuracion.contactos;
  List<ContactoTelefono> get contactosAgenda => _contactosAgenda;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get guardado => _guardado;
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

  void agregarContacto(ContactoTelefono contacto) {
    if (maxContactosAlcanzado) return;
    final nuevo = ContactoEmergencia(
      id: contacto.id,
      nombre: contacto.nombre,
      telefono: contacto.telefono,
    );
    final updated = [..._configuracion.contactos, nuevo];
    _configuracion = _configuracion.copyWith(contactos: updated);
    notifyListeners();
  }

  void eliminarContacto(String id) {
    final updated = _configuracion.contactos.where((c) => c.id != id).toList();
    _configuracion = _configuracion.copyWith(contactos: updated);
    notifyListeners();
  }

  void setIntervalo(int minutos) {
    _configuracion = _configuracion.copyWith(intervaloMinutos: minutos);
    notifyListeners();
  }

  void setTelegramToken(String token) {
    _configuracion = _configuracion.copyWith(telegramToken: token);
    notifyListeners();
  }

  Future<void> guardar() async {
    if (!_configuracion.esValida) {
      _error = 'Configuración inválida. Verifica el intervalo y los contactos.';
      notifyListeners();
      return;
    }
    _cargando = true;
    notifyListeners();
    try {
      await _guardarConfiguracion.call(_configuracion);
      _guardado = true;
      _error = null;
    } catch (e) {
      _error = 'Error al guardar: $e';
    }
    _cargando = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _configSub?.cancel();
    super.dispose();
  }
}
