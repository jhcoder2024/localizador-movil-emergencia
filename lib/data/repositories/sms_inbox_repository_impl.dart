import 'package:drift/drift.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/app_database.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/conversation_dao.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/sms_dao.dart';
import 'package:localizador_movil_emergencia/data/mappers/sms_mappers.dart';
import 'package:localizador_movil_emergencia/domain/entities/conversation.dart';
import 'package:localizador_movil_emergencia/domain/entities/sms_message.dart';
import 'package:localizador_movil_emergencia/domain/repositories/sms_inbox_repository.dart';

class SmsInboxRepositoryImpl implements SmsInboxRepository {
  final ConversationDao _conversationDao;
  final SmsDao _smsDao;

  SmsInboxRepositoryImpl(this._conversationDao, this._smsDao);

  @override
  Stream<List<Conversation>> watchConversations() {
    return _conversationDao.watchActiveConversations().map(
      (rows) => rows.map(SmsMappers.fromConversationTable).toList(),
    );
  }

  @override
  Stream<List<Conversation>> watchArchivedConversations() {
    return _conversationDao.watchArchivedConversations().map(
      (rows) => rows.map(SmsMappers.fromConversationTable).toList(),
    );
  }

  @override
  Stream<List<SmsMessage>> watchMessages(String conversationId) {
    return _smsDao.watchMessages(conversationId).map(
      (rows) => rows.map(SmsMappers.fromSmsMessageTable).toList(),
    );
  }

  @override
  Future<List<SmsMessage>> searchMessages(String query) async {
    if (query.trim().isEmpty) return [];
    final results = await _smsDao.buscarMensajes(query.trim());
    return results.map(SmsMappers.fromSmsMessageTable).toList();
  }

  @override
  Future<void> insertMessage(SmsMessage message) async {
    await _smsDao.insertMessage(SmsMappers.toSmsMessageCompanion(message));
  }

  @override
  Future<void> insertMessages(List<SmsMessage> messages) async {
    await _smsDao.insertMessages(
      messages.map(SmsMappers.toSmsMessageCompanion).toList(),
    );
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    await _smsDao.markAsRead(conversationId);
    final messages = await _smsDao.watchMessages(conversationId).first;
    final noLeidos = messages.where((m) => !m.leido).length;
    await _conversationDao.upsert(
      ConversationsTableCompanion(
        id: Value(conversationId),
        noLeidos: Value(noLeidos),
      ),
    );
  }

  @override
  Future<void> upsertConversation(Conversation conversation) async {
    await _conversationDao.upsert(SmsMappers.toConversationCompanion(conversation));
  }

  @override
  Future<void> archiveConversation(String conversationId, bool archived) async {
    await _conversationDao.archive(conversationId, archived);
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await _smsDao.deleteByConversation(conversationId);
    await _conversationDao.deleteById(conversationId);
  }
}
