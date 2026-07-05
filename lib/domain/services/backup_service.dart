import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:localizador_movil_emergencia/domain/entities/conversation.dart';
import 'package:localizador_movil_emergencia/domain/entities/sms_message.dart';
import 'package:localizador_movil_emergencia/domain/repositories/sms_inbox_repository.dart';

class BackupService {
  final SmsInboxRepository _smsInboxRepository;

  BackupService(this._smsInboxRepository);

  Future<void> exportToJson(
    List<Conversation> conversations,
    List<SmsMessage> messages,
  ) async {
    try {
      final data = {
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'conversations': conversations.map((c) => {
          'id': c.id,
          'remitente': c.remitente,
          'telefono': c.telefono,
          'ultimoMensaje': c.ultimoMensaje,
          'ultimaFecha': c.ultimaFecha.toIso8601String(),
          'noLeidos': c.noLeidos,
        }).toList(),
        'messages': messages.map((m) => {
          if (m.id != null) 'id': m.id,
          'conversationId': m.conversationId,
          'remitente': m.remitente,
          'telefono': m.telefono,
          'cuerpo': m.cuerpo,
          'fecha': m.fecha.toIso8601String(),
          'tipo': m.tipo.name,
          'leido': m.leido,
          'tieneMms': m.tieneMms,
          'estadoEnvio': m.estadoEnvio,
        }).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/localizador_backup.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Copia de seguridad - Localizador Móvil',
        text: 'Copia de seguridad de mensajes',
      );
    } catch (e) {
      debugPrint('[Backup] Error exportando: $e');
      rethrow;
    }
  }

  Future<int> importFromJson(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final data = json.decode(jsonString) as Map<String, dynamic>;

      final conversationsJson = data['conversations'] as List<dynamic>;
      final messagesJson = data['messages'] as List<dynamic>;

      final conversations = conversationsJson.map((c) => Conversation(
        id: c['id'] as String,
        remitente: c['remitente'] as String,
        telefono: c['telefono'] as String,
        ultimoMensaje: c['ultimoMensaje'] as String,
        ultimaFecha: DateTime.parse(c['ultimaFecha'] as String),
        noLeidos: c['noLeidos'] as int? ?? 0,
      )).toList();

      final messages = messagesJson.map((m) => SmsMessage(
        id: m['id'] as int?,
        conversationId: m['conversationId'] as String,
        remitente: m['remitente'] as String,
        telefono: m['telefono'] as String,
        cuerpo: m['cuerpo'] as String,
        fecha: DateTime.parse(m['fecha'] as String),
        tipo: m['tipo'] == 'received' ? MensajeType.received : MensajeType.sent,
        leido: m['leido'] as bool? ?? false,
        tieneMms: m['tieneMms'] as bool? ?? false,
        estadoEnvio: m['estadoEnvio'] as String? ?? 'sent',
      )).toList();

      for (final conv in conversations) {
        await _smsInboxRepository.upsertConversation(conv);
      }
      await _smsInboxRepository.insertMessages(messages);

      return messages.length;
    } catch (e) {
      debugPrint('[Backup] Error importando: $e');
      rethrow;
    }
  }
}
