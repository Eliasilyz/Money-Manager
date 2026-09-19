import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/data/repositories/drift_account_repository.dart';
import 'package:money_manager/data/repositories/drift_budget_repository.dart';
import 'package:money_manager/data/repositories/drift_category_repository.dart';
import 'package:money_manager/data/repositories/drift_currency_repository.dart';
import 'package:money_manager/data/repositories/drift_debt_repository.dart';
import 'package:money_manager/data/repositories/drift_goal_repository.dart';
import 'package:money_manager/data/repositories/drift_recurring_repository.dart';
import 'package:money_manager/data/repositories/drift_transaction_repository.dart';
import 'package:money_manager/database/database.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/budgets/application/budget_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/currencies/application/currency_provider.dart';
import 'package:money_manager/features/debts/application/debt_provider.dart';
import 'package:money_manager/features/goals/application/goal_provider.dart';
import 'package:money_manager/features/recurring/application/recurring_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/main.dart';

void main() {
  testWidgets('MoneyManager app loads with in-memory DB', (WidgetTester tester) async {
    final db = AppDatabase.memory();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountRepositoryProvider.overrideWithValue(DriftAccountRepository(db)),
          categoryRepositoryProvider.overrideWithValue(DriftCategoryRepository(db)),
          transactionRepositoryProvider.overrideWithValue(DriftTransactionRepository(db)),
          budgetRepositoryProvider.overrideWithValue(DriftBudgetRepository(db)),
          goalRepositoryProvider.overrideWithValue(DriftGoalRepository(db)),
          debtRepositoryProvider.overrideWithValue(DriftDebtRepository(db)),
          recurringRepositoryProvider.overrideWithValue(DriftRecurringRepository(db)),
          currencyRepositoryProvider.overrideWithValue(DriftCurrencyRepository(db)),
        ],
        child: const MoneyManagerApp(),
      ),
    );

    // Initial pump without extra timers
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);

    await db.close();
  });
}
