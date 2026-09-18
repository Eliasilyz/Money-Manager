import 'package:drift/drift.dart';
import 'package:money_manager/database/tables/transactions_table.dart';
import 'package:money_manager/database/tables/transfers_table.dart';
import 'package:money_manager/database/database.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [TransactionsTable, TransfersTable])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  final AppDatabase db;

  TransactionsDao(this.db) : super(db);

  Future<int> insertTransaction(TransactionsTableCompanion transaction) =>
      into(transactionsTable).insert(transaction);

  Future<int> deleteTransaction(String id) =>
      (delete(transactionsTable)..where((t) => t.id.equals(id))).go();

  Future<List<Transaction>> getAllTransactions() =>
      select(transactionsTable).get();

  Stream<List<Transaction>> watchAllTransactions() =>
      select(transactionsTable).watch();

  Stream<List<Transaction>> watchTransactionsByDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(transactionsTable)
          ..where((t) => t.date.isBetweenValues(start, end)))
        .watch();
  }

  Stream<List<Transaction>> watchTransactionsByAccount(String accountId) =>
      (select(transactionsTable)..where((t) => t.accountId.equals(accountId)))
          .watch();

  Stream<List<Transaction>> watchTransactionsByCategory(String categoryId) =>
      (select(transactionsTable)..where((t) => t.categoryId.equals(categoryId)))
          .watch();

  Stream<List<Transaction>> watchTransactionsByType(String type) =>
      (select(transactionsTable)..where((t) => t.type.equals(type))).watch();

  Stream<List<Transaction>> watchTransactionsByAccountAndDate(
    String accountId,
    DateTime start,
    DateTime end,
  ) {
    return (select(transactionsTable)
          ..where((t) => t.accountId.equals(accountId))
          ..where((t) => t.date.isBetweenValues(start, end)))
        .watch();
  }

  Future<int> insertTransfer(TransfersTableCompanion transfer) =>
      into(transfersTable).insert(transfer);

  Future<List<Transfer>> getAllTransfers() => select(transfersTable).get();

  Stream<List<Transfer>> watchAllTransfers() => select(transfersTable).watch();
}
