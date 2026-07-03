import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/app_database.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/config_dao.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/contacts_dao.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/conversation_dao.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/sms_dao.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/shared_prefs_datasource.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/secure_storage_datasource.dart';
import 'package:localizador_movil_emergencia/data/datasources/remote/sms_content_provider_datasource.dart';
import 'package:localizador_movil_emergencia/data/repositories/contacto_repository_impl.dart';
import 'package:localizador_movil_emergencia/data/repositories/config_repository_impl.dart';
import 'package:localizador_movil_emergencia/data/repositories/emergency_repository_impl.dart';
import 'package:localizador_movil_emergencia/data/repositories/location_repository_impl.dart';
import 'package:localizador_movil_emergencia/data/repositories/sms_inbox_repository_impl.dart';
import 'package:localizador_movil_emergencia/data/repositories/sms_repository_impl.dart';
import 'package:localizador_movil_emergencia/domain/repositories/contacto_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/config_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/emergency_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/location_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/sms_inbox_repository.dart';
import 'package:localizador_movil_emergencia/domain/repositories/sms_repository.dart';
import 'package:localizador_movil_emergencia/domain/services/sms_sync_service.dart';
import 'package:localizador_movil_emergencia/domain/services/sms_event_service.dart';

final getIt = GetIt.instance;

Future<void> initDataModule() async {
  // Core
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
  getIt.registerLazySingleton<Dio>(() => dio);

  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPrefsDataSource>(
      () => SharedPrefsDataSource(prefs));

  // Secure Storage
  getIt.registerLazySingleton<SecureStorageDataSource>(
      () => SecureStorageDataSource());

  // Database
  final database = AppDatabase();
  getIt.registerLazySingleton<AppDatabase>(() => database);
  getIt.registerLazySingleton<ConfigDao>(() => ConfigDao(database));
  getIt.registerLazySingleton<ContactsDao>(() => ContactsDao(database));
  getIt.registerLazySingleton<SmsDao>(() => SmsDao(database));
  getIt.registerLazySingleton<ConversationDao>(() => ConversationDao(database));

  // Repositories
  getIt.registerLazySingleton<ContactoRepository>(
    () => ContactoRepositoryImpl(getIt<ContactsDao>()),
  );
  getIt.registerLazySingleton<ConfigRepository>(
    () => ConfigRepositoryImpl(
      getIt<SharedPrefsDataSource>(),
      getIt<ConfigDao>(),
      getIt<SecureStorageDataSource>(),
    ),
  );
  getIt.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(GeolocatorPlatform.instance),
  );
  getIt.registerLazySingleton<SmsRepository>(
    () => SmsRepositoryImpl(),
  );
  getIt.registerLazySingleton<EmergencyRepository>(
    () => EmergencyRepositoryImpl(),
  );
  getIt.registerLazySingleton<SmsInboxRepository>(
    () => SmsInboxRepositoryImpl(getIt<ConversationDao>(), getIt<SmsDao>()),
  );

  // SMS Sync & Event services
  getIt.registerLazySingleton<SmsContentProviderDataSource>(
    () => SmsContentProviderDataSource(),
  );
  getIt.registerLazySingleton<SmsSyncService>(
    () => SmsSyncService(
      getIt<SmsContentProviderDataSource>(),
      getIt<SmsDao>(),
      getIt<ConversationDao>(),
      getIt<ConfigDao>(),
    ),
  );
  getIt.registerLazySingleton<SmsEventService>(
    () => SmsEventService(
      getIt<SmsDao>(),
      getIt<ConversationDao>(),
    ),
  );
}
