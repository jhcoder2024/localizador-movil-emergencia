import 'package:flutter/material.dart';
import 'package:localizador_movil_emergencia/domain/entities/contacto_emergencia.dart';

class ContactListSection extends StatelessWidget {
  final List<ContactoEmergencia> contactos;
  final VoidCallback onAdd;
  final ValueChanged<String> onDelete;

  const ContactListSection({
    super.key,
    required this.contactos,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Contactos de emergencia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: onAdd,
                ),
              ],
            ),
            const Divider(),
            if (contactos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No hay contactos de emergencia.\nAgrega al menos un contacto.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...contactos.map(
                (c) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFD32F2F).withOpacity(0.1),
                    child: Text(
                      c.nombre.isNotEmpty
                          ? c.nombre[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Color(0xFFD32F2F)),
                    ),
                  ),
                  title: Text(c.nombre),
                  subtitle: Text(c.telefono),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Color(0xFFB00020)),
                    onPressed: () => onDelete(c.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
