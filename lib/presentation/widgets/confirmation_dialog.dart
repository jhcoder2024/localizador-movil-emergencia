import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localizador_movil_emergencia/domain/entities/tipo_emergencia.dart';

class ConfirmationDialog extends StatefulWidget {
  final TipoEmergencia tipo;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmationDialog({
    super.key,
    required this.tipo,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog>
    with SingleTickerProviderStateMixin {
  static const int _segundosTotales = 10;
  int _segundosRestantes = _segundosTotales;
  Timer? _timer;
  late final AnimationController _animController;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _iniciarContador();
  }

  void _iniciarContador() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundosRestantes <= 1) {
        timer.cancel();
        _animController.stop();
        widget.onConfirm();
        return;
      }
      setState(() {
        _segundosRestantes--;
      });
      if (_segundosRestantes == 3) {
        HapticFeedback.heavyImpact();
        _animController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progreso = _segundosRestantes / _segundosTotales;
    final color = _segundosRestantes <= 3
        ? const Color(0xFFD32F2F)
        : const Color(0xFFFF9800);

    return Material(
      color: Colors.black54,
      child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, size: 64, color: color),
              const SizedBox(height: 24),
              Text(
                '⚠️ Localizador: ${widget.tipo.displayName}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Se activará el protocolo de emergencia y se enviará tu ubicación a tus contactos.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (context, child) => Transform.translate(
                  offset: Offset(_shakeAnim.value, 0),
                  child: child,
                ),
                child: Text(
                  '$_segundosRestantes',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 72,
                      ),
                ),
              ),
              const Text(
                'segundos',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progreso,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _segundosRestantes <= 3
                    ? '¡Activación inminente!'
                    : 'La emergencia se activará automáticamente',
                style: TextStyle(
                  color: _segundosRestantes <= 3
                      ? const Color(0xFFD32F2F)
                      : Colors.grey,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _timer?.cancel();
                    _animController.stop();
                    widget.onCancel();
                  },
                  icon: const Icon(Icons.block, size: 24),
                  label: const Text(
                    'ABORTAR',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
