import 'package:localizador_movil_emergencia/domain/entities/tipo_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/repositories/config_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/emergency_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/location_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/sms_repository.dart';
import 'package:localizador_movil_emergencia/domain/entities/configuracion.dart';

class EnviarUbicacionUseCase {
  final LocationRepository _locationRepository;
  final EmergencyRepository _emergencyRepository;
  final ConfigRepository _configRepository;
  final SmsRepository _smsRepository;

  EnviarUbicacionUseCase(
    this._locationRepository,
    this._emergencyRepository,
    this._configRepository,
    this._smsRepository,
  );

  Future<void> call(TipoEmergencia tipo) async {
    // 1. Obtener ubicación (puntual, no streaming)
    final coordenadas = await _locationRepository.obtenerUbicacionActual();

    // 2. Actualizar estado con coordenada actual
    await _emergencyRepository.actualizarCoordenada(coordenadas);

    // 3. Obtener configuración y contactos
    final config = await _configRepository.obtenerConfiguracion().first;
    final mensaje = tipo.construirMensaje(
      coordenadas.latitud,
      coordenadas.longitud,
    );

    // 4. Enviar SMS a todos los contactos
    for (final contacto in config.contactos) {
      await _smsRepository.enviarSms(contacto.telefono, mensaje);
      // Pequeña pausa entre contactos para no saturar
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}
