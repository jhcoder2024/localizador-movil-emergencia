import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/app_database.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/blocked_number_dao.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/sms_dao.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/conversation_dao.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:drift/drift.dart';

class SmsEventService {
  static const _eventChannel = EventChannel('com.example.localizador_movil_emergencia/sms_events');
  
  final SmsDao _smsDao;
  final ConversationDao _conversationDao;
  final BlockedNumberDao _blockedNumberDao;
  StreamSubscription? _subscription;

  SmsEventService(this._smsDao, this._conversationDao, this._blockedNumberDao);

  void startListening() {
    _subscription?.cancel();
    _subscription = _eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is Map) {
          _handleIncomingSms(event.cast<String, dynamic>());
        }
      },
      onError: (error) {
        debugPrint('[SmsEvent] Error: $error');
      },
    );
    debugPrint('[SmsEvent] Escuchando SMS entrantes...');
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _handleIncomingSms(Map<String, dynamic> smsData) async {
    try {
      final address = (smsData['address'] as String?)?.trim() ?? '';
      final body = (smsData['body'] as String?) ?? '';
      final date = (smsData['date'] as int?) ?? DateTime.now().millisecondsSinceEpoch;
      
      if (address.isEmpty) return;

      final conversationId = address.replaceAll(RegExp(r'[^\d+]'), '');

      if (await _blockedNumberDao.isBlocked(conversationId)) {
        debugPrint('[SmsEvent] SMS bloqueado de $address');
        return;
      }

      // Insertar mensaje
      await _smsDao.insertMessage(SmsMessagesTableCompanion(
        conversationId: Value(conversationId),
        remitente: Value(address),
        telefono: Value(address),
        cuerpo: Value(body),
        fecha: Value(date),
        tipo: const Value(1), // received
        leido: const Value(false),
        tieneMms: const Value(false),
      ));

      // Actualizar o crear conversación
      await _conversationDao.upsert(ConversationsTableCompanion(
        id: Value(conversationId),
        remitente: Value(address),
        telefono: Value(address),
        ultimoMensaje: Value(body),
        ultimaFecha: Value(date),
        noLeidos: Value(1),
      ));

      // Nota: Si la conversación ya existe, el upsert incrementa noLeidos
      // Para sumar en lugar de reemplazar, necesitamos lógica adicional
      // Por ahora, el upsert reemplaza noLeidos con 1 si no existe

      debugPrint('[SmsEvent] SMS almacenado de $address');

      // Mostrar notificación con acción "Responder"
      try {
        await _showSmsNotification(address, body, conversationId);
      } catch (e) {
        debugPrint('[SmsEvent] Error mostrando notificación: $e');
      }
    } catch (e) {
      debugPrint('[SmsEvent] Error procesando SMS: $e');
    }
  }

  Future<void> _showSmsNotification(String sender, String body, String conversationId) async {
    final plugin = FlutterLocalNotificationsPlugin();

    final reenviarAction = AndroidNotificationAction(
      'abrir_conversacion',
      'Responder',
      showsUserInterface: true,
    );

    await plugin.show(
      conversationId.hashCode,
      sender,
      body.length > 100 ? '${body.substring(0, 100)}...' : body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'localizador_channel',
          'Localizador',
          importance: Importance.high,
          priority: Priority.high,
          actions: [reenviarAction],
        ),
      ),
      payload: conversationId,
    );
  }
}
