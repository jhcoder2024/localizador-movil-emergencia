import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localizador_movil_emergencia/domain/entities/tipo_emergencia.dart';

class EmergencyButton extends StatefulWidget {
  final TipoEmergencia tipo;
  final VoidCallback onPressed;
  final bool enabled;

  const EmergencyButton({
    super.key,
    required this.tipo,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton> {
  bool _isPressed = false;

  Color _getColor() {
    return const Color(0xFFD32F2F);
  }

  IconData _getIcon() {
    return Icons.warning_amber_rounded;
  }

  void _handlePress() {
    if (!widget.enabled) return;
    HapticFeedback.heavyImpact();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: AnimatedOpacity(
        opacity: widget.enabled ? 1.0 : 0.6,
        duration: const Duration(milliseconds: 200),
        child: Listener(
          onPointerDown: (_) {
            if (widget.enabled) {
              setState(() => _isPressed = true);
            }
          },
          onPointerUp: (_) => setState(() => _isPressed = false),
          onPointerCancel: (_) => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: SizedBox(
              width: double.infinity,
              height: 80,
              child: ElevatedButton(
                onPressed: _handlePress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getColor(),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_getIcon(), size: 32),
                    const SizedBox(width: 16),
                    Text(widget.tipo.displayName,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
