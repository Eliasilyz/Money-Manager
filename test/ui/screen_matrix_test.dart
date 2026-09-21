import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:money_manager/domain/entities/account.dart';
import 'package:money_manager/domain/entities/budget.dart';
import 'package:money_manager/domain/entities/category.dart';
import 'package:money_manager/domain/entities/currency.dart';
import 'package:money_manager/domain/entities/debt.dart';
import 'package:money_manager/domain/entities/goal.dart';
import 'package:money_manager/domain/entities/note.dart';
import 'package:money_manager/domain/entities/recurring_transaction.dart';
import 'package:money_manager/domain/entities/transaction.dart';
import 'package:money_manager/domain/entities/transfer.dart';
import 'package:money_manager/domain/repositories/account_repository.dart';
import 'package:money_manager/domain/repositories/budget_repository.dart';
import 'package:money_manager/domain/repositories/category_repository.dart';
import 'package:money_manager/domain/repositories/currency_repository.dart';
import 'package:money_manager/domain/repositories/debt_repository.dart';
import 'package:money_manager/domain/repositories/goal_repository.dart';
import 'package:money_manager/domain/repositories/note_repository.dart';
import 'package:money_manager/domain/repositories/recurring_repository.dart';
import 'package:money_manager/domain/repositories/transaction_repository.dart';
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/budgets/application/budget_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/currencies/application/currency_provider.dart';
import 'package:money_manager/features/debts/application/debt_provider.dart';
import 'package:money_manager/features/goals/application/goal_provider.dart';
import 'package:money_manager/features/notes/application/note_provider.dart';
import 'package:money_manager/features/recurring/application/recurring_provider.dart';
import 'package:money_manager/features/settings/application/notification_service.dart';
import 'package:money_manager/features/settings/application/settings_provider.dart';
import 'package:money_manager/features/transactions/application/transaction_provider.dart';

import 'package:money_manager/features/accounts/presentation/accounts_screen.dart';
import 'package:money_manager/features/budgets/presentation/budgets_screen.dart';
import 'package:money_manager/features/calendar/presentation/calendar_screen.dart';
import 'package:money_manager/features/categories/presentation/categories_screen.dart';
import 'package:money_manager/features/dashboard/presentation/dashboard_screen.dart';
import 'package:money_manager/features/goals/presentation/goals_screen.dart';
import 'package:money_manager/features/notes/presentation/notes_screen.dart';
import 'package:money_manager/features/recurring/presentation/recurring_screen.dart';
import 'package:money_manager/features/settings/presentation/backup_screen.dart';
import 'package:money_manager/features/settings/presentation/settings_screen.dart';
import 'package:money_manager/features/statistics/presentation/statistics_screen.dart';
import 'package:money_manager/features/transactions/presentation/transactions_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager/theme/app_colors.dart';
import 'package:money_manager/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Empty-data mock implementations
// ---------------------------------------------------------------------------

class _EmptyAccountRepo implements IAccountRepository {
  @override Future<List<Account>> getAllAccounts() async => [];
  @override Future<List<Account>> getActiveAccounts() async => [];
  @override Future<Account?> getAccountById(String id) async => null;
  @override Stream<List<Account>> watchAllAccounts() => Stream.value([]);
  @override Stream<List<Account>> watchActiveAccounts() => Stream.value([]);
  @override Future<void> insertAccount(Account a) async {}
  @override Future<void> updateAccount(Account a) async {}
  @override Future<void> deleteAccount(String id) async {}
  @override Future<void> archiveAccount(String id, bool archived) async {}
}

class _EmptyCategoryRepo implements ICategoryRepository {
  @override Future<List<Category>> getAllCategories() async => [];
  @override Stream<List<Category>> watchAllCategories() => Stream.value([]);
  @override Stream<List<Category>> watchCategoriesByType(String type) => Stream.value([]);
  @override Future<void> insertCategory(Category c) async {}
  @override Future<void> updateCategory(Category c) async {}
  @override Future<void> deleteCategory(String id) async {}
  @override Future<Category?> getCategoryById(String id) async => null;
}

class _EmptyTransactionRepo implements ITransactionRepository {
  @override Future<List<Transaction>> getAllTransactions() async => [];
  @override Stream<List<Transaction>> watchAllTransactions() => Stream.value([]);
  @override Stream<List<Transaction>> watchTransactionsByAccount(String accountId) => Stream.value([]);
  @override Stream<List<Transaction>> watchTransactionsByType(String type) => Stream.value([]);
  @override Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end) async => [];
  @override Future<void> insertTransaction(Transaction t) async {}
  @override Future<void> deleteTransaction(String id) async {}
  @override Future<List<Transfer>> getAllTransfers() async => [];
  @override Stream<List<Transfer>> watchTransfersByAccount(String accountId) => Stream.value([]);
  @override Future<void> insertTransfer(Transfer t) async {}
}

