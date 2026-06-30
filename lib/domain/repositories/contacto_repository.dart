import 'package:localizador_movil_emergencia/domain/entities/contacto_emergencia.dart';

class ContactoTelefono {
  final String id;
  final String nombre;
  final String telefono;

  const ContactoTelefono({required this.id, required this.nombre, required this.telefono});
}

abstract class ContactoRepository {
  Future<List<ContactoEmergencia>> obtenerContactos();
  Future<void> guardarContactos(List<ContactoEmergencia> contactos);
  Future<List<ContactoTelefono>> obtenerContactosAgenda();
}
