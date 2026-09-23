import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:money_manager/data/repositories/drift_account_repository.dart';
import 'package:money_manager/data/repositories/drift_category_repository.dart';
import 'package:money_manager/data/repositories/drift_recurring_repository.dart';
import 'package:money_manager/database/database.dart';
import 'package:money_manager/domain/entities/account.dart' as domain_account;
import 'package:money_manager/domain/entities/recurring_transaction.dart' as domain;
import 'package:money_manager/features/accounts/application/account_provider.dart';
import 'package:money_manager/features/categories/application/category_provider.dart';
import 'package:money_manager/features/recurring/application/recurring_provider.dart';
import 'package:money_manager/features/recurring/presentation/recurring_form_sheet.dart';
import 'package:money_manager/features/recurring/presentation/recurring_screen.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/theme/app_theme.dart';

void main() {
  test('nextOccurrenceFor skips to the next date after now', () {
    final start = DateTime(2026, 8, 31);
    final now = DateTime(2026, 9, 15);
    // monthly: Aug 31 -> Sep 30 (clamped), which is >= today
    expect(nextOccurrenceFor('monthly', 1, start, now), DateTime(2026, 9, 30));
    // daily
    expect(nextOccurrenceFor('daily', 1, start, now), DateTime(2026, 9, 15));
    // weekly
    expect(nextOccurrenceFor('weekly', 2, DateTime(2026, 9, 1), now), DateTime(2026, 9, 15));
    // yearly clamps Feb 29
    expect(nextOccurrenceFor('yearly', 1, DateTime(2024, 2, 29), DateTime(2025, 3, 1)), DateTime(2026, 2, 28));
  });

  test('recurring repository CRUD round-trip with in-memory DB', () async {
    final db = AppDatabase.memory();
    final repo = DriftRecurringRepository(db);
    final base = DateTime(2026, 10, 1);
    final rt = domain.RecurringTransaction(
      id: 'rt-1',
      type: 'expense',
      accountId: 'acc-1',
      categoryId: 'cat-1',
      amount: 150000,
      currencyCode: 'IDR',
      description: 'Langganan internet',
      frequency: 'monthly',
      interval: 1,
      startDate: base,
      nextOccurrence: base,
      enabled: true,
      createdAt: base,
      updatedAt: base,
    );

    expect(await repo.getAllRecurring(), isEmpty);
    await repo.insertRecurring(rt);
    var list = await repo.getAllRecurring();
    expect(list, hasLength(1));
    expect(list.first.amount, 150000);
    expect(list.first.type, 'expense');
    expect(list.first.nextOccurrence, base);

    await repo.updateRecurring(rt.copyWith(amount: 180000, enabled: false, currencyCode: 'USD'));
    list = await repo.getAllRecurring();
    expect(list.first.amount, 180000);
    expect(list.first.enabled, isFalse);
    expect(list.first.currencyCode, 'USD');

    await repo.deleteRecurring('rt-1');
    expect(await repo.getAllRecurring(), isEmpty);

    await db.close();
  });

  testWidgets('recurring form sheet creates, edits, and deletes an item', (tester) async {
    await initializeDateFormatting('id_ID', null);
    final db = AppDatabase.memory();
    final accountRepo = DriftAccountRepository(db);
    await accountRepo.insertAccount(
      domain_account.Account(
          id: 'acc-1',
          name: 'Cash',
          accountType: 'cash',
          currencyCode: 'IDR',
          initialBalance: 0,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1)),
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        recurringRepositoryProvider.overrideWithValue(DriftRecurringRepository(db)),
        accountRepositoryProvider.overrideWithValue(accountRepo),
        categoryRepositoryProvider.overrideWithValue(DriftCategoryRepository(db)),
      ],
      child: MaterialApp(
        locale: const Locale('id'),
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const RecurringScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    // empty state, then open the create sheet
    expect(find.text('Belum ada data'), findsOneWidget);
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    // pick account + fill amount
    await tester.tap(find.textContaining('Pilih akun'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cash'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '150000');
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Rp 150.000'), findsOneWidget);

    // open edit sheet from the tile and delete
    await tester.tap(find.textContaining('Rp 150.000'));
    await tester.pumpAndSettle();
    expect(find.text('Simpan perubahan'), findsOneWidget);
    await tester.ensureVisible(find.text('Hapus'));
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus').last);
    await tester.pumpAndSettle();

    expect(find.text('Belum ada data'), findsOneWidget);
    await db.close();
  });
}