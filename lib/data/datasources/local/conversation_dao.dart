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

  Future<void> upsert(ConversationsTableCompanion conversation) {
    return into(conversationsTable).insertOnConflictUpdate(conversation);
  }
}
