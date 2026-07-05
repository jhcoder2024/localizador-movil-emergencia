import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:localizador_movil_emergencia/domain/entities/conversation.dart';
import 'package:localizador_movil_emergencia/domain/repositories/sms_inbox_repository.dart';

class InboxProvider extends ChangeNotifier {
  final SmsInboxRepository _smsInboxRepository;
  StreamSubscription? _conversationsSub;
  StreamSubscription? _blockedSub;

  List<Conversation> _conversations = [];
  List<Conversation> _blockedNumbers = [];
  bool _cargando = true;

  InboxProvider({required SmsInboxRepository smsInboxRepository})
      : _smsInboxRepository = smsInboxRepository;

  List<Conversation> get conversations => _conversations;
  List<Conversation> get blockedNumbers => _blockedNumbers;
  bool get cargando => _cargando;
  bool get vacio => !_cargando && _conversations.isEmpty;

  void init() {
    _conversationsSub?.cancel();
    _conversationsSub = _smsInboxRepository.watchConversations().listen((convs) {
      _conversations = convs;
      _cargando = false;
      notifyListeners();
    });
    _blockedSub?.cancel();
    _blockedSub = _smsInboxRepository.watchBlockedNumbers().listen((blocked) {
      _blockedNumbers = blocked;
      notifyListeners();
    });
  }

  Future<void> archiveConversation(String id) async {
    await _smsInboxRepository.archiveConversation(id, true);
  }

  Future<void> deleteConversation(String id) async {
    await _smsInboxRepository.deleteConversation(id);
  }

  Future<bool> isNumberBlocked(String phoneNumber) async {
    return _smsInboxRepository.isNumberBlocked(phoneNumber);
  }

  Future<void> blockNumber(String phoneNumber) async {
    await _smsInboxRepository.blockNumber(phoneNumber);
  }

  Future<void> unblockNumber(String phoneNumber) async {
    await _smsInboxRepository.unblockNumber(phoneNumber);
  }

  Stream<List<Conversation>> watchArchivedConversations() {
    return _smsInboxRepository.watchArchivedConversations();
  }

  @override
  void dispose() {
    _conversationsSub?.cancel();
    _blockedSub?.cancel();
    super.dispose();
  }
}
