import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/domain/entities/account.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';

class CategoryExpense {
  final String categoryName;
  final String categoryIcon;
  final int amount;
  CategoryExpense(this.categoryName, this.categoryIcon, this.amount);
}

class DashboardData {
  final int totalBalance;
  final int totalIncome;
  final int totalExpenses;
  final List<Transaction> recentTransactions;
  final List<Account> accounts;
  final List<CategoryExpense> expenseBreakdown;
  final DateTime periodStart;
  final DateTime periodEnd;

  const DashboardData({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.recentTransactions,
    required this.accounts,
    required this.expenseBreakdown,
    required this.periodStart,
    required this.periodEnd,
  });
}

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final accountRepo = ref.watch(accountRepositoryProvider);
  final txRepo = ref.watch(transactionRepositoryProvider);
  final catRepo = ref.watch(categoryRepositoryProvider);

  final accounts = await accountRepo.getAllAccounts();

  final now = DateTime.now();
  final periodStart = DateTime(now.year, now.month, 1);
  final periodEnd = now;

  final transactions = await txRepo.getTransactionsByDateRange(periodStart, periodEnd);

  final totalBalance = accounts.fold<int>(0, (sum, a) => sum + a.initialBalance);
  final totalIncome = transactions
      .where((t) => t.type == 'income')
      .fold<int>(0, (sum, t) => sum + t.amount);
  final totalExpenses = transactions
      .where((t) => t.type == 'expense')
      .fold<int>(0, (sum, t) => sum + t.amount);

  final expenseMap = <String, CategoryExpense>{};
  for (final t in transactions.where((t) => t.type == 'expense')) {
    final cat = t.categoryId != null ? await catRepo.getCategoryById(t.categoryId!) : null;
    final name = cat?.name ?? 'Uncategorized';
    final icon = cat?.icon ?? '📁';
    expenseMap.update(name, (val) => CategoryExpense(name, icon, val.amount + t.amount),
        ifAbsent: () => CategoryExpense(name, icon, t.amount));
  }
  final expenseBreakdown = expenseMap.values.toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));

  final recent = List<Transaction>.from(transactions)
    ..sort((a, b) => b.date.compareTo(a.date));

  return DashboardData(
    totalBalance: totalBalance + totalIncome - totalExpenses,
    totalIncome: totalIncome,
    totalExpenses: totalExpenses,
    recentTransactions: recent.take(10).toList(),
    accounts: accounts,
    expenseBreakdown: expenseBreakdown,
    periodStart: periodStart,
    periodEnd: periodEnd,
  );
});

final dashboardFilteredProvider = FutureProvider.family<DashboardData, (DateTime start, DateTime end)>((ref, dates) async {
  final accountRepo = ref.watch(accountRepositoryProvider);
  final txRepo = ref.watch(transactionRepositoryProvider);
  final catRepo = ref.watch(categoryRepositoryProvider);

  final accounts = await accountRepo.getAllAccounts();
  final transactions = await txRepo.getTransactionsByDateRange(dates.$1, dates.$2);

  final totalBalance = accounts.fold<int>(0, (sum, a) => sum + a.initialBalance);
  final totalIncome = transactions
      .where((t) => t.type == 'income')
      .fold<int>(0, (sum, t) => sum + t.amount);
  final totalExpenses = transactions
      .where((t) => t.type == 'expense')
      .fold<int>(0, (sum, t) => sum + t.amount);

  final expenseMap = <String, CategoryExpense>{};
  for (final t in transactions.where((t) => t.type == 'expense')) {
    final cat = t.categoryId != null ? await catRepo.getCategoryById(t.categoryId!) : null;
    final name = cat?.name ?? 'Uncategorized';
    final icon = cat?.icon ?? '📁';
    expenseMap.update(name, (val) => CategoryExpense(name, icon, val.amount + t.amount),
        ifAbsent: () => CategoryExpense(name, icon, t.amount));
  }
  final expenseBreakdown = expenseMap.values.toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));

  final recent = List<Transaction>.from(transactions)
    ..sort((a, b) => b.date.compareTo(a.date));

  return DashboardData(
    totalBalance: totalBalance + totalIncome - totalExpenses,
    totalIncome: totalIncome,
    totalExpenses: totalExpenses,
    recentTransactions: recent.take(10).toList(),
    accounts: accounts,
    expenseBreakdown: expenseBreakdown,
    periodStart: dates.$1,
    periodEnd: dates.$2,
  );
});
