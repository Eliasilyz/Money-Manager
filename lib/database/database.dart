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
import 'package:money_manager/database/daos/notes_dao.dart';
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
import 'package:money_manager/database/tables/notes_table.dart';
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
    NotesTable,
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
    NotesDao,
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
          if (from < 2) {
            await m.createTable(notesTable);
            await m.addColumn(accountsTable, accountsTable.systemKey);
            await m.addColumn(categoriesTable, categoriesTable.systemKey);
            await m.addColumn(goalsTable, goalsTable.isPriority);
            await m.addColumn(debtsTable, debtsTable.totalInstallments);
            await m.addColumn(debtsTable, debtsTable.paidInstallments);
            await m.addColumn(debtsTable, debtsTable.billingDay);
          }
          if (from < 3) {
            await m.addColumn(accountsTable, accountsTable.sortOrder);
          }
          if (from < 4) {
            await m.drop(recurringTransactionsTable);
            await m.createTable(recurringTransactionsTable);
          }
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
