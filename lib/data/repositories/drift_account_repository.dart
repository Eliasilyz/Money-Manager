import 'package:drift/drift.dart';
import 'package:money_manager/database/database.dart' as drift;
import 'package:money_manager/domain/entities/account.dart' as domain;
import 'package:money_manager/domain/repositories/account_repository.dart';

class DriftAccountRepository implements IAccountRepository {
  final drift.AppDatabase _db;

  DriftAccountRepository(this._db);

  @override
  Future<List<domain.Account>> getAllAccounts() async {
    final accounts = await _db.accountsDao.getAllAccounts();
    return accounts.map((a) => domain.Account(
          id: a.id,
          name: a.name,
          accountType: a.accountType,
          currencyCode: a.currencyCode,
          initialBalance: a.initialBalance,
          icon: a.icon,
          color: a.color,
          note: a.note,
          isArchived: a.isArchived,
          createdAt: a.createdAt,
          updatedAt: a.updatedAt,
        )).toList();
  }

  @override
  Future<List<domain.Account>> getActiveAccounts() async {
    final accounts = await _db.accountsDao.getActiveAccounts();
    return accounts.map((a) => domain.Account(
          id: a.id,
          name: a.name,
          accountType: a.accountType,
          currencyCode: a.currencyCode,
          initialBalance: a.initialBalance,
          icon: a.icon,
          color: a.color,
          note: a.note,
          isArchived: a.isArchived,
          createdAt: a.createdAt,
          updatedAt: a.updatedAt,
        )).toList();
  }

  @override
  Future<domain.Account?> getAccountById(String id) async {
    final account = await _db.accountsDao.getAccountById(id);
    if (account == null) return null;
    return domain.Account(
      id: account.id,
      name: account.name,
      accountType: account.accountType,
      currencyCode: account.currencyCode,
      initialBalance: account.initialBalance,
      icon: account.icon,
      color: account.color,
      note: account.note,
      isArchived: account.isArchived,
      createdAt: account.createdAt,
      updatedAt: account.updatedAt,
    );
  }

  @override
  Stream<List<domain.Account>> watchAllAccounts() =>
      _db.accountsDao.watchAllAccounts().map((accounts) =>
          accounts.map((a) => domain.Account(
                id: a.id,
                name: a.name,
                accountType: a.accountType,
                currencyCode: a.currencyCode,
                initialBalance: a.initialBalance,
                icon: a.icon,
                color: a.color,
                note: a.note,
                isArchived: a.isArchived,
                createdAt: a.createdAt,
                updatedAt: a.updatedAt,
              )).toList());

  @override
  Stream<List<domain.Account>> watchActiveAccounts() =>
      _db.accountsDao.watchActiveAccounts().map((accounts) =>
          accounts.map((a) => domain.Account(
                id: a.id,
                name: a.name,
                accountType: a.accountType,
                currencyCode: a.currencyCode,
                initialBalance: a.initialBalance,
                icon: a.icon,
                color: a.color,
                note: a.note,
                isArchived: a.isArchived,
                createdAt: a.createdAt,
                updatedAt: a.updatedAt,
              )).toList());

  @override
  Future<void> insertAccount(domain.Account account) async {
    await _db.accountsDao.insertAccount(
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
        createdAt: Value(account.createdAt),
        updatedAt: Value(account.updatedAt),
      ),
    );
  }

  @override
  Future<void> updateAccount(domain.Account account) async {
    await _db.accountsDao.updateAccount(
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
        createdAt: Value(account.createdAt),
        updatedAt: Value(account.updatedAt),
      ),
    );
  }

  @override
  Future<void> deleteAccount(String id) async {
    await _db.accountsDao.deleteAccount(id);
  }

  @override
  Future<void> archiveAccount(String id, bool archived) async {
    await _db.accountsDao.archiveAccount(id, archived);
  }
}
