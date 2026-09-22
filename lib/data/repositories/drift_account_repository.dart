import 'package:drift/drift.dart';
import 'package:money_manager/database/database.dart' as drift;
import 'package:money_manager/domain/entities/account.dart' as domain;
import 'package:money_manager/domain/repositories/account_repository.dart';

class DriftAccountRepository implements IAccountRepository {
  final drift.AppDatabase _db;

  DriftAccountRepository(this._db);

  domain.Account _map(drift.Account a) => domain.Account(
        id: a.id,
        name: a.name,
        accountType: a.accountType,
        currencyCode: a.currencyCode,
        initialBalance: a.initialBalance,
        icon: a.icon,
        color: a.color,
        note: a.note,
        isArchived: a.isArchived,
        sortOrder: a.sortOrder,
        systemKey: a.systemKey,
        createdAt: a.createdAt,
        updatedAt: a.updatedAt,
      );

  @override
  Future<List<domain.Account>> getAllAccounts() async {
    final accounts = await _db.accountsDao.getAllAccounts();
    return accounts.map(_map).toList();
  }

  @override
  Future<List<domain.Account>> getActiveAccounts() async {
    final accounts = await _db.accountsDao.getActiveAccounts();
    return accounts.map(_map).toList();
  }

  @override
  Future<domain.Account?> getAccountById(String id) async {
    final account = await _db.accountsDao.getAccountById(id);
    if (account == null) return null;
    return _map(account);
  }

  @override
  Stream<List<domain.Account>> watchAllAccounts() =>
      _db.accountsDao.watchAllAccounts().map((accounts) => accounts.map(_map).toList());

  @override
  Stream<List<domain.Account>> watchActiveAccounts() =>
      _db.accountsDao.watchActiveAccounts().map((accounts) => accounts.map(_map).toList());

  drift.AccountsTableCompanion _toCompanion(domain.Account account) =>
      drift.AccountsTableCompanion(
        id: Value(account.id),
        name: Value(account.name),
        currencyCode: Value(account.currencyCode),
        accountType: Value(account.accountType),
        initialBalance: Value(account.initialBalance),
        icon: Value(account.icon),
        color: Value(account.color),
        note: Value(account.note),
        isArchived: Value(account.isArchived),
        sortOrder: Value(account.sortOrder),
        systemKey: Value(account.systemKey),
        createdAt: Value(account.createdAt),
        updatedAt: Value(account.updatedAt),
      );

  @override
  Future<void> insertAccount(domain.Account account) async {
    await _db.accountsDao.insertAccount(_toCompanion(account));
  }

  @override
  Future<void> updateAccount(domain.Account account) async {
    await _db.accountsDao.updateAccount(_toCompanion(account));
  }

  @override
  Future<void> deleteAccount(String id) async {
    await _db.accountsDao.deleteAccount(id);
  }

  @override
  Future<void> archiveAccount(String id, bool archived) async {
    await _db.accountsDao.archiveAccount(id, archived);
  }

  @override
  Future<void> updateSortOrders(List<({String id, int sortOrder})> orders) async {
    await _db.accountsDao.updateSortOrders(orders);
  }
}
