import 'package:localizador_movil_emergencia/domain/entities/configuracion.dart';

abstract class ConfigRepository {
  Stream<Configuracion> obtenerConfiguracion();
  Future<void> guardarConfiguracion(Configuracion config);
}
