import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localizador_movil_emergencia/domain/services/sms_sync_service.dart';
import 'package:localizador_movil_emergencia/domain/services/sms_event_service.dart';
import 'package:localizador_movil_emergencia/app/di/presentation_module.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    // Esperar un momento para mostrar el splash
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Sincronizar SMS del sistema
    try {
      final smsSyncService = getIt<SmsSyncService>();
      await smsSyncService.syncAll();
    } catch (e) {
      debugPrint('[Splash] Error en sync SMS: $e');
    }

    // Iniciar escucha de SMS entrantes
    try {
      final smsEventService = getIt<SmsEventService>();
      smsEventService.startListening();
    } catch (e) {
      debugPrint('[Splash] Error en event service: $e');
    }

    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD32F2F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              'Localizador Móvil\nde Emergencia',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Preparando tu app de emergencia...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
