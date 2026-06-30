import 'package:flutter/material.dart';
import 'package:localizador_movil_emergencia/domain/repositories/contacto_repository.dart';

class ContactPickerDialog extends StatefulWidget {
  final List<ContactoTelefono> contactos;
  final ValueChanged<ContactoTelefono> onSelected;

  const ContactPickerDialog({
    super.key,
    required this.contactos,
    required this.onSelected,
  });

  @override
  State<ContactPickerDialog> createState() => _ContactPickerDialogState();
}

class _ContactPickerDialogState extends State<ContactPickerDialog> {
  bool _isLoading = true;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  List<ContactoTelefono> get _contactosFiltrados {
    if (_busqueda.isEmpty) return widget.contactos;
    return widget.contactos.where((c) {
      final q = _busqueda.toLowerCase();
      return c.nombre.toLowerCase().contains(q) ||
          c.telefono.contains(q);
    }).toList();
  }

  Widget _buildContent() {
    if (_isLoading && widget.contactos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_contactosFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.contacts_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _busqueda.isEmpty
                  ? 'No se encontraron contactos en tu agenda'
                  : 'No se encontraron contactos',
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: _contactosFiltrados.length,
      itemBuilder: (context, index) {
        final c = _contactosFiltrados[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor:
                const Color(0xFFD32F2F).withOpacity(0.1),
            child: Text(
              c.nombre.isNotEmpty
                  ? c.nombre[0].toUpperCase()
                  : '?',
              style:
                  const TextStyle(color: Color(0xFFD32F2F)),
            ),
          ),
          title: Text(c.nombre),
          subtitle: Text(c.telefono),
          onTap: () {
            widget.onSelected(c);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                child: Row(
                  children: [
                    const Text(
                      'Seleccionar contacto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar contacto...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _busqueda = v),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
