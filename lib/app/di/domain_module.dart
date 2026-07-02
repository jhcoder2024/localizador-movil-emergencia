import 'package:get_it/get_it.dart';
import 'package:localizador_movil_emergencia/domain/repositories/contacto_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/config_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/emergency_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/location_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/sms_repository.dart';
import 'package:localizador_movil_emergencia/domain/usecases/activar_emergencia_usecase.dart';
import 'package:localizador_movil_emergencia/domain/usecases/cancelar_emergencia_usecase.dart';
import 'package:localizador_movil_emergencia/domain/usecases/enviar_ubicacion_usecase.dart';
import 'package:localizador_movil_emergencia/domain/usecases/obtener_contactos_usecase.dart';
import 'package:localizador_movil_emergencia/domain/usecases/guardar_configuracion_usecase.dart';
import 'package:localizador_movil_emergencia/domain/usecases/obtener_configuracion_usecase.dart';
import 'package:localizador_movil_emergencia/domain/usecases/verificar_disponibilidad_canal_usecase.dart';

final getIt = GetIt.instance;

void initDomainModule() {
  getIt.registerLazySingleton<ActivarEmergenciaUseCase>(
    () => ActivarEmergenciaUseCase(
      getIt<EmergencyRepository>(),
      getIt<ConfigRepository>(),
    ),
  );
  getIt.registerLazySingleton<CancelarEmergenciaUseCase>(
    () => CancelarEmergenciaUseCase(getIt<EmergencyRepository>()),
  );
  getIt.registerLazySingleton<EnviarUbicacionUseCase>(
    () => EnviarUbicacionUseCase(
      getIt<LocationRepository>(),
      getIt<EmergencyRepository>(),
      getIt<ConfigRepository>(),
      getIt<SmsRepository>(),
    ),
  );
  getIt.registerLazySingleton<ObtenerContactosUseCase>(
    () => ObtenerContactosUseCase(getIt<ContactoRepository>()),
  );
  getIt.registerLazySingleton<GuardarConfiguracionUseCase>(
    () => GuardarConfiguracionUseCase(getIt<ConfigRepository>()),
  );
  getIt.registerLazySingleton<ObtenerConfiguracionUseCase>(
    () => ObtenerConfiguracionUseCase(getIt<ConfigRepository>()),
  );
  getIt.registerLazySingleton<VerificarDisponibilidadCanalUseCase>(
    () => VerificarDisponibilidadCanalUseCase(
      getIt<SmsRepository>(),
      getIt<ConfigRepository>(),
    ),
  );
}
