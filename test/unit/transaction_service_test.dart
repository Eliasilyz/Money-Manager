import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/database/database.dart' hide Category;
import 'package:money_manager/data/repositories/drift_category_repository.dart';
import 'package:money_manager/data/repositories/drift_transaction_repository.dart';
import 'package:money_manager/domain/entities/category.dart';
import 'package:money_manager/domain/services/transaction_service.dart';

void main() {
  group('TransactionService & CategoryRepository Tests', () {
    late AppDatabase db;
    late DriftTransactionRepository txRepo;
    late DriftCategoryRepository catRepo;
    late TransactionService txService;

    setUp(() async {
      db = AppDatabase.memory();
      txRepo = DriftTransactionRepository(db);
      catRepo = DriftCategoryRepository(db);
      txService = TransactionService(txRepo);

      // Seed currency & account & category
      await db.into(db.currenciesTable).insert(
            const CurrenciesTableCompanion(
              code: Value('IDR'),
              name: Value('Rupiah'),
              symbol: Value('Rp'),
            ),
          );

      await db.into(db.accountsTable).insert(
            const AccountsTableCompanion(
              id: Value('acc-1'),
              name: Value('BCA'),
              accountType: Value('wallet'),
              currencyCode: Value('IDR'),
              initialBalance: Value(1000000),
            ),
          );

      final now = DateTime.now();
      await catRepo.insertCategory(Category(
        id: 'cat-makan',
        name: 'Makanan',
        type: 'expense',
        createdAt: now,
        updatedAt: now,
      ));
    });

    tearDown(() => db.close());

    test('addExpense saves description, categoryId and amount properly', () async {
      await txService.addExpense(
        accountId: 'acc-1',
        categoryId: 'cat-makan',
        amount: 25000,
        currencyCode: 'IDR',
        description: 'Nasi Goreng Spesial',
        note: 'Pedas sedang',
        date: DateTime(2025, 3, 20, 12, 30),
      );

      final allTx = await txRepo.getAllTransactions();
      expect(allTx.length, 1);
      final tx = allTx.first;
      expect(tx.type, 'expense');
      expect(tx.amount, 25000);
      expect(tx.description, 'Nasi Goreng Spesial');
      expect(tx.note, 'Pedas sedang');
      expect(tx.categoryId, 'cat-makan');
    });

    test('addIncome saves description and amount properly', () async {
      await txService.addIncome(
        accountId: 'acc-1',
        amount: 500000,
        currencyCode: 'IDR',
        description: 'Bonus Proyek',
        date: DateTime(2025, 3, 20),
      );

      final allTx = await txRepo.getAllTransactions();
      expect(allTx.length, 1);
      final tx = allTx.first;
      expect(tx.type, 'income');
      expect(tx.amount, 500000);
      expect(tx.description, 'Bonus Proyek');
    });

    test('getCategoryById returns correct Category or null', () async {
      final found = await catRepo.getCategoryById('cat-makan');
      expect(found, isNotNull);
      expect(found!.name, 'Makanan');

      final notFound = await catRepo.getCategoryById('cat-unknown');
      expect(notFound, isNull);
    });
  });
}
