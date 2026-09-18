import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/domain/repositories/transaction_repository.dart';
import 'package:money_manager/domain/services/transaction_service.dart';

final transactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService(ref.read(transactionRepositoryProvider));
});

final transactionRepositoryProvider = Provider<ITransactionRepository>((ref) {
  throw UnimplementedError('TransactionRepository not initialized');
});

class TransactionsNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  final ITransactionRepository _repo;

  TransactionsNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = const AsyncValue.loading();
    try {
      final transactions = await _repo.getAllTransactions();
      transactions.sort((a, b) => b.date.compareTo(a.date));
      state = AsyncValue.data(transactions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTransaction(String id) async {
    await _repo.deleteTransaction(id);
    await loadTransactions();
  }
}

final transactionsNotifierProvider = StateNotifierProvider<TransactionsNotifier, AsyncValue<List<Transaction>>>((ref) {
  return TransactionsNotifier(ref.read(transactionRepositoryProvider));
});

final transactionsByAccountProvider = StreamProvider.family<List<Transaction>, String>((ref, accountId) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchTransactionsByAccount(accountId);
});

final transactionsByDateRangeProvider = FutureProvider.family<List<Transaction>, ({DateTime start, DateTime end})>((ref, dates) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final transactions = await repo.getTransactionsByDateRange(dates.start, dates.end);
  transactions.sort((a, b) => b.date.compareTo(a.date));
  return transactions;
});
