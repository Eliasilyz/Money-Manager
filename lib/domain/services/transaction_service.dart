import 'package:uuid/uuid.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/domain/entities/transfer.dart';
import 'package:money_manager/domain/repositories/transaction_repository.dart';

class TransactionService {
  final ITransactionRepository _transactionRepository;
  final _uuid = const Uuid();

  TransactionService(this._transactionRepository);

  Future<void> addIncome({
    required String accountId,
    String? categoryId,
    required int amount,
    required String currencyCode,
    String? description,
    DateTime? date,
    String? note,
  }) async {
    final now = DateTime.now();
    final transaction = Transaction(
      id: _uuid.v4(),
      type: 'income',
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      currencyCode: currencyCode,
      description: description,
      date: date ?? now,
      note: note,
      createdAt: now,
      updatedAt: now,
    );
    await _transactionRepository.insertTransaction(transaction);
  }

  Future<void> addExpense({
    required String accountId,
    String? categoryId,
    required int amount,
    required String currencyCode,
    String? description,
    DateTime? date,
    String? note,
  }) async {
    final now = DateTime.now();
    final transaction = Transaction(
      id: _uuid.v4(),
      type: 'expense',
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      currencyCode: currencyCode,
      description: description,
      date: date ?? now,
      note: note,
      createdAt: now,
      updatedAt: now,
    );
    await _transactionRepository.insertTransaction(transaction);
  }

  Future<void> addTransfer({
    required String fromAccountId,
    required String toAccountId,
    required int amount,
    required String currencyCode,
    double? exchangeRate,
    DateTime? date,
    String? description,
  }) async {
    final now = date ?? DateTime.now();
    final destinationAmount = _calculateDestinationAmount(amount, exchangeRate);
    final transfer = Transfer(
      id: _uuid.v4(),
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      sourceAmount: amount,
      destinationAmount: destinationAmount,
      currencyCode: currencyCode,
      exchangeRate: exchangeRate,
      description: description,
      date: now,
      createdAt: now,
      updatedAt: now,
    );
    await _transactionRepository.insertTransfer(transfer);
  }

  int _calculateDestinationAmount(int sourceAmount, double? exchangeRate) {
    if (exchangeRate == null) return sourceAmount;
    return (sourceAmount * exchangeRate).toInt();
  }
}
