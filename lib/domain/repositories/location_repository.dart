import 'package:localizador_movil_emergencia/domain/entities/coordenadas.dart';

abstract class LocationRepository {
  Future<Coordenadas> obtenerUbicacionActual();
  Stream<Coordenadas> obtenerActualizacionesUbicacion();
}
