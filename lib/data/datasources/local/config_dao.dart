import 'package:drift/drift.dart';
import 'app_database.dart';

part 'config_dao.g.dart';

@DriftAccessor(tables: [ConfigTable])
class ConfigDao extends DatabaseAccessor<AppDatabase> with _$ConfigDaoMixin {
  ConfigDao(super.db);

  Future<String?> getValor(String clave) async {
    final result = await (select(configTable)
          ..where((tbl) => tbl.clave.equals(clave)))
        .getSingleOrNull();
    return result?.valor;
  }

  Future<void> setValor(String clave, String valor) async {
    await into(configTable).insert(
      ConfigTableCompanion(
        clave: Value(clave),
        valor: Value(valor),
      ),
      mode: InsertMode.replace,
    );
  }

  Future<void> deleteValor(String clave) async {
    await (delete(configTable)..where((tbl) => tbl.clave.equals(clave))).go();
  }

  Future<Map<String, String>> getAll() async {
    final rows = await select(configTable).get();
    return {for (final row in rows) row.clave: row.valor};
  }
}
