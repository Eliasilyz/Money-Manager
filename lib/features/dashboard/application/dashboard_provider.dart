import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/domain/entities/account.dart';
import 'package:money_manager/domain/entities/exchange_rate.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/currencies/application/currency_provider.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';

enum DashboardPeriod { thisMonth, threeMonths, thisYear }

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

final dashboardPeriodProvider = StateProvider<DashboardPeriod>((ref) => DashboardPeriod.thisMonth);

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final period = ref.watch(dashboardPeriodProvider);
  final accountRepo = ref.watch(accountRepositoryProvider);
  final txRepo = ref.watch(transactionRepositoryProvider);
  final catRepo = ref.watch(categoryRepositoryProvider);
  final baseCode = ref.watch(baseCurrencyCodeProvider);
  final ratesAsync = ref.watch(exchangeRatesProvider);
  final rates = ratesAsync.valueOrNull ?? const <String, double>{};

  final accounts = await accountRepo.getAllAccounts();

  final now = DateTime.now();
  final periodEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
  DateTime periodStart;

  switch (period) {
    case DashboardPeriod.threeMonths:
      periodStart = DateTime(now.year, now.month - 3, 1);
      break;
    case DashboardPeriod.thisYear:
      periodStart = DateTime(now.year, 1, 1);
      break;
    case DashboardPeriod.thisMonth:
      periodStart = DateTime(now.year, now.month, 1);
      break;
  }

  final transactions = await txRepo.getTransactionsByDateRange(periodStart, periodEnd);

  final totalBalance = accounts.fold<int>(
    0,
    (sum, a) => sum +
        convertAmount(a.initialBalance, a.currencyCode, baseCode, rates).round(),
  );
  final totalIncome = transactions
      .where((t) => t.type == 'income')
      .fold<int>(0, (sum, t) => sum + convertAmount(t.amount, t.currencyCode, baseCode, rates).round());
  final totalExpenses = transactions
      .where((t) => t.type == 'expense')
      .fold<int>(0, (sum, t) => sum + convertAmount(t.amount, t.currencyCode, baseCode, rates).round());

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
