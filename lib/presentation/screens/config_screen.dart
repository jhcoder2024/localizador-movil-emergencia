import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:provider/provider.dart';

import 'package:localizador_movil_emergencia/domain/repositories/contacto_repository.dart';
import 'package:localizador_movil_emergencia/presentation/providers/config_provider.dart';
import 'package:localizador_movil_emergencia/presentation/providers/theme_provider.dart';
import 'package:localizador_movil_emergencia/presentation/widgets/interval_section.dart';
import 'package:localizador_movil_emergencia/presentation/widgets/contact_list_section.dart';
import 'package:localizador_movil_emergencia/presentation/widgets/contact_picker_dialog.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConfigProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Configurar Localizador'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [

                IntervalSection(
                  valor: provider.configuracion.intervaloMinutos,
                  onChanged: provider.setIntervalo,
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Apariencia',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, _) {
                            return Column(
                              children: [
                                RadioListTile<ThemeMode>(
                                  title: const Text('Claro'),
                                  value: ThemeMode.light,
                                  groupValue: themeProvider.themeMode,
                                  onChanged: (v) => themeProvider.setThemeMode(v!),
                                ),
                                RadioListTile<ThemeMode>(
                                  title: const Text('Oscuro'),
                                  value: ThemeMode.dark,
                                  groupValue: themeProvider.themeMode,
                                  onChanged: (v) => themeProvider.setThemeMode(v!),
                                ),
                                RadioListTile<ThemeMode>(
                                  title: const Text('Seguir sistema'),
                                  value: ThemeMode.system,
                                  groupValue: themeProvider.themeMode,
                                  onChanged: (v) => themeProvider.setThemeMode(v!),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (provider.contactosSeleccionados.isEmpty)
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFB74D)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Color(0xFFE65100), size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Agrega al menos un contacto de emergencia. '
                            'Se recomienda agregar el máximo de 10 contactos para mayor seguridad.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFBF360C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ContactListSection(
                  contactos: provider.contactosSeleccionados,
                  onAdd: () => _agregarContacto(context, provider),
                  onDelete: provider.eliminarContacto,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text('${provider.contactosSeleccionados.length}/10 contactos'),
                      const Spacer(),
                      if (provider.contactosSeleccionados.isNotEmpty)
                        Text(
                          provider.contactosSeleccionados.length >= 10
                              ? '✅ Completo'
                              : '👍 Recomendable agregar más',
                          style: TextStyle(
                            fontSize: 12,
                            color: provider.contactosSeleccionados.length >= 10
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _agregarContacto(BuildContext context, ConfigProvider provider) async {
    if (provider.maxContactosAlcanzado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Máximo 10 contactos de emergencia'),
        ),
      );
      return;
    }

    // Solicitar permiso de contactos si no está concedido
    final permStatus = await FlutterContacts.permissions.request(
      PermissionType.read,
    );
    if (permStatus != PermissionStatus.granted) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Se necesita acceso a contactos para seleccionar destinatarios de emergencia.',
          ),
        ),
      );
      return;
    }

    // Cargar contactos de la agenda
    await provider.cargarContactosAgenda();

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => ContactPickerDialog(
        contactos: provider.contactosAgenda,
        onSelected: (ContactoTelefono contacto) {
          provider.agregarContacto(contacto);
        },
      ),
    );
  }
}
