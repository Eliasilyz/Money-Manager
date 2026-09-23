import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/database/database.dart';
import 'package:money_manager/data/repositories/drift_account_repository.dart';
import 'package:money_manager/domain/services/account_service.dart';

void main() {
  group('AccountService Tests', () {
    late AppDatabase db;
    late DriftAccountRepository accRepo;
    late AccountService accService;

    setUp(() async {
      db = AppDatabase.memory();
      accRepo = DriftAccountRepository(db);
      accService = AccountService(accRepo);

      // Seed currency
      await db.into(db.currenciesTable).insert(
            const CurrenciesTableCompanion(
              code: Value('IDR'),
              name: Value('Rupiah'),
              symbol: Value('Rp'),
            ),
          );
      await db.into(db.currenciesTable).insert(
            const CurrenciesTableCompanion(
              code: Value('USD'),
              name: Value('US Dollar'),
              symbol: Value(r'$'),
            ),
          );
    });

    tearDown(() => db.close());

    test('createAccount inserts account with UUID and balance properly', () async {
      await accService.createAccount(
        name: 'BCA Utama',
        accountType: 'savings',
        currencyCode: 'IDR',
        initialBalance: 5000000,
        note: 'Gaji bulanan',
      );

      final accounts = await accRepo.getAllAccounts();
      expect(accounts.length, 1);
      final acc = accounts.first;
      expect(acc.name, 'BCA Utama');
      expect(acc.accountType, 'savings');
      expect(acc.currencyCode, 'IDR');
      expect(acc.initialBalance, 5000000);
      expect(acc.note, 'Gaji bulanan');
      expect(acc.id, isNotEmpty);
      expect(acc.id.length, 36); // Valid UUID length
    });

    test('createAccount persists non-IDR currencyCode', () async {
      await accService.createAccount(
        name: 'Pocket USD',
        accountType: 'savings',
        currencyCode: 'USD',
        initialBalance: 500,
        note: null,
      );

      final accounts = await accRepo.getAllAccounts();
      expect(accounts.length, 1);
      expect(accounts.first.currencyCode, 'USD');
      expect(accounts.first.initialBalance, 500);
    });
  });
}
