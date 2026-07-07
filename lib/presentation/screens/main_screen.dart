import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:localizador_movil_emergencia/domain/entities/tipo_emergencia.dart';
import 'package:localizador_movil_emergencia/presentation/providers/main_provider.dart';
import 'package:localizador_movil_emergencia/presentation/widgets/emergency_active_banner.dart';
import 'package:localizador_movil_emergencia/core/utils/permission_utils.dart';
import 'package:localizador_movil_emergencia/presentation/widgets/confirmation_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MainProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Localizador de Emergencia'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => context.push('/config'),
              ),
            ],
          ),
          body: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (provider.estado.activa)
                      EmergencyActiveBanner(
                        estado: provider.estado,
                        onCancel: () => provider.cancelarEmergenciaActual(),
                      ),
                    if (provider.ubicacionDenegada)
                      _buildWarningBanner(
                        icon: Icons.location_off,
                        title: 'Permiso de ubicación denegado',
                        message:
                            'La aplicación no funcionará correctamente sin acceso a la ubicación. '
                            'Toca el botón para conceder el permiso.',
                        action: TextButton(
                          onPressed: () async {
                            final otorgado = await PermissionUtils.requestLocationPermission();
                            if (otorgado) {
                              await provider.reverificarPermisos();
                            } else {
                              await PermissionUtils.openSettings();
                              await provider.reverificarPermisos();
                            }
                          },
                          child: const Text('CONCEDER PERMISO'),
                        ),
                      ),
                    if (provider.contactosFaltantes)
                      _buildWarningBanner(
                        icon: Icons.contacts_outlined,
                        title: 'Sin contactos configurados',
                        message:
                            'No has agregado ningún contacto de emergencia. '
                            'Ve a Configuración y agrega al menos un contacto para que la app pueda enviar tu ubicación en caso de emergencia.',
                        action: TextButton(
                          onPressed: () => context.push('/config'),
                          child: const Text('Configurar contactos'),
                        ),
                      ),
                    const Spacer(),
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: ElevatedButton(
                        onPressed: provider.estado.activa
                            ? null
                            : () => provider.solicitarConfirmacion(
                                TipoEmergencia.extraviado),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          foregroundColor: Colors.white,
                          shape: const CircleBorder(),
                          elevation: 8,
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 48),
                            SizedBox(height: 8),
                            Text(
                              'EMERGENCIA',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Toca para activar',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (provider.cargando)
                      const CircularProgressIndicator(),
                    if (provider.error != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Card(
                          color: const Color(0xFFFFEBEE),
                          child: ListTile(
                            leading: const Icon(Icons.error,
                                color: Color(0xFFB00020)),
                            title: Text(provider.error!),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: provider.limpiarError,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (provider.mostrarDialogo && provider.tipoPendiente != null)
                ConfirmationDialog(
                  tipo: provider.tipoPendiente!,
                  onConfirm: () => provider.confirmarEmergencia(),
                  onCancel: () => provider.cancelarDialogo(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWarningBanner({
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFE65100), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFFE65100),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(fontSize: 12, color: Color(0xFFBF360C)),
                ),
                if (action != null) action,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
