import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:localizador_movil_emergencia/domain/entities/conversation.dart';
import 'package:localizador_movil_emergencia/domain/services/sms_sync_service.dart';
import 'package:localizador_movil_emergencia/app/di/presentation_module.dart';
import 'package:localizador_movil_emergencia/presentation/providers/inbox_provider.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InboxProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InboxProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mensajes'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => context.push('/config'),
              ),
            ],
          ),
          body: _buildBody(provider),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _mostrarDialogoEmergencia(context);
            },
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.warning_amber_rounded),
            label: const Text('EMERGENCIA'),
          ),
        );
      },
    );
  }

  Widget _buildBody(InboxProvider provider) {
    if (provider.cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.vacio) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay conversaciones',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tus mensajes aparecerán aquí',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshSms,
      child: ListView.builder(
        itemCount: provider.conversations.length,
        itemBuilder: (context, index) {
          final conv = provider.conversations[index];
          return _buildConversationTile(context, conv);
        },
      ),
    );
  }

  Widget _buildConversationTile(BuildContext context, Conversation conv) {
    final hora = _formatTime(conv.ultimaFecha);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.primaries[conv.remitente.length % Colors.primaries.length],
        child: Text(
          conv.remitente.isNotEmpty ? conv.remitente[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        conv.remitente,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        conv.ultimoMensaje,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            hora,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          if (conv.noLeidos > 0) ...[
            const SizedBox(height: 4),
            CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Text(
                '${conv.noLeidos}',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
      onTap: () {
        context.push('/conversation/${conv.id}');
      },
    );
  }

  void _mostrarDialogoEmergencia(BuildContext context) {
    context.push('/?tab=emergencia');
  }

  Future<void> _refreshSms() async {
    try {
      final syncService = getIt<SmsSyncService>();
      final nuevos = await syncService.syncIncremental();
      if (nuevos > 0 && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$nuevos mensajes nuevos'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('[Inbox] Error refreshing: $e');
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) return 'Ayer';
    return '${date.day}/${date.month}';
  }
}
