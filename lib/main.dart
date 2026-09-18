import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:money_manager/database/database.dart';
import 'package:money_manager/data/repositories/drift_account_repository.dart';
import 'package:money_manager/data/repositories/drift_budget_repository.dart';
import 'package:money_manager/data/repositories/drift_category_repository.dart';
import 'package:money_manager/data/repositories/drift_currency_repository.dart';
import 'package:money_manager/data/repositories/drift_debt_repository.dart';
import 'package:money_manager/data/repositories/drift_goal_repository.dart';
import 'package:money_manager/data/repositories/drift_recurring_repository.dart';
import 'package:money_manager/data/repositories/drift_transaction_repository.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/budgets/application/budget_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/currencies/application/currency_provider.dart';
import 'package:money_manager/features/debts/application/debt_provider.dart';
import 'package:money_manager/features/goals/application/goal_provider.dart';
import 'package:money_manager/features/recurring/application/recurring_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/routing/router.dart';
import 'package:money_manager/theme/app_theme.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();

  final accountRepo = DriftAccountRepository(db);
  final categoryRepo = DriftCategoryRepository(db);
  final transactionRepo = DriftTransactionRepository(db);
  final budgetRepo = DriftBudgetRepository(db);
  final goalRepo = DriftGoalRepository(db);
  final debtRepo = DriftDebtRepository(db);
  final recurringRepo = DriftRecurringRepository(db);
  final currencyRepo = DriftCurrencyRepository(db);

  runApp(
    ProviderScope(
      overrides: [
        accountRepositoryProvider.overrideWithValue(accountRepo),
        categoryRepositoryProvider.overrideWithValue(categoryRepo),
        transactionRepositoryProvider.overrideWithValue(transactionRepo),
        budgetRepositoryProvider.overrideWithValue(budgetRepo),
        goalRepositoryProvider.overrideWithValue(goalRepo),
        debtRepositoryProvider.overrideWithValue(debtRepo),
        recurringRepositoryProvider.overrideWithValue(recurringRepo),
        currencyRepositoryProvider.overrideWithValue(currencyRepo),
      ],
      child: const MoneyManagerApp(),
    ),
  );

  // Seed defaults after app starts — don't block first frame
  await _seedDefaults(db);
}

Future<void> _seedDefaults(AppDatabase db) async {
  const uuid = Uuid();
  final now = DateTime.now();

  final existingCurrencies = await db.select(db.currenciesTable).get();
  if (existingCurrencies.isEmpty) {
    await db.batch((batch) {
      batch.insertAll(db.currenciesTable, [
        CurrenciesTableCompanion.insert(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp'),
        CurrenciesTableCompanion.insert(code: 'USD', name: 'US Dollar', symbol: r'$'),
        CurrenciesTableCompanion.insert(code: 'EUR', name: 'Euro', symbol: '\u20ac'),
        CurrenciesTableCompanion.insert(code: 'GBP', name: 'British Pound', symbol: '\u00a3'),
        CurrenciesTableCompanion.insert(code: 'JPY', name: 'Japanese Yen', symbol: '\u00a5'),
      ]);
    });
  }

  final existingCategories = await db.select(db.categoriesTable).get();
  if (existingCategories.isEmpty) {
    await db.batch((batch) {
      final cats = [
        ('Food & Drinks', 'expense'),
        ('Transport', 'expense'),
        ('Shopping', 'expense'),
        ('Bills & Utilities', 'expense'),
        ('Entertainment', 'expense'),
        ('Health', 'expense'),
        ('Education', 'expense'),
        ('Salary', 'income'),
        ('Freelance', 'income'),
        ('Investment', 'income'),
        ('Other Income', 'income'),
      ];
      for (final (name, type) in cats) {
        batch.insert(db.categoriesTable, CategoriesTableCompanion(
          id: Value(uuid.v4()),
          name: Value(name),
          type: Value(type),
          createdAt: Value(now),
          updatedAt: Value(now),
        ));
      }
    });
  }
}

class MoneyManagerApp extends ConsumerWidget {
  const MoneyManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Money Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
