import 'dart:async';
import 'dart:convert';
import 'package:localizador_movil_emergencia/data/datasources/local/shared_prefs_datasource.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/config_dao.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/secure_storage_datasource.dart';
import 'package:localizador_movil_emergencia/data/mappers/config_mapper.dart';
import 'package:localizador_movil_emergencia/data/models/configuracion_model.dart';
import 'package:localizador_movil_emergencia/data/models/contacto_model.dart';
import 'package:localizador_movil_emergencia/domain/entities/configuracion.dart';
import 'package:localizador_movil_emergencia/domain/repositories/config_repository.dart';

class ConfigRepositoryImpl implements ConfigRepository {
  final SharedPrefsDataSource _sharedPrefs;
  final ConfigDao _configDao;
  final SecureStorageDataSource _secureStorage;
  final StreamController<Configuracion> _controller =
      StreamController<Configuracion>.broadcast();

  ConfigRepositoryImpl(this._sharedPrefs, this._configDao, this._secureStorage);

  @override
  Stream<Configuracion> obtenerConfiguracion() {
    _emitCurrentConfig();
    return _controller.stream;
  }

  @override
  Future<void> guardarConfiguracion(Configuracion config) async {
    await _sharedPrefs.setIdioma(config.idioma);
    await _sharedPrefs.setIntervalo(config.intervaloMinutos);
    if (config.telegramToken != null) {
      await _secureStorage.setTelegramToken(config.telegramToken!);
    }
    final model = ConfigMapper.toModel(config);
    final jsonStr = jsonEncode(model.toJson());
    await _configDao.setValor('config_completa', jsonStr);

    _emit(config);
  }

  Future<void> _emitCurrentConfig() async {
    final config = await _loadConfig();
    _emit(config);
  }

  void _emit(Configuracion config) {
    if (!_controller.isClosed) {
      _controller.add(config);
    }
  }

  Future<Configuracion> _loadConfig() async {
    final idioma = _sharedPrefs.getIdioma();
    final intervalo = _sharedPrefs.getIntervalo();
    final telegramToken = await _secureStorage.getTelegramToken();
    final jsonStr = await _configDao.getValor('config_completa');
    if (jsonStr != null) {
      try {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        final model = ConfiguracionModel.fromJson(json);
        return ConfigMapper.toEntity(model).copyWith(
          idioma: idioma,
          intervaloMinutos: intervalo,
          telegramToken: telegramToken,
        );
      } catch (_) {}
    }

    return Configuracion(
      idioma: idioma,
      intervaloMinutos: intervalo,
      telegramToken: telegramToken,
    );
  }

  void dispose() {
    _controller.close();
  }
}
