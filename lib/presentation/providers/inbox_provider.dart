import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:localizador_movil_emergencia/domain/entities/conversation.dart';
import 'package:localizador_movil_emergencia/domain/repositories/sms_inbox_repository.dart';

class InboxProvider extends ChangeNotifier {
  final SmsInboxRepository _smsInboxRepository;
  StreamSubscription? _conversationsSub;

  List<Conversation> _conversations = [];
  bool _cargando = true;

  InboxProvider({required SmsInboxRepository smsInboxRepository})
      : _smsInboxRepository = smsInboxRepository;

  List<Conversation> get conversations => _conversations;
  bool get cargando => _cargando;
  bool get vacio => !_cargando && _conversations.isEmpty;

  void init() {
    _conversationsSub?.cancel();
    _conversationsSub = _smsInboxRepository.watchConversations().listen((convs) {
      _conversations = convs;
      _cargando = false;
      notifyListeners();
    });
  }

  Future<void> archiveConversation(String id) async {
    await _smsInboxRepository.archiveConversation(id, true);
  }

  Future<void> deleteConversation(String id) async {
    await _smsInboxRepository.deleteConversation(id);
  }

  Stream<List<Conversation>> watchArchivedConversations() {
    return _smsInboxRepository.watchArchivedConversations();
  }

  @override
  void dispose() {
    _conversationsSub?.cancel();
    super.dispose();
  }
}
