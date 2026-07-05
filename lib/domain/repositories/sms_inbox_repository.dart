import 'package:localizador_movil_emergencia/domain/entities/conversation.dart';
import 'package:localizador_movil_emergencia/domain/entities/sms_message.dart';

abstract class SmsInboxRepository {
  Stream<List<Conversation>> watchConversations();
  Stream<List<Conversation>> watchArchivedConversations();
  Stream<List<SmsMessage>> watchMessages(String conversationId);
  Future<List<SmsMessage>> searchMessages(String query);
  Future<void> insertMessage(SmsMessage message);
  Future<void> insertMessages(List<SmsMessage> messages);
  Future<void> markAsRead(String conversationId);
  Future<void> upsertConversation(Conversation conversation);
  Future<void> archiveConversation(String conversationId, bool archived);
  Future<void> deleteConversation(String conversationId);

  Future<bool> isNumberBlocked(String phoneNumber);
  Future<void> blockNumber(String phoneNumber);
  Future<void> unblockNumber(String phoneNumber);
  Stream<List<Conversation>> watchBlockedNumbers();
}
