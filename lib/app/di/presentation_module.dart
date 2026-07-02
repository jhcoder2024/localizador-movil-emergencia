import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:localizador_movil_emergencia/presentation/providers/main_provider.dart';
import 'package:localizador_movil_emergencia/presentation/providers/config_provider.dart';

final getIt = GetIt.instance;

void initPresentationModule() {
  getIt.registerFactory<MainProvider>(
    () => MainProvider(
      activarEmergencia: getIt(),
      cancelarEmergencia: getIt(),
      enviarUbicacion: getIt(),
      obtenerConfiguracion: getIt(),
      emergencyRepository: getIt(),
    ),
  );
  getIt.registerFactory<ConfigProvider>(
    () => ConfigProvider(
      obtenerContactos: getIt(),
      guardarConfiguracion: getIt(),
      obtenerConfiguracion: getIt(),
      verificarCanales: getIt(),
      contactoRepository: getIt(),
      smsRepository: getIt(),
    ),
  );
}

List<ChangeNotifierProvider> get providers => [
      ChangeNotifierProvider<MainProvider>(
        create: (_) => getIt<MainProvider>(),
      ),
      ChangeNotifierProvider<ConfigProvider>(
        create: (_) => getIt<ConfigProvider>(),
      ),
    ];
