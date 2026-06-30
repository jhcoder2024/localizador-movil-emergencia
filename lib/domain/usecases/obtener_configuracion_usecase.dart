import 'package:localizador_movil_emergencia/domain/entities/configuracion.dart';
import 'package:localizador_movil_emergencia/domain/repositories/config_repository.dart';

class ObtenerConfiguracionUseCase {
  final ConfigRepository _repository;

  ObtenerConfiguracionUseCase(this._repository);

  Stream<Configuracion> call() {
    return _repository.obtenerConfiguracion();
  }
}
