import 'package:localizador_movil_emergencia/domain/entities/tipo_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/repositories/config_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/emergency_repository.dart';

class ActivarEmergenciaUseCase {
  final EmergencyRepository _emergencyRepository;
  final ConfigRepository _configRepository;

  ActivarEmergenciaUseCase(this._emergencyRepository, this._configRepository);

  Future<void> call(TipoEmergencia tipo) async {
    final config = await _configRepository.obtenerConfiguracion().first;
    if (!config.esValida) {
      throw Exception('Configuración inválida. Verifica el intervalo y número de contactos.');
    }
    if (config.contactos.isEmpty) {
      throw Exception('No hay contactos de emergencia configurados.');
    }
    return _emergencyRepository.activarEmergencia(tipo);
  }
}
