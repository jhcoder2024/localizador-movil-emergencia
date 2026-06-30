import 'package:equatable/equatable.dart';
import 'package:localizador_movil_emergencia/domain/entities/tipo_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/entities/coordenadas.dart';

class EstadoEmergencia extends Equatable {
  final bool activa;
  final TipoEmergencia? tipo;
  final DateTime? inicioTimestamp;
  final DateTime? ultimoEnvioTimestamp;
  final int enviosRealizados;
  final Coordenadas? coordenadaActual;

  const EstadoEmergencia({
    this.activa = false,
    this.tipo,
    this.inicioTimestamp,
    this.ultimoEnvioTimestamp,
    this.enviosRealizados = 0,
    this.coordenadaActual,
  });

  EstadoEmergencia copyWith({
    bool? activa,
    TipoEmergencia? tipo,
    DateTime? inicioTimestamp,
    DateTime? ultimoEnvioTimestamp,
    int? enviosRealizados,
    Coordenadas? coordenadaActual,
  }) {
    return EstadoEmergencia(
      activa: activa ?? this.activa,
      tipo: tipo ?? this.tipo,
      inicioTimestamp: inicioTimestamp ?? this.inicioTimestamp,
      ultimoEnvioTimestamp: ultimoEnvioTimestamp ?? this.ultimoEnvioTimestamp,
      enviosRealizados: enviosRealizados ?? this.enviosRealizados,
      coordenadaActual: coordenadaActual ?? this.coordenadaActual,
    );
  }

  @override
  List<Object?> get props => [
        activa,
        tipo,
        inicioTimestamp,
        ultimoEnvioTimestamp,
        enviosRealizados,
        coordenadaActual,
      ];
}
