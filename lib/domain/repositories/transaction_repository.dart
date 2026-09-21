import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/domain/entities/transfer.dart';

abstract class ITransactionRepository {
  Future<List<Transaction>> getAllTransactions();
  Stream<List<Transaction>> watchAllTransactions();
  Stream<List<Transaction>> watchTransactionsByAccount(String accountId);
  Stream<List<Transaction>> watchTransactionsByType(String type);
  Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end);
  Future<void> insertTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);

  Future<List<Transfer>> getAllTransfers();
  Stream<List<Transfer>> watchTransfersByAccount(String accountId);
  Future<void> insertTransfer(Transfer transfer);
}
