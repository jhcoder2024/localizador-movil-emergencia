import 'dart:async';
import 'package:flutter/material.dart';
import 'package:localizador_movil_emergencia/domain/entities/estado_emergencia.dart';

class EmergencyActiveBanner extends StatefulWidget {
  final EstadoEmergencia estado;
  final VoidCallback onCancel;

  const EmergencyActiveBanner({
    super.key,
    required this.estado,
    required this.onCancel,
  });

  @override
  State<EmergencyActiveBanner> createState() => _EmergencyActiveBannerState();
}

class _EmergencyActiveBannerState extends State<EmergencyActiveBanner> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration() {
    if (widget.estado.inicioTimestamp == null) return '';
    final diff = DateTime.now().difference(widget.estado.inicioTimestamp!);
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFFD32F2F),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🚨 LOCALIZADOR ACTIVO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${widget.estado.tipo?.displayName ?? ''} - ${_formatDuration()}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: widget.onCancel,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
            ),
            child: const Text('CANCELAR'),
          ),
        ],
      ),
    );
  }
}
