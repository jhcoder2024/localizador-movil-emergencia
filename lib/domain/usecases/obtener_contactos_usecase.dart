import 'package:localizador_movil_emergencia/domain/entities/contacto_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/repositories/contacto_repository.dart';

class ObtenerContactosUseCase {
  final ContactoRepository _repository;

  ObtenerContactosUseCase(this._repository);

  Future<List<ContactoEmergencia>> call() {
    return _repository.obtenerContactos();
  }
}
