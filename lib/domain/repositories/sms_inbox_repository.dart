import 'package:localizador_movil_emergencia/domain/entities/conversation.dart';
import 'package:localizador_movil_emergencia/domain/entities/sms_message.dart';

abstract class SmsInboxRepository {
  Stream<List<Conversation>> watchConversations();
  Stream<List<SmsMessage>> watchMessages(String conversationId);
  Future<void> insertMessage(SmsMessage message);
  Future<void> insertMessages(List<SmsMessage> messages);
  Future<void> markAsRead(String conversationId);
  Future<void> upsertConversation(Conversation conversation);
}
