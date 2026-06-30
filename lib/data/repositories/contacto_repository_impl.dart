import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/contacts_dao.dart';
import 'package:localizador_movil_emergencia/data/mappers/contacto_mapper.dart';
import 'package:localizador_movil_emergencia/domain/entities/contacto_emergencia.dart';
import 'package:localizador_movil_emergencia/domain/repositories/contacto_repository.dart';

class ContactoRepositoryImpl implements ContactoRepository {
  final ContactsDao _contactsDao;

  ContactoRepositoryImpl(this._contactsDao);

  @override
  Future<List<ContactoEmergencia>> obtenerContactos() async {
    final rows = await _contactsDao.obtenerTodos();
    return ContactoMapper.fromTableDataList(rows);
  }

  @override
  Future<void> guardarContactos(List<ContactoEmergencia> contactos) async {
    final companions =
        contactos.map((c) => ContactoMapper.toCompanion(c)).toList();
    await _contactsDao.reemplazarTodos(companions);
  }

  @override
  Future<List<ContactoTelefono>> obtenerContactosAgenda() async {
    try {
      final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.name, ContactProperty.phone},
      );
      return contacts
          .where((c) => c.phones.isNotEmpty)
          .map((c) => ContactoTelefono(
                id: c.id ?? '',
                nombre: c.displayName ?? 'Sin nombre',
                telefono: c.phones.first.number,
              ))
          .where((c) => c.telefono.isNotEmpty)
          .toList();
    } catch (e) {
      return [];
    }
  }
}
