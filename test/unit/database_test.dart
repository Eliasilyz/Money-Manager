import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/database/database.dart';

void main() {
  group('AppDatabase', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.memory();
    });

    tearDown(() => db.close());

    test('schema version is set', () {
      expect(db.schemaVersion, 2);
    });

    test('can insert and retrieve account', () async {
      await db.into(db.accountsTable).insert(
            const AccountsTableCompanion(
              id: Value('test-uuid-1'),
              name: Value('Test Account'),
              accountType: Value('bank'),
              currencyCode: Value('IDR'),
              initialBalance: Value(5000000),
            ),
          );

      final accounts = await db.getAllAccounts();
      expect(accounts, isNotEmpty);
      expect(accounts.first.name, 'Test Account');
    });

    test('can insert and retrieve currency', () async {
      await db.into(db.currenciesTable).insert(
            const CurrenciesTableCompanion(
              code: Value('USD'),
              name: Value('US Dollar'),
              symbol: Value('\$'),
              decimalDigits: Value(2),
            ),
          );

      final currencies = await db.getAllCurrencies();
      expect(currencies, isNotEmpty);
      expect(currencies.first.code, 'USD');
    });

    test('can insert and retrieve category', () async {
      await db.into(db.categoriesTable).insert(
            const CategoriesTableCompanion(
              id: Value('cat-1'),
              name: Value('Food'),
              type: Value('expense'),
            ),
          );

      final categories = await db.getAllCategories();
      expect(categories, isNotEmpty);
    });

    test('can insert and retrieve transaction', () async {
      await db.into(db.currenciesTable).insert(
            const CurrenciesTableCompanion(
              code: Value('IDR'),
              name: Value('Indonesian Rupiah'),
              symbol: Value('Rp'),
            ),
          );
      await db.into(db.accountsTable).insert(
            const AccountsTableCompanion(
              id: Value('acc-1'),
              name: Value('Test Bank'),
              accountType: Value('bank'),
              currencyCode: Value('IDR'),
            ),
          );
      await db.into(db.categoriesTable).insert(
            const CategoriesTableCompanion(
              id: Value('cat-1'),
              name: Value('Food'),
              type: Value('expense'),
            ),
          );

      await db.into(db.transactionsTable).insert(
            TransactionsTableCompanion(
              id: const Value('tx-1'),
              type: const Value('expense'),
              accountId: const Value('acc-1'),
              categoryId: const Value('cat-1'),
              amount: const Value(35000),
              currencyCode: const Value('IDR'),
              date: Value(DateTime.now()),
            ),
          );

      final transactions = await db.getAllTransactions();
      expect(transactions, isNotEmpty);
    });

    test('can insert transfer with exchange rate', () async {
      await db.into(db.currenciesTable).insert(
            const CurrenciesTableCompanion(
              code: Value('IDR'),
              name: Value('Indonesian Rupiah'),
              symbol: Value('Rp'),
            ),
          );
      await db.into(db.currenciesTable).insert(
            const CurrenciesTableCompanion(
              code: Value('USD'),
              name: Value('US Dollar'),
              symbol: Value('\$'),
              decimalDigits: Value(2),
            ),
          );
      await db.into(db.accountsTable).insert(
            const AccountsTableCompanion(
              id: Value('acc-usd'),
              name: Value('USD Wallet'),
              accountType: Value('wallet'),
              currencyCode: Value('USD'),
            ),
          );
      await db.into(db.accountsTable).insert(
            const AccountsTableCompanion(
              id: Value('acc-idr'),
              name: Value('Bank IDR'),
              accountType: Value('bank'),
              currencyCode: Value('IDR'),
            ),
          );

      await db.into(db.transfersTable).insert(
            TransfersTableCompanion(
              id: const Value('tr-1'),
              fromAccountId: const Value('acc-usd'),
              toAccountId: const Value('acc-idr'),
              sourceAmount: const Value(10000),
              destinationAmount: const Value(150000000),
              currencyCode: const Value('USD'),
              exchangeRate: const Value(15000.0),
              date: Value(DateTime.now()),
            ),
          );

      final transfers = await db.getAllTransfers();
      expect(transfers, isNotEmpty);
      expect(transfers.first.sourceAmount, 10000);
    });
  });

  group('Migration', () {
    test('migration does not delete data', () async {
      final db = AppDatabase.memory();
      await db.into(db.accountsTable).insert(
            const AccountsTableCompanion(
              id: Value('acc-1'),
              name: Value('Test'),
              accountType: Value('bank'),
              currencyCode: Value('IDR'),
            ),
          );

      final accountsBefore = await db.getAllAccounts();
      expect(accountsBefore.length, 1);
    });
  });
}
