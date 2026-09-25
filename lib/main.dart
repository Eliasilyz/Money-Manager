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

  final existingAccounts = await db.select(db.accountsTable).get();
  if (existingAccounts.isEmpty) {
    final now = DateTime.now();
    await db.batch((batch) {
      batch.insertAll(db.accountsTable, [
        AccountsTableCompanion.insert(
          id: 'acc_bca',
          name: 'BCA Utama',
          accountType: 'savings',
          currencyCode: const Value('IDR'),
          initialBalance: const Value(9850000),
          note: const Value('•••• 2841'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        AccountsTableCompanion.insert(
          id: 'acc_jago',
          name: 'Jago Tabungan',
          accountType: 'savings',
          currencyCode: const Value('IDR'),
          initialBalance: const Value(6775000),
          note: const Value('•••• 9120 • bunga 4,5%'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        AccountsTableCompanion.insert(
          id: 'acc_gopay',
          name: 'GoPay',
          accountType: 'wallet',
          currencyCode: const Value('IDR'),
          initialBalance: const Value(1425000),
          note: const Value('•••• 2841 • promo aktif'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        AccountsTableCompanion.insert(
          id: 'acc_bca_plat',
          name: 'BCA Platinum',
          accountType: 'credit',
          currencyCode: const Value('IDR'),
          initialBalance: const Value(-1200000),
          note: const Value('•••• 1182 • tagihan 28 Sep'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        AccountsTableCompanion.insert(
          id: 'acc_reksa',
          name: 'Reksa Dana',
          accountType: 'investment',
          currencyCode: const Value('IDR'),
          initialBalance: const Value(1100000),
          note: const Value('•••• 7712 • imbal hasil 7,2%'),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      ]);
    });

    final today = DateTime(now.year, now.month, now.day);
    await db.batch((batch) {
      batch.insertAll(db.transactionsTable, [
        TransactionsTableCompanion.insert(
          id: 'tx_supermarket',
          type: 'expense',
          accountId: 'acc_bca',
          categoryId: const Value('exp_shopping'),
          amount: 286500,
          currencyCode: 'IDR',
          description: const Value('Supermarket Fresh'),
          date: today.add(const Duration(hours: 18, minutes: 20)),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        TransactionsTableCompanion.insert(
          id: 'tx_kopi',
          type: 'expense',
          accountId: 'acc_gopay',
          categoryId: const Value('exp_food_drink'),
          amount: 68000,
          currencyCode: 'IDR',
          description: const Value('Kopi bersama tim'),
          date: today.add(const Duration(hours: 15, minutes: 42)),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        TransactionsTableCompanion.insert(
          id: 'tx_bensin',
          type: 'expense',
          accountId: 'acc_bca',
          categoryId: const Value('exp_transport'),
          amount: 180000,
          currencyCode: 'IDR',
          description: const Value('Isi bensin'),
          date: today.add(const Duration(hours: 8, minutes: 10)),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        TransactionsTableCompanion.insert(
          id: 'tx_bakso',
          type: 'expense',
          accountId: 'acc_gopay',
          categoryId: const Value('exp_food_drink'),
          amount: 10000,
          currencyCode: 'IDR',
          description: const Value('Bakso'),
          date: today.add(const Duration(hours: 18)),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        TransactionsTableCompanion.insert(
          id: 'tx_proyek',
          type: 'income',
          accountId: 'acc_bca',
          categoryId: const Value('inc_business'),
          amount: 1750000,
          currencyCode: 'IDR',
          description: const Value('Proyek desain'),
          note: const Value('DP tahap 2'),
          date: today.subtract(const Duration(days: 1)).add(const Duration(hours: 14)),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        TransactionsTableCompanion.insert(
          id: 'tx_gaji',
          type: 'income',
          accountId: 'acc_bca',
          categoryId: const Value('inc_salary'),
          amount: 12500000,
          currencyCode: 'IDR',
          description: const Value('Gaji bulanan'),
          date: today.subtract(const Duration(days: 2)).add(const Duration(hours: 9)),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      ]);
    });

    await db.batch((batch) {
      batch.insertAll(db.budgetsTable, [
        BudgetsTableCompanion.insert(
          id: 'bgt_food',
          categoryId: 'exp_food_drink',
          amount: 2500000,
          currencyCode: 'IDR',
          startDate: DateTime(now.year, now.month, 1),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        BudgetsTableCompanion.insert(
          id: 'bgt_transport',
          categoryId: 'exp_transport',
          amount: 1200000,
          currencyCode: 'IDR',
          startDate: DateTime(now.year, now.month, 1),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        BudgetsTableCompanion.insert(
          id: 'bgt_shopping',
          categoryId: 'exp_shopping',
          amount: 1500000,
          currencyCode: 'IDR',
          startDate: DateTime(now.year, now.month, 1),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        BudgetsTableCompanion.insert(
          id: 'bgt_housing',
          categoryId: 'exp_housing',
          amount: 1500000,
          currencyCode: 'IDR',
          startDate: DateTime(now.year, now.month, 1),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        BudgetsTableCompanion.insert(
          id: 'bgt_entertainment',
          categoryId: 'exp_entertainment',
          amount: 1300000,
          currencyCode: 'IDR',
          startDate: DateTime(now.year, now.month, 1),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      ]);
    });

    await db.batch((batch) {
      batch.insertAll(db.goalsTable, [
        GoalsTableCompanion.insert(
          id: 'goal_japan',
          name: 'Liburan ke Jepang',
          targetAmount: 25000000,
          currentAmount: const Value(18500000),
          currencyCode: 'IDR',
          isPriority: const Value(true),
          startDate: now,
          targetDate: Value(DateTime(2026, 12, 31)),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        GoalsTableCompanion.insert(
          id: 'goal_emergency',
          name: 'Dana darurat',
          targetAmount: 40000000,
          currentAmount: const Value(22000000),
          currencyCode: 'IDR',
          isPriority: const Value(false),
          startDate: now,
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        GoalsTableCompanion.insert(
          id: 'goal_laptop',
          name: 'Laptop baru',
          targetAmount: 9000000,
          currentAmount: const Value(7200000),
          currencyCode: 'IDR',
          isPriority: const Value(false),
          startDate: now,
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      ]);
    });

    await db.batch((batch) {
      batch.insertAll(db.debtsTable, [
        DebtsTableCompanion.insert(
          id: 'debt_motor',
          personName: 'Cicilan motor',
          type: 'borrowed',
          originalAmount: 30000000,
          remainingAmount: 22750000,
          currencyCode: 'IDR',
          totalInstallments: const Value(24),
          paidInstallments: const Value(7),
          billingDay: const Value(25),
          dueDate: now.add(const Duration(days: 30)),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      ]);
    });

    await db.batch((batch) {
      batch.insertAll(db.recurringTransactionsTable, [
        RecurringTransactionsTableCompanion.insert(
          id: 'rec_sewa',
          type: 'expense',
          accountId: 'acc_bca',
          categoryId: const Value('exp_housing'),
          amount: 2750000,
          currencyCode: 'IDR',
          description: const Value('Sewa apartemen'),
          frequency: 'monthly',
          startDate: now,
          nextOccurrence: now.add(const Duration(days: 12)),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        RecurringTransactionsTableCompanion.insert(
          id: 'rec_internet',
          type: 'expense',
          accountId: 'acc_bca',
          categoryId: const Value('exp_utilities'),
          amount: 425000,
          currencyCode: 'IDR',
          description: const Value('Internet rumah'),
          frequency: 'monthly',
          startDate: now,
          nextOccurrence: now.add(const Duration(days: 16)),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        RecurringTransactionsTableCompanion.insert(
          id: 'rec_seluler',
          type: 'expense',
          accountId: 'acc_bca',
          categoryId: const Value('exp_utilities'),
          amount: 160000,
          currencyCode: 'IDR',
          description: const Value('Paket seluler'),
          frequency: 'monthly',
          startDate: now,
          nextOccurrence: now.add(const Duration(days: 19)),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
        RecurringTransactionsTableCompanion.insert(
          id: 'rec_gaji',
          type: 'income',
          accountId: 'acc_bca',
          categoryId: const Value('inc_salary'),
          amount: 12500000,
          currencyCode: 'IDR',
          description: const Value('Gaji bulanan'),
          frequency: 'monthly',
          startDate: now,
          nextOccurrence: now.add(const Duration(days: 25)),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
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
