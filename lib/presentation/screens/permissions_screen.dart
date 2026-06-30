import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localizador_movil_emergencia/core/utils/permission_utils.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _locationGranted = false;
  bool _smsGranted = false;
  bool _contactsGranted = false;
  bool _notificationGranted = false;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _verificarPermisos();
  }

  Future<void> _verificarPermisos() async {
    setState(() => _cargando = true);
    final results = await Future.wait([
      PermissionUtils.checkLocationPermission(),
      PermissionUtils.checkSmsPermission(),
      PermissionUtils.checkContactsPermission(),
      PermissionUtils.checkNotificationPermission(),
    ]);
    setState(() {
      _locationGranted = results[0];
      _smsGranted = results[1];
      _contactsGranted = results[2];
      _notificationGranted = results[3];
      _cargando = false;
    });
    if (_todosConcedidos) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/');
      });
    }
  }

  bool get _todosConcedidos =>
      _locationGranted && _smsGranted && _contactsGranted && _notificationGranted;

  double get _progreso {
    int count = 0;
    if (_locationGranted) count++;
    if (_smsGranted) count++;
    if (_contactsGranted) count++;
    if (_notificationGranted) count++;
    return count / 4;
  }

  Future<void> _solicitar(Future<bool> Function() request,
      ValueChanged<bool> onResult) async {
    final result = await request();
    setState(() => onResult(result));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permisos del Localizador'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Icon(Icons.location_on, size: 64, color: Color(0xFFD32F2F)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Permisos requeridos',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'La aplicación necesita estos permisos para funcionar '
                    'correctamente durante una emergencia.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: _progreso),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.grey.shade300,
                      color: const Color(0xFF4CAF50),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(_progreso * 100).toInt()}% completado',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  _buildTile(
                    icon: Icons.location_on,
                    titulo: 'Ubicación',
                    descripcion: 'Para enviar tu ubicación en tiempo real',
                    concedido: _locationGranted,
                    onSolicitar: () => _solicitar(
                      PermissionUtils.requestLocationPermission,
                      (v) => _locationGranted = v,
                    ),
                  ),
                  _buildTile(
                    icon: Icons.sms,
                    titulo: 'SMS',
                    descripcion: 'Para enviar mensajes de emergencia por SMS',
                    concedido: _smsGranted,
                    onSolicitar: () => _solicitar(
                      PermissionUtils.requestSmsPermission,
                      (v) => _smsGranted = v,
                    ),
                  ),
                  _buildTile(
                    icon: Icons.contacts,
                    titulo: 'Contactos',
                    descripcion:
                        'Para seleccionar contactos de emergencia de tu agenda',
                    concedido: _contactsGranted,
                    onSolicitar: () => _solicitar(
                      PermissionUtils.requestContactsPermission,
                      (v) => _contactsGranted = v,
                    ),
                  ),
                  _buildTile(
                    icon: Icons.notifications,
                    titulo: 'Notificaciones',
                    descripcion:
                        'Para mostrar alertas de emergencia en segundo plano',
                    concedido: _notificationGranted,
                    onSolicitar: () => _solicitar(
                      PermissionUtils.requestNotificationPermission,
                      (v) => _notificationGranted = v,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _todosConcedidos ? () => context.go('/') : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _todosConcedidos
                            ? const Color(0xFF4CAF50)
                            : null,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _todosConcedidos
                            ? 'Continuar'
                            : 'Concede todos los permisos para continuar',
                      ),
                    ),
                  ),
                  if (!_todosConcedidos)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: PermissionUtils.openSettings,
                          child: const Text('Abrir configuración del sistema'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String titulo,
    required String descripcion,
    required bool concedido,
    required VoidCallback onSolicitar,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          icon,
          color: concedido ? const Color(0xFF4CAF50) : Colors.grey,
          size: 32,
        ),
        title: Text(titulo),
        subtitle: Text(descripcion),
        trailing: concedido
            ? const Icon(Icons.check_circle, color: Color(0xFF4CAF50))
            : TextButton(
                onPressed: onSolicitar,
                child: const Text('Conceder'),
              ),
      ),
    );
  }
}
