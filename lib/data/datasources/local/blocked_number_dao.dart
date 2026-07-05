import 'package:drift/drift.dart';
import 'package:localizador_movil_emergencia/data/datasources/local/app_database.dart';

part 'blocked_number_dao.g.dart';

@DriftAccessor(tables: [BlockedNumbersTable])
class BlockedNumberDao extends DatabaseAccessor<AppDatabase> with _$BlockedNumberDaoMixin {
  BlockedNumberDao(super.db);

  Future<bool> isBlocked(String phoneNumber) async {
    final normalized = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final row = await (select(blockedNumbersTable)
          ..where((t) => t.id.equals(normalized)))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> block(String phoneNumber) async {
    final normalized = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    await into(blockedNumbersTable).insert(
      BlockedNumbersTableCompanion(
        id: Value(normalized),
        bloqueadoEn: Value(DateTime.now().millisecondsSinceEpoch),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> unblock(String phoneNumber) async {
    final normalized = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    await (delete(blockedNumbersTable)..where((t) => t.id.equals(normalized))).go();
  }

  Stream<List<BlockedNumbersTableData>> watchAll() {
    return (select(blockedNumbersTable)
          ..orderBy([(t) => OrderingTerm(expression: t.bloqueadoEn, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<List<BlockedNumbersTableData>> getAll() async {
    return (select(blockedNumbersTable)
          ..orderBy([(t) => OrderingTerm(expression: t.bloqueadoEn, mode: OrderingMode.desc)]))
        .get();
  }
}
