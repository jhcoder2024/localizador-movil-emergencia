import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:localizador_movil_emergencia/domain/entities/sms_message.dart';
import 'package:localizador_movil_emergencia/domain/repositories/sms_inbox_repository.dart';

class ConversationProvider extends ChangeNotifier {
  final SmsInboxRepository _smsInboxRepository;
  static const _smsChannel = MethodChannel('com.example.localizador_movil_emergencia/sms_sync');

  StreamSubscription? _messagesSub;
  List<SmsMessage> _messages = [];
  bool _cargando = true;
  String _conversationId;

  ConversationProvider({
    required SmsInboxRepository smsInboxRepository,
    required String conversationId,
  })  : _smsInboxRepository = smsInboxRepository,
        _conversationId = conversationId;

  List<SmsMessage> get messages => _messages;
  bool get cargando => _cargando;
  String get conversationId => _conversationId;

  void init() {
    _messagesSub?.cancel();
    _messagesSub = _smsInboxRepository.watchMessages(_conversationId).listen((msgs) {
      _messages = msgs;
      _cargando = false;
      notifyListeners();
    });

    // Marcar como leídos al abrir la conversación
    _smsInboxRepository.markAsRead(_conversationId);
  }

  Future<bool> enviarMensaje(String texto) async {
    if (texto.trim().isEmpty) return false;

    final smsId = DateTime.now().millisecondsSinceEpoch.remainder(100000).toInt();

    // Crear mensaje optimistic
    final msg = SmsMessage(
      conversationId: _conversationId,
      remitente: 'Yo',
      telefono: _conversationId,
      cuerpo: texto.trim(),
      fecha: DateTime.now(),
      tipo: MensajeType.sent,
      leido: true,
      estadoEnvio: 'sending',
    );

    // Insertar en BD local (optimistic update)
    await _smsInboxRepository.insertMessage(msg);

    // Intentar envío real
    try {
      final result = await _smsChannel.invokeMethod<Map>('sendSmsFromInbox', {
        'telefono': _conversationId,
        'mensaje': texto.trim(),
        'smsId': smsId,
      });

      final exito = result?['exito'] == true;

      if (!exito) {
        debugPrint('[Conversation] Error enviando SMS: ${result?['error']}');
      }
    } catch (e) {
      debugPrint('[Conversation] Error: $e');
    }

    return true;
  }

  void actualizarEstadoEnvio(int smsId, String estado) {
    notifyListeners();
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    super.dispose();
  }
}
