import 'package:localizador_movil_emergencia/domain/entities/coordenadas.dart';
import 'package:localizador_movil_emergencia/domain/entities/estado_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/entities/tipo_emergencia.dart';

abstract class EmergencyRepository {
  Stream<EstadoEmergencia> obtenerEstado();
  Future<void> activarEmergencia(TipoEmergencia tipo);
  Future<void> cancelarEmergencia();
  Future<void> actualizarCoordenada(Coordenadas coordenadas);
}
