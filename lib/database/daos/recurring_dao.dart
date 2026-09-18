import 'package:drift/drift.dart';
import 'package:money_manager/database/tables/recurring_transactions_table.dart';
import 'package:money_manager/database/database.dart';

part 'recurring_dao.g.dart';

@DriftAccessor(tables: [RecurringTransactionsTable])
class RecurringDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringDaoMixin {
  final AppDatabase db;

  RecurringDao(this.db) : super(db);

  Future<int> insertRecurring(RecurringTransactionsTableCompanion recurring) =>
      into(recurringTransactionsTable).insert(recurring);

  Future<bool> updateRecurring(RecurringTransactionsTableCompanion recurring) =>
      update(recurringTransactionsTable).replace(recurring);

  Future<int> deleteRecurring(String id) =>
      (delete(recurringTransactionsTable)..where((r) => r.id.equals(id))).go();

  Stream<List<RecurringTransaction>> watchAllRecurring() =>
      select(recurringTransactionsTable).watch();

  Stream<List<RecurringTransaction>> watchDueRecurring(DateTime now) =>
      (select(recurringTransactionsTable)
            ..where((r) => r.nextOccurrence.isSmallerOrEqualValue(now))
            ..where((r) => r.enabled.equals(true)))
          .watch();

  Future<List<RecurringTransaction>> getAllRecurring() =>
      select(recurringTransactionsTable).get();

  Future<List<RecurringTransaction>> getDueRecurring(DateTime now) async {
    return (select(recurringTransactionsTable)
          ..where((r) => r.nextOccurrence.isSmallerOrEqualValue(now))
          ..where((r) => r.enabled.equals(true)))
        .get();
  }
}
