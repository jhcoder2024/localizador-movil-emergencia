import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localizador_movil_emergencia/presentation/providers/inbox_provider.dart';

class BlockedNumbersScreen extends StatelessWidget {
  const BlockedNumbersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Números bloqueados'),
      ),
      body: Consumer<InboxProvider>(
        builder: (context, provider, _) {
          final blocked = provider.blockedNumbers;

          if (blocked.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay números bloqueados',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mantén presionada una conversación para bloquearla',
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: blocked.length,
            itemBuilder: (context, index) {
              final conv = blocked[index];
              final hora = _formatTime(conv.ultimaFecha);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red[100],
                  child: const Icon(Icons.block, color: Colors.red),
                ),
                title: Text(
                  conv.remitente,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Bloqueado $hora',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                trailing: TextButton(
                  onPressed: () => _confirmarDesbloqueo(context, provider, conv.id),
                  child: const Text('Desbloquear'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmarDesbloqueo(BuildContext context, InboxProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desbloquear número'),
        content: Text('¿Desbloquear $id?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.unblockNumber(id);
            },
            child: const Text('Desbloquear'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inHours < 1) return 'hace ${diff.inMinutes}m';
    if (diff.inDays < 1) return 'hace ${diff.inHours}h';
    if (diff.inDays == 1) return 'ayer';
    return '${date.day}/${date.month}';
  }
}
