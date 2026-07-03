import 'package:drift/drift.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/app_database.dart';

part 'sms_dao.g.dart';

@DriftAccessor(tables: [SmsMessagesTable])
class SmsDao extends DatabaseAccessor<AppDatabase> with _$SmsDaoMixin {
  SmsDao(super.db);

  Stream<List<SmsMessagesTableData>> watchMessages(String conversationId) {
    return (select(smsMessagesTable)
          ..where((t) => t.conversationId.equals(conversationId))
          ..orderBy([(t) => OrderingTerm(expression: t.fecha, mode: OrderingMode.asc)]))
        .watch();
  }

  Future<void> insertMessage(SmsMessagesTableCompanion message) {
    return into(smsMessagesTable).insert(message);
  }

  Future<void> insertMessages(List<SmsMessagesTableCompanion> messages) {
    return batch((batch) {
      batch.insertAll(smsMessagesTable, messages);
    });
  }

  Future<void> markAsRead(String conversationId) {
    return (update(smsMessagesTable)
          ..where((t) => t.conversationId.equals(conversationId))
          ..where((t) => t.leido.equals(false)))
        .write(const SmsMessagesTableCompanion(leido: Value(true)));
  }
}
