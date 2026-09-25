import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:money_manager/app.dart';
import 'package:money_manager/database/database.dart';
import 'package:money_manager/data/repositories/drift_account_repository.dart';
import 'package:money_manager/data/repositories/drift_budget_repository.dart';
import 'package:money_manager/data/repositories/drift_category_repository.dart';
import 'package:money_manager/data/repositories/drift_currency_repository.dart';
import 'package:money_manager/data/repositories/drift_debt_repository.dart';
import 'package:money_manager/data/repositories/drift_goal_repository.dart';
import 'package:money_manager/data/repositories/drift_note_repository.dart';
import 'package:money_manager/data/repositories/drift_recurring_repository.dart';
import 'package:money_manager/data/repositories/drift_transaction_repository.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/budgets/application/budget_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/currencies/application/currency_provider.dart';
import 'package:money_manager/features/debts/application/debt_provider.dart';
import 'package:money_manager/features/goals/application/goal_provider.dart';
import 'package:money_manager/features/notes/application/note_provider.dart';
import 'package:money_manager/features/recurring/application/recurring_provider.dart';
import 'package:money_manager/features/security/application/security_provider.dart';
import 'package:money_manager/features/security/presentation/lock_screen.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';
import 'package:money_manager/routing/router.dart';
import 'package:money_manager/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  initializeDateFormatting('en_US', null);
  final db = AppDatabase();

  final accountRepo = DriftAccountRepository(db);
  final categoryRepo = DriftCategoryRepository(db);
  final transactionRepo = DriftTransactionRepository(db);
  final budgetRepo = DriftBudgetRepository(db);
  final goalRepo = DriftGoalRepository(db);
  final noteRepo = DriftNoteRepository(db);
  final debtRepo = DriftDebtRepository(db);
  final recurringRepo = DriftRecurringRepository(db);
  final currencyRepo = DriftCurrencyRepository(db);

  await _migrateSchema(db);
  await _seedDefaults(db);

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        accountRepositoryProvider.overrideWithValue(accountRepo),
        categoryRepositoryProvider.overrideWithValue(categoryRepo),
        transactionRepositoryProvider.overrideWithValue(transactionRepo),
        budgetRepositoryProvider.overrideWithValue(budgetRepo),
        goalRepositoryProvider.overrideWithValue(goalRepo),
        noteRepositoryProvider.overrideWithValue(noteRepo),
        debtRepositoryProvider.overrideWithValue(debtRepo),
        recurringRepositoryProvider.overrideWithValue(recurringRepo),
        currencyRepositoryProvider.overrideWithValue(currencyRepo),
        settingsServiceProvider.overrideWithValue(SettingsService()),
      ],
      child: const MoneyManagerApp(),
    ),
  );
}

Future<void> _migrateSchema(AppDatabase db) async {}

Future<void> _seedDefaults(AppDatabase db) async {
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
    final now = DateTime.now();
    await db.batch((batch) {
      batch.insertAll(db.categoriesTable, [
        // Expense
        CategoriesTableCompanion.insert(id: 'exp_food_drink', name: 'Makan & Minum', type: const Value('expense'), systemKey: const Value('food_drink'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'exp_transport', name: 'Transportasi', type: const Value('expense'), systemKey: const Value('transport'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'exp_shopping', name: 'Belanja', type: const Value('expense'), systemKey: const Value('shopping'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'exp_housing', name: 'Rumah & Sewa', type: const Value('expense'), systemKey: const Value('housing'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'exp_utilities', name: 'Tagihan & Utilitas', type: const Value('expense'), systemKey: const Value('utilities'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'exp_health', name: 'Kesehatan', type: const Value('expense'), systemKey: const Value('health'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'exp_education', name: 'Pendidikan', type: const Value('expense'), systemKey: const Value('education'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'exp_entertainment', name: 'Hiburan', type: const Value('expense'), systemKey: const Value('entertainment'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'exp_vacation', name: 'Liburan', type: const Value('expense'), systemKey: const Value('vacation'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'exp_family', name: 'Keluarga & Anak', type: const Value('expense'), systemKey: const Value('family'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'exp_personal_care', name: 'Perawatan Diri', type: const Value('expense'), systemKey: const Value('personal_care'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'exp_gifts', name: 'Hadiah & Donasi', type: const Value('expense'), systemKey: const Value('gifts'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'exp_debt_payment', name: 'Cicilan & Hutang', type: const Value('expense'), systemKey: const Value('debt_payment'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'exp_insurance', name: 'Asuransi', type: const Value('expense'), systemKey: const Value('insurance'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'exp_subscriptions', name: 'Langganan', type: const Value('expense'), systemKey: const Value('subscriptions'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'exp_other', name: 'Lainnya', type: const Value('expense'), systemKey: const Value('other_expense'), createdAt: Value(now), updatedAt: Value(now)),
        // Income
        CategoriesTableCompanion.insert(id: 'inc_salary', name: 'Gaji', type: const Value('income'), systemKey: const Value('salary'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'inc_bonus', name: 'Bonus', type: const Value('income'), systemKey: const Value('bonus'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'inc_business', name: 'Usaha', type: const Value('income'), systemKey: const Value('business'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'inc_investment', name: 'Investasi', type: const Value('income'), systemKey: const Value('investment'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'inc_gift', name: 'Hadiah', type: const Value('income'), systemKey: const Value('gift'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'inc_sale', name: 'Penjualan', type: const Value('income'), systemKey: const Value('sale'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'inc_refund', name: 'Pengembalian Dana', type: const Value('income'), systemKey: const Value('refund'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'inc_other', name: 'Lainnya', type: const Value('income'), systemKey: const Value('other_income'), createdAt: Value(now), updatedAt: Value(now)),
        // System (hidden)
        CategoriesTableCompanion.insert(id: 'sys_balance_adj', name: 'Penyesuaian saldo', type: const Value('system'), systemKey: const Value('balance_adjustment'), createdAt: Value(now), updatedAt: Value(now)),
        CategoriesTableCompanion.insert(id: 'sys_transfer', name: 'Transfer', type: const Value('system'), systemKey: const Value('transfer'), createdAt: Value(now), updatedAt: Value(now)),
      ]);
    });
  }

}

class MoneyManagerApp extends ConsumerWidget {
  const MoneyManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsInitProvider);
    ref.watch(securityInitProvider);
    final themeMode = ref.watch(themeModeProvider);
    final themePreset = ref.watch(themePresetProvider);
    final locale = ref.watch(localeProvider);
    final locked = ref.watch(appLockedProvider);

    return MaterialApp.router(
      title: 'Money Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(preset: themePreset),
      darkTheme: AppTheme.dark(preset: themePreset),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const <Locale>[Locale('id'), Locale('en')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => Stack(
        children: [
          if (child != null) child,
          if (locked) const LockScreen(),
        ],
      ),
    );
  }
}
