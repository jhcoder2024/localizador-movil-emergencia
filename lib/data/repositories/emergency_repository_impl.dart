import 'dart:async';
import 'package:localizador_movil_emergencia/domain/entities/coordenadas.dart';
import 'package:localizador_movil_emergencia/domain/entities/estado_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/entities/tipo_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/repositories/emergency_repository.dart';

class EmergencyRepositoryImpl implements EmergencyRepository {
  final StreamController<EstadoEmergencia> _estadoController =
      StreamController<EstadoEmergencia>.broadcast();

  EstadoEmergencia _estado = const EstadoEmergencia();

  @override
  Stream<EstadoEmergencia> obtenerEstado() => _estadoController.stream;

  @override
  Future<void> activarEmergencia(TipoEmergencia tipo) async {
    _estado = EstadoEmergencia(
      activa: true,
      tipo: tipo,
      inicioTimestamp: DateTime.now(),
      enviosRealizados: 0,
    );
    _emit();
  }

  @override
  Future<void> cancelarEmergencia() async {
    _estado = const EstadoEmergencia();
    _emit();
  }

  @override
  Future<void> actualizarCoordenada(Coordenadas coordenadas) async {
    _estado = _estado.copyWith(
      coordenadaActual: coordenadas,
      ultimoEnvioTimestamp: DateTime.now(),
      enviosRealizados: _estado.enviosRealizados + 1,
    );
    _emit();
  }

  void _emit() {
    if (!_estadoController.isClosed) {
      _estadoController.add(_estado);
    }
  }

  void dispose() {
    _estadoController.close();
  }
}
