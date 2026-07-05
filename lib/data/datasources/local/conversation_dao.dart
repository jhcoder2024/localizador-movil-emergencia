import 'package:drift/drift.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/app_database.dart';

part 'conversation_dao.g.dart';

@DriftAccessor(tables: [ConversationsTable])
class ConversationDao extends DatabaseAccessor<AppDatabase> with _$ConversationDaoMixin {
  ConversationDao(super.db);

  Stream<List<ConversationsTableData>> watchConversations() {
    return (select(conversationsTable)
          ..orderBy([(t) => OrderingTerm(expression: t.ultimaFecha, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<ConversationsTableData>> watchActiveConversations() {
    return (select(conversationsTable)
          ..where((t) => t.isArchived.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.ultimaFecha, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<ConversationsTableData>> watchArchivedConversations() {
    return (select(conversationsTable)
          ..where((t) => t.isArchived.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.ultimaFecha, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<void> upsert(ConversationsTableCompanion conversation) {
    return into(conversationsTable).insertOnConflictUpdate(conversation);
  }

  Future<void> archive(String id, bool archived) async {
    await (update(conversationsTable)
          ..where((t) => t.id.equals(id)))
        .write(ConversationsTableCompanion(isArchived: Value(archived)));
  }

  Future<void> deleteById(String id) async {
    await (delete(conversationsTable)..where((t) => t.id.equals(id))).go();
  }
}
