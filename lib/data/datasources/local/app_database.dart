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

class ConversationsTable extends Table {
  TextColumn get id => text()();
  TextColumn get remitente => text()();
  TextColumn get telefono => text()();
  TextColumn get ultimoMensaje => text()();
  IntColumn get ultimaFecha => integer()();
  IntColumn get noLeidos => integer().withDefault(const Constant(0))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class SmsMessagesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get conversationId => text()();
  TextColumn get remitente => text()();
  TextColumn get telefono => text()();
  TextColumn get cuerpo => text()();
  IntColumn get fecha => integer()();
  IntColumn get tipo => integer()();
  BoolColumn get leido => boolean().withDefault(const Constant(false))();
  BoolColumn get tieneMms => boolean().withDefault(const Constant(false))();
  TextColumn get estadoEnvio => text().withDefault(const Constant('sent'))();

  @override
  Set<Column> get primaryKey => {id};
}

class BlockedNumbersTable extends Table {
  TextColumn get id => text()();
  IntColumn get bloqueadoEn => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [ContactosTable, ConfigTable, ConversationsTable, SmsMessagesTable, BlockedNumbersTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(conversationsTable);
        await m.createTable(smsMessagesTable);
      }
      if (from < 3) {
        await m.addColumn(smsMessagesTable, smsMessagesTable.estadoEnvio);
      }
      if (from < 4) {
        await m.addColumn(conversationsTable, conversationsTable.isArchived);
      }
      if (from < 5) {
        await m.createTable(blockedNumbersTable);
      }
    },
  );

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