class _EmptyBudgetRepo implements IBudgetRepository {
  @override Future<List<Budget>> getAllBudgets() async => [];
  @override Stream<List<Budget>> watchAllBudgets() => Stream.value([]);
  @override Stream<List<Budget>> watchBudgetsByCategory(String categoryId) => Stream.value([]);
  @override Future<void> insertBudget(Budget b) async {}
  @override Future<void> updateBudget(Budget b) async {}
  @override Future<void> deleteBudget(String id) async {}
}

class _EmptyGoalRepo implements IGoalRepository {
  @override Future<List<Goal>> getAllGoals() async => [];
  @override Stream<List<Goal>> watchAllGoals() => Stream.value([]);
  @override Future<void> insertGoal(Goal g) async {}
  @override Future<void> updateGoal(Goal g) async {}
  @override Future<void> deleteGoal(String id) async {}
}

class _EmptyRecurringRepo implements IRecurringRepository {
  @override Future<List<RecurringTransaction>> getAllRecurring() async => [];
  @override Stream<List<RecurringTransaction>> watchAllRecurring() => Stream.value([]);
  @override Stream<List<RecurringTransaction>> watchDueRecurring(DateTime now) => Stream.value([]);
  @override Future<void> insertRecurring(RecurringTransaction r) async {}
  @override Future<void> updateRecurring(RecurringTransaction r) async {}
  @override Future<void> deleteRecurring(String id) async {}
}

class _EmptyNoteRepo implements INoteRepository {
  @override Future<List<Note>> getAllNotes() async => [];
  @override Stream<List<Note>> watchAllNotes() => Stream.value([]);
  @override Future<void> insertNote(Note n) async {}
  @override Future<void> updateNote(Note n) async {}
  @override Future<void> deleteNote(String id) async {}
}

class _EmptyCurrencyRepo implements ICurrencyRepository {
  @override Future<List<Currency>> getAllCurrencies() async => [];
  @override Future<Currency?> getCurrencyByCode(String code) async => null;
  @override Stream<List<Currency>> watchAllCurrencies() => Stream.value([]);
  @override Future<void> insertCurrency(Currency c) async {}
}

class _EmptyDebtRepo implements IDebtRepository {
  @override Future<List<Debt>> getAllDebts() async => [];
  @override Stream<List<Debt>> watchAllDebts() => Stream.value([]);
  @override Future<List<Debt>> getOverdueDebts(DateTime now) async => [];
  @override Future<Debt?> getDebtById(String id) async => null;
  @override Future<void> insertDebt(Debt d) async {}
  @override Future<void> updateDebt(Debt d) async {}
  @override Future<void> deleteDebt(String id) async {}
  @override Future<List<DebtPayment>> getPaymentsForDebt(String debtId) async => [];
  @override Stream<List<DebtPayment>> watchPaymentsForDebt(String debtId) => Stream.value([]);
  @override Future<void> insertDebtPayment(DebtPayment payment) async {}
  @override Future<int> getTotalPaidForDebt(String debtId) async => 0;
}

// ---------------------------------------------------------------------------
// Stub services (avoid SharedPreferences / local_auth / flutter_local_notifications)
// ---------------------------------------------------------------------------

class _StubSettingsService extends SettingsService {
  @override Future<ThemeMode> getThemeMode() async => ThemeMode.light;
  @override Future<void> saveThemeMode(ThemeMode mode) async {}
  @override Future<Locale> getLocale() async => const Locale('id');
  @override Future<void> saveLocale(Locale locale) async {}
  @override Future<String?> getPinHash() async => null;
  @override Future<String?> getPinSalt() async => null;
  @override Future<void> savePin(String hash, String salt) async {}
  @override Future<void> clearPin() async {}
  @override Future<bool> getBiometricEnabled() async => false;
  @override Future<void> saveBiometricEnabled(bool v) async {}
  @override Future<bool> getNotificationsEnabled() async => false;
  @override Future<void> saveNotificationsEnabled(bool v) async {}
  @override Future<bool> getAutoBackup() async => false;
  @override Future<void> saveAutoBackup(bool v) async {}
  @override Future<bool> getWifiOnly() async => true;
  @override Future<void> saveWifiOnly(bool v) async {}
  @override Future<bool> getEncryptBackup() async => false;
  @override Future<void> saveEncryptBackup(bool v) async {}
}

class _StubNotificationService extends NotificationService {
  @override Future<void> init() async {}
  @override Future<void> scheduleDaily({String time = '19:00'}) async {}
  @override Future<void> cancelAll() async {}
}

// ---------------------------------------------------------------------------
// Test constants
// ---------------------------------------------------------------------------

const _sizes = <Size>[
  Size(320, 568),
  Size(360, 640),
  Size(390, 844),
  Size(430, 932),
  Size(768, 1024),
];

const _textScales = <double>[1.0, 1.3, 2.0];

const _locales = <Locale>[
  Locale('id'),
  Locale('en'),
];

final _themes = <String, ThemeData>{
  'light': AppThemeData.light,
  'dark': AppThemeData.dark,
};

