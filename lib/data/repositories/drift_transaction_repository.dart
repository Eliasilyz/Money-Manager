import 'package:drift/drift.dart';
import 'package:money_manager/database/database.dart' as drift;
import 'package:money_manager/domain/entities/transaction.dart' as domain;
import 'package:money_manager/domain/entities/transfer.dart' as domain_transfer;
import 'package:money_manager/domain/repositories/transaction_repository.dart';

class DriftTransactionRepository implements ITransactionRepository {
  final drift.AppDatabase _db;

  DriftTransactionRepository(this._db);

  @override
  Future<List<domain.Transaction>> getAllTransactions() async {
    final transactions = await _db.transactionsDao.getAllTransactions();
    return transactions.map((t) => t.toDomain()).toList();
  }

  @override
  Stream<List<domain.Transaction>> watchAllTransactions() =>
      _db.transactionsDao.watchAllTransactions().map((transactions) =>
          transactions.map((t) => t.toDomain()).toList());

  @override
  Stream<List<domain.Transaction>> watchTransactionsByAccount(String accountId) =>
      _db.transactionsDao.watchTransactionsByAccount(accountId).map((transactions) =>
          transactions.map((t) => t.toDomain()).toList());

  @override
  Stream<List<domain.Transaction>> watchTransactionsByType(String type) =>
      _db.transactionsDao.watchTransactionsByType(type).map((transactions) =>
          transactions.map((t) => t.toDomain()).toList());

  @override
  Future<List<domain.Transaction>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final transactions = await _db.transactionsDao.getAllTransactions();
    return transactions
        .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
        .map((t) => t.toDomain())
        .toList();
  }

  @override
  Future<void> insertTransaction(domain.Transaction transaction) async {
    await _db.transactionsDao.insertTransaction(
      drift.TransactionsTableCompanion(
        id: Value(transaction.id),
        type: Value(transaction.type),
        accountId: Value(transaction.accountId),
        categoryId: Value(transaction.categoryId),
        amount: Value(transaction.amount),
        currencyCode: Value(transaction.currencyCode),
        description: Value(transaction.description),
        date: Value(transaction.date),
        note: Value(transaction.note),
        transferId: Value(transaction.transferId),
        createdAt: Value(transaction.createdAt),
        updatedAt: Value(transaction.updatedAt),
      ),
    );
  }

  @override
  Future<void> updateTransaction(domain.Transaction transaction) async {
    await _db.transactionsDao.updateTransaction(
      drift.TransactionsTableCompanion(
        id: Value(transaction.id),
        type: Value(transaction.type),
        accountId: Value(transaction.accountId),
        categoryId: Value(transaction.categoryId),
        amount: Value(transaction.amount),
        currencyCode: Value(transaction.currencyCode),
        description: Value(transaction.description),
        date: Value(transaction.date),
        note: Value(transaction.note),
        transferId: Value(transaction.transferId),
        createdAt: Value(transaction.createdAt),
        updatedAt: Value(transaction.updatedAt),
      ),
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _db.transactionsDao.deleteTransaction(id);
  }

  @override
  Future<List<domain_transfer.Transfer>> getAllTransfers() async {
    final transfers = await _db.transactionsDao.getAllTransfers();
    return transfers.map((t) => domain_transfer.Transfer(
          id: t.id,
          fromAccountId: t.fromAccountId,
          toAccountId: t.toAccountId,
          sourceAmount: t.sourceAmount,
          destinationAmount: t.destinationAmount,
          currencyCode: t.currencyCode,
          exchangeRate: t.exchangeRate,
          description: t.description,
          date: t.date,
          createdAt: t.createdAt,
          updatedAt: t.updatedAt,
        )).toList();
  }

  @override
  Stream<List<domain_transfer.Transfer>> watchTransfersByAccount(String accountId) =>
      _db.transactionsDao.watchAllTransfers().map((transfers) =>
          transfers.where((t) => t.fromAccountId == accountId || t.toAccountId == accountId)
              .map((t) => domain_transfer.Transfer(
                    id: t.id,
                    fromAccountId: t.fromAccountId,
                    toAccountId: t.toAccountId,
                    sourceAmount: t.sourceAmount,
                    destinationAmount: t.destinationAmount,
                    currencyCode: t.currencyCode,
                    exchangeRate: t.exchangeRate,
                    description: t.description,
                    date: t.date,
                    createdAt: t.createdAt,
                    updatedAt: t.updatedAt,
                  )).toList());

  @override
  Future<void> insertTransfer(domain_transfer.Transfer transfer) async {
    await _db.transactionsDao.insertTransfer(
      drift.TransfersTableCompanion(
        id: Value(transfer.id),
        fromAccountId: Value(transfer.fromAccountId),
        toAccountId: Value(transfer.toAccountId),
        sourceAmount: Value(transfer.sourceAmount),
        destinationAmount: Value(transfer.destinationAmount),
        currencyCode: Value(transfer.currencyCode),
        exchangeRate: Value(transfer.exchangeRate),
        description: Value(transfer.description),
        date: Value(transfer.date),
        createdAt: Value(transfer.createdAt),
        updatedAt: Value(transfer.updatedAt),
      ),
    );
  }
}

extension on drift.Transaction {
  domain.Transaction toDomain() => domain.Transaction(
        id: id,
        type: type,
        accountId: accountId,
        categoryId: categoryId,
        amount: amount,
        currencyCode: currencyCode,
        description: description,
        date: date,
        note: note,
        transferId: transferId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
