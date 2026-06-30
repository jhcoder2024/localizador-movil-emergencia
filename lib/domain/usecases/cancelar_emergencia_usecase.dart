import 'package:localizador_movil_emergencia/domain/repositories/emergency_repository.dart';

class CancelarEmergenciaUseCase {
  final EmergencyRepository _repository;

  CancelarEmergenciaUseCase(this._repository);

  Future<void> call() {
    return _repository.cancelarEmergencia();
  }
}
