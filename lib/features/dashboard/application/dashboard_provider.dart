import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/domain/entities/account.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';

class DashboardData {
  final int totalBalance;
  final int totalIncome;
  final int totalExpenses;
  final List<Transaction> recentTransactions;
  final List<Account> accounts;

  const DashboardData({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.recentTransactions,
    required this.accounts,
  });
}

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final accountRepo = ref.watch(accountRepositoryProvider);
  final txRepo = ref.watch(transactionRepositoryProvider);

  final accounts = await accountRepo.getAllAccounts();
  final transactions = await txRepo.getAllTransactions();

  final totalBalance = accounts.fold<int>(0, (sum, a) => sum + a.initialBalance);
  final totalIncome = transactions
      .where((t) => t.type == 'income')
      .fold<int>(0, (sum, t) => sum + t.amount);
  final totalExpenses = transactions
      .where((t) => t.type == 'expense')
      .fold<int>(0, (sum, t) => sum + t.amount);

  final recent = List<Transaction>.from(transactions)
    ..sort((a, b) => b.date.compareTo(a.date));

  return DashboardData(
    totalBalance: totalBalance + totalIncome - totalExpenses,
    totalIncome: totalIncome,
    totalExpenses: totalExpenses,
    recentTransactions: recent.take(5).toList(),
    accounts: accounts,
  );
});
