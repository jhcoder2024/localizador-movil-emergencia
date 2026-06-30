import 'package:localizador_movil_emergencia/domain/entities/configuracion.dart';
import 'package:localizador_movil_emergencia/domain/repositories/config_repository.dart';

class GuardarConfiguracionUseCase {
  final ConfigRepository _repository;

  GuardarConfiguracionUseCase(this._repository);

  Future<void> call(Configuracion config) async {
    if (!config.esValida) {
      throw Exception(
        'Configuración inválida. El intervalo mínimo es ${Configuracion.intervaloMinimo} minuto(s) '
        'y el máximo de contactos es ${Configuracion.maxContactos}.',
      );
    }
    return _repository.guardarConfiguracion(config);
  }
}
