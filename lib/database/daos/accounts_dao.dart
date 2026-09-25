import 'package:drift/drift.dart';
import 'package:money_manager/database/tables/accounts_table.dart';
import 'package:money_manager/database/database.dart';

part 'accounts_dao.g.dart';

@DriftAccessor(tables: [AccountsTable])
class AccountsDao extends DatabaseAccessor<AppDatabase>
    with _$AccountsDaoMixin {
  final AppDatabase db;

  AccountsDao(this.db) : super(db);

  Future<int> insertAccount(AccountsTableCompanion account) =>
      into(accountsTable).insert(account);

  Future<bool> updateAccount(AccountsTableCompanion account) =>
      update(accountsTable).replace(account);

  Future<int> deleteAccount(String id) =>
      (delete(accountsTable)..where((a) => a.id.equals(id))).go();

  Future<List<Account>> getAllAccounts() =>
      (select(accountsTable)..orderBy([(a) => OrderingTerm.asc(a.sortOrder)])).get();

  Future<List<Account>> getActiveAccounts() =>
      (select(accountsTable)
        ..where((a) => a.isArchived.equals(false))
        ..orderBy([(a) => OrderingTerm.asc(a.sortOrder)]))
      .get();

  Future<Account?> getAccountById(String id) =>
      (select(accountsTable)..where((a) => a.id.equals(id))).getSingleOrNull();

  Stream<List<Account>> watchAllAccounts() =>
      (select(accountsTable)..orderBy([(a) => OrderingTerm.asc(a.sortOrder)])).watch();

  Stream<List<Account>> watchActiveAccounts() =>
      (select(accountsTable)
        ..where((a) => a.isArchived.equals(false))
        ..orderBy([(a) => OrderingTerm.asc(a.sortOrder)]))
      .watch();

  Stream<Account?> watchAccountById(String id) =>
      (select(accountsTable)..where((a) => a.id.equals(id)))
          .watchSingleOrNull();

  Future<int> archiveAccount(String id, bool archived) =>
      (update(accountsTable)..where((a) => a.id.equals(id)))
          .write(AccountsTableCompanion(isArchived: Value(archived)));

  Future<void> updateSortOrders(List<({String id, int sortOrder})> orders) async {
    await batch((b) {
      for (final o in orders) {
        b.update(
          accountsTable,
          AccountsTableCompanion(sortOrder: Value(o.sortOrder)),
          where: (a) => a.id.equals(o.id),
        );
      }
    });
  }
}
