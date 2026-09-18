import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:money_manager/core/constants/app_constants.dart';
import 'package:money_manager/database/daos/accounts_dao.dart';
import 'package:money_manager/database/daos/budgets_dao.dart';
import 'package:money_manager/database/daos/categories_dao.dart';
import 'package:money_manager/database/daos/currencies_dao.dart';
import 'package:money_manager/database/daos/debts_dao.dart';
import 'package:money_manager/database/daos/goals_dao.dart';
import 'package:money_manager/database/daos/recurring_dao.dart';
import 'package:money_manager/database/daos/transactions_dao.dart';
import 'package:money_manager/database/tables/accounts_table.dart';
import 'package:money_manager/database/tables/budgets_table.dart';
import 'package:money_manager/database/tables/categories_table.dart';
import 'package:money_manager/database/tables/currencies_table.dart';
import 'package:money_manager/database/tables/debt_payments_table.dart';
import 'package:money_manager/database/tables/debts_table.dart';
import 'package:money_manager/database/tables/exchange_rates_table.dart';
import 'package:money_manager/database/tables/goals_table.dart';
import 'package:money_manager/database/tables/recurring_transactions_table.dart';
import 'package:money_manager/database/tables/transfers_table.dart';
import 'package:money_manager/database/tables/transactions_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    AccountsTable,
    CategoriesTable,
    TransactionsTable,
    TransfersTable,
    RecurringTransactionsTable,
    BudgetsTable,
    GoalsTable,
    DebtsTable,
    DebtPaymentsTable,
    CurrenciesTable,
    ExchangeRatesTable,
  ],
  daos: [
    AccountsDao,
    CategoriesDao,
    TransactionsDao,
    BudgetsDao,
    GoalsDao,
    DebtsDao,
    RecurringDao,
    CurrenciesDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => AppConstants.databaseSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // future migrations here
        },
      );

  Future<List<Account>> getAllAccounts() => select(accountsTable).get();
  Future<List<Transaction>> getAllTransactions() => select(transactionsTable).get();
  Future<List<Transfer>> getAllTransfers() => select(transfersTable).get();
  Future<List<Currency>> getAllCurrencies() => select(currenciesTable).get();
  Future<List<Category>> getAllCategories() => select(categoriesTable).get();
}

QueryExecutor _openConnection() {
  return driftDatabase(name: AppConstants.databaseFileName);
}
