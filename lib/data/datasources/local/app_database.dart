import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class ContactosTable extends Table {
  TextColumn get id => text()();
  TextColumn get nombre => text()();
  TextColumn get telefono => text()();
  BoolColumn get tieneWhatsApp => boolean().withDefault(const Constant(false))();
  BoolColumn get tieneTelegram => boolean().withDefault(const Constant(false))();
  TextColumn get chatIdTelegram => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ConfigTable extends Table {
  TextColumn get clave => text()();
  TextColumn get valor => text()();

  @override
  Set<Column> get primaryKey => {clave};
}

@DriftDatabase(tables: [ContactosTable, ConfigTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<ContactosTableData>> getAllContactos() =>
      select(contactosTable).get();

  Future<void> insertContacto(ContactosTableCompanion contacto) =>
      into(contactosTable).insert(contacto);

  Future<void> deleteContacto(String id) =>
      (delete(contactosTable)..where((t) => t.id.equals(id))).go();

  Future<void> clearContactos() => delete(contactosTable).go();

  Future<String?> getConfig(String clave) async {
    final row = await (select(configTable)
            ..where((t) => t.clave.equals(clave)))
        .watchSingleOrNull()
        .first;
    return row?.valor;
  }

  Future<void> setConfig(String clave, String valor) =>
      into(configTable).insert(
        ConfigTableCompanion(
          clave: Value(clave),
          valor: Value(valor),
        ),
        mode: InsertMode.replace,
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'localizador.db'));
    return NativeDatabase(file);
  });
}
