import 'package:flutter/foundation.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/app_database.dart';
import 'package:localizador_movil_emergencia/data/datasources/remote/sms_content_provider_datasource.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/sms_dao.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/conversation_dao.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/config_dao.dart';
import 'package:drift/drift.dart';

class SmsSyncService {
  final SmsContentProviderDataSource _contentProvider;
  final SmsDao _smsDao;
  final ConversationDao _conversationDao;
  final ConfigDao _configDao;

  SmsSyncService(
    this._contentProvider,
    this._smsDao,
    this._conversationDao,
    this._configDao,
  );

  static const _lastSyncKey = 'last_sms_sync_timestamp';

  Future<int> syncAll() async {
    debugPrint('[SmsSync] Iniciando sincronización completa...');
    final smsList = await _contentProvider.getAllSms();
    final count = await _processSmsBatch(smsList);

    // Actualizar timestamp para futuras sincronizaciones incrementales
    await _configDao.setConfig(_lastSyncKey, DateTime.now().millisecondsSinceEpoch.toString());

    return count;
  }

  Future<int> syncIncremental() async {
    var lastSync = await _configDao.getConfig(_lastSyncKey);
    var since = lastSync != null ? int.tryParse(lastSync) ?? 0 : 0;

    // Si es la primera vez, tomar desde hace 1 hora
    if (since == 0) {
      since = DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch;
    }

    debugPrint('[SmsSync] Sincronización incremental desde $since');
    final smsList = await _contentProvider.getNewSms(since);
    
    if (smsList.isEmpty) {
      debugPrint('[SmsSync] No hay SMS nuevos');
      return 0;
    }
    
    final count = await _processSmsBatch(smsList);
    
    // Actualizar timestamp
    await _configDao.setConfig(_lastSyncKey, DateTime.now().millisecondsSinceEpoch.toString());
    
    return count;
  }

  Future<int> _processSmsBatch(List<Map<String, dynamic>> smsList) async {
    if (smsList.isEmpty) return 0;

    final conversations = <String, Map<String, dynamic>>{};
    final messageCompanions = <SmsMessagesTableCompanion>[];
    final existingIds = <int>{};
    
    // Cargar IDs existentes para evitar duplicados
    try {
      final existing = await _smsDao.getAllIds();
      existingIds.addAll(existing);
    } catch (_) {}

    for (final sms in smsList) {
      final smsId = sms['id'] as int;
      
      // Evitar duplicados
      if (existingIds.contains(smsId)) continue;
      existingIds.add(smsId);

      final address = (sms['address'] as String?)?.trim() ?? '';
      final body = (sms['body'] as String?) ?? '';
      final date = (sms['date'] as int?) ?? 0;
      final type = (sms['type'] as int?) ?? 1;
      final isRead = (sms['read'] as int?) == 1;

      if (address.isEmpty) continue;

      // Normalizar teléfono
      final normalizedAddress = address.replaceAll(RegExp(r'[^\d+]'), '');
      final conversationId = normalizedAddress;

      // Actualizar conversación
      if (!conversations.containsKey(conversationId)) {
        conversations[conversationId] = {
          'id': conversationId,
          'remitente': address,
          'telefono': address,
          'ultimoMensaje': body,
          'ultimaFecha': date,
          'noLeidos': isRead ? 0 : 1,
        };
      } else {
        final conv = conversations[conversationId]!;
        if ((conv['ultimaFecha'] as int) < date) {
          conv['ultimoMensaje'] = body;
          conv['ultimaFecha'] = date;
        }
        if (!isRead) {
          conv['noLeidos'] = (conv['noLeidos'] as int) + 1;
        }
      }

      messageCompanions.add(SmsMessagesTableCompanion(
        id: Value(smsId),
        conversationId: Value(conversationId),
        remitente: Value(address),
        telefono: Value(address),
        cuerpo: Value(body),
        fecha: Value(date),
        tipo: Value(type == 2 ? 2 : 1),
        leido: Value(isRead),
        tieneMms: const Value(false),
      ));
    }

    // Insertar conversaciones
    for (final conv in conversations.values) {
      await _conversationDao.upsert(
        ConversationsTableCompanion(
          id: Value(conv['id'] as String),
          remitente: Value(conv['remitente'] as String),
          telefono: Value(conv['telefono'] as String),
          ultimoMensaje: Value(conv['ultimoMensaje'] as String),
          ultimaFecha: Value(conv['ultimaFecha'] as int),
          noLeidos: Value(conv['noLeidos'] as int),
        ),
      );
    }

    // Insertar mensajes en batch
    if (messageCompanions.isNotEmpty) {
      await _smsDao.insertMessages(messageCompanions);
    }

    debugPrint('[SmsSync] Sincronizados ${messageCompanions.length} SMS, ${conversations.length} conversaciones');
    return messageCompanions.length;
  }
}
