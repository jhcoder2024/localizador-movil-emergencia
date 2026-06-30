import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localizador_movil_emergencia/core/utils/permission_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarPermisos();
  }

  Future<void> _verificarPermisos() async {
    final granted = await PermissionUtils.checkLocationPermission();
    if (!mounted) return;
    if (granted) {
      context.go('/');
    } else {
      context.go('/permissions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 80, color: Color(0xFFD32F2F)),
            SizedBox(height: 24),
            Text(
              'Localizador Móvil\nde Emergencia',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD32F2F),
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(color: Color(0xFFD32F2F)),
          ],
        ),
      ),
    );
  }
}