class AppThemeData {
  AppThemeData._();
  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    extensions: const <ThemeExtension<dynamic>>[AppColorsT.light],
    colorScheme: const ColorScheme.light(
      surface: Color(0xFFFFFFFF),
      primary: Color(0xFF1B6E4B),
      error: Color(0xFFE0524A),
      onSurface: Color(0xFF1A1F1C),
    ),
    scaffoldBackgroundColor: const Color(0xFFF4F6F5),
  );
  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    extensions: const <ThemeExtension<dynamic>>[AppColorsT.dark],
    colorScheme: const ColorScheme.dark(
      surface: Color(0xFF161E19),
      primary: Color(0xFF34A873),
      error: Color(0xFFF0716A),
      onSurface: Color(0xFFE7EEE9),
    ),
    scaffoldBackgroundColor: const Color(0xFF0E1411),
  );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<Override> _emptyOverrides() => [
      accountRepositoryProvider.overrideWithValue(_EmptyAccountRepo()),
      categoryRepositoryProvider.overrideWithValue(_EmptyCategoryRepo()),
      transactionRepositoryProvider.overrideWithValue(_EmptyTransactionRepo()),
      budgetRepositoryProvider.overrideWithValue(_EmptyBudgetRepo()),
      goalRepositoryProvider.overrideWithValue(_EmptyGoalRepo()),
      recurringRepositoryProvider.overrideWithValue(_EmptyRecurringRepo()),
      noteRepositoryProvider.overrideWithValue(_EmptyNoteRepo()),
      currencyRepositoryProvider.overrideWithValue(_EmptyCurrencyRepo()),
      debtRepositoryProvider.overrideWithValue(_EmptyDebtRepo()),
      settingsServiceProvider.overrideWithValue(_StubSettingsService()),
      notificationServiceProvider.overrideWithValue(_StubNotificationService()),
    ];

/// Wraps [child] in ProviderScope + MaterialApp with proper theme/locale/scale.
Widget _wrap(
  Widget child, {
  required ThemeData theme,
  required Locale locale,
  required double textScale,
}) {
  return ProviderScope(
    overrides: [
      ..._emptyOverrides(),
      themeModeProvider.overrideWith((ref) => ThemeMode.light),
      localeProvider.overrideWith((ref) => locale),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      locale: locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id'), Locale('en')],
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: child,
      ),
    ),
  );
}

/// Pumps a screen and asserts no FlutterErrors (especially overflow) occur.
Future<void> _pumpAndVerify({
  required WidgetTester tester,
  required Widget Function(BuildContext) builder,
  required Size size,
  required ThemeData theme,
  required String themeName,
  required Locale locale,
  required double textScale,
  required String screenName,
}) async {
  FlutterErrorDetails? capturedError;

  final originalHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    final msg = details.toString();
    if (msg.toLowerCase().contains('overflowed')) {
      capturedError = details;
    }
  };

  try {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(_wrap(
      Builder(builder: builder),
      theme: theme,
      locale: locale,
      textScale: textScale,
    ));

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    if (capturedError != null) {
      fail(
        '$screenName ${size.width.toInt()}x${size.height.toInt()} '
        'scale=$textScale locale=${locale.languageCode} theme=$themeName: '
        'OVERFLOW: ${capturedError!}',
      );
    }
  } catch (e) {
    if (e is TestFailure) rethrow;
    fail('$screenName pump failed: $e');
  } finally {
    FlutterError.onError = originalHandler;
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }
}

// ---------------------------------------------------------------------------
// Screen matrix
// ---------------------------------------------------------------------------

final _screens = <String, Widget Function(BuildContext)>{
  'DashboardScreen': (_) => const DashboardScreen(),
  'TransactionsScreen': (_) => const TransactionsScreen(),
  'AccountsScreen': (_) => const AccountsScreen(),
  'SettingsScreen': (_) => const SettingsScreen(),
  'StatisticsScreen': (_) => const StatisticsScreen(),
  'BudgetsScreen': (_) => const BudgetsScreen(),
  'GoalsScreen': (_) => const GoalsScreen(),
  'RecurringScreen': (_) => const RecurringScreen(),
  'CategoriesScreen': (_) => const CategoriesScreen(),
  'NotesScreen': (_) => const NotesScreen(),
  'BackupScreen': (_) => const BackupScreen(),
  'CalendarScreen': (_) => const CalendarScreen(),
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
    await initializeDateFormatting('en_US', null);
  });

  for (final entry in _screens.entries) {
    final screenName = entry.key;
    final screenBuilder = entry.value;

    group(screenName, () {
      for (final size in _sizes) {
        for (final textScale in _textScales) {
          for (final locale in _locales) {
            for (final themeEntry in _themes.entries) {
              final themeName = themeEntry.key;
              final theme = themeEntry.value;

              final label =
                  '${size.width.toInt()}x${size.height.toInt()} '
                  'scale=$textScale '
                  'locale=${locale.languageCode} '
                  'theme=$themeName';

              testWidgets(label, (tester) async {
                await _pumpAndVerify(
                  tester: tester,
                  builder: screenBuilder,
                  size: size,
                  theme: theme,
                  themeName: themeName,
                  locale: locale,
                  textScale: textScale,
                  screenName: screenName,
                );
              });
            }
          }
        }
      }
    });
  }
}
