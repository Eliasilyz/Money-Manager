import 'package:drift/drift.dart';
import 'package:money_manager/database/tables/debts_table.dart';
import 'package:money_manager/database/tables/debt_payments_table.dart';
import 'package:money_manager/database/database.dart';

part 'debts_dao.g.dart';

@DriftAccessor(tables: [DebtsTable, DebtPaymentsTable])
class DebtsDao extends DatabaseAccessor<AppDatabase> with _$DebtsDaoMixin {
  final AppDatabase db;

  DebtsDao(this.db) : super(db);

  Future<int> insertDebt(DebtsTableCompanion debt) =>
      into(debtsTable).insert(debt);

  Future<bool> updateDebt(DebtsTableCompanion debt) =>
      update(debtsTable).replace(debt);

  Future<int> deleteDebt(String id) =>
      (delete(debtsTable)..where((d) => d.id.equals(id))).go();

  Stream<List<Debt>> watchAllDebts() => select(debtsTable).watch();

  Future<List<Debt>> getAllDebts() => select(debtsTable).get();

  Future<Debt?> getDebtById(String id) =>
      (select(debtsTable)..where((d) => d.id.equals(id))).getSingleOrNull();

  Stream<List<Debt>> watchOverdueDebts(DateTime now) => (select(debtsTable)
        ..where((d) => d.dueDate.isSmallerThanValue(now))
        ..where((d) => d.remainingAmount.isNotValue(0))
        ..where((d) => d.status.equals('unpaid').not()))
      .watch();

  Future<int> insertDebtPayment(DebtPaymentsTableCompanion payment) =>
      into(debtPaymentsTable).insert(payment);

  Stream<List<DebtPayment>> watchPaymentsForDebt(String debtId) =>
      (select(debtPaymentsTable)..where((p) => p.debtId.equals(debtId)))
          .watch();

  Future<List<DebtPayment>> getPaymentsForDebt(String debtId) =>
      (select(debtPaymentsTable)..where((p) => p.debtId.equals(debtId))).get();
}
