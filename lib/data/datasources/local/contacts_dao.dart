import 'package:drift/drift.dart';
import 'app_database.dart';

part 'contacts_dao.g.dart';

@DriftAccessor(tables: [ContactosTable])
class ContactsDao extends DatabaseAccessor<AppDatabase>
    with _$ContactsDaoMixin {
  ContactsDao(super.db);

  Future<List<ContactosTableData>> obtenerTodos() async =>
      select(contactosTable).get();

  Future<void> insertar(ContactosTableCompanion contacto) async {
    await into(contactosTable).insert(contacto);
  }

  Future<void> insertarMultiples(
      List<ContactosTableCompanion> contactos) async {
    await batch((batch) {
      batch.insertAll(contactosTable, contactos);
    });
  }

  Future<void> eliminar(String id) async {
    await (delete(contactosTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> eliminarTodos() async {
    await delete(contactosTable).go();
  }

  Future<void> reemplazarTodos(List<ContactosTableCompanion> contactos) async {
    await transaction(() async {
      await delete(contactosTable).go();
      for (final c in contactos) {
        await into(contactosTable).insert(c);
      }
    });
  }
}
