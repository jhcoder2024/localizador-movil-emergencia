import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsDataSource {
  final SharedPreferences _prefs;

  SharedPrefsDataSource(this._prefs);

  Future<void> setIdioma(String idioma) => _prefs.setString('idioma', idioma);

  String getIdioma() => _prefs.getString('idioma') ?? 'es';

  Future<void> setIntervalo(int minutos) =>
      _prefs.setInt('intervalo', minutos);

  int getIntervalo() => _prefs.getInt('intervalo') ?? 5;

  Future<void> clear() => _prefs.clear();
}
