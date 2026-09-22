import 'package:uuid/uuid.dart';
import 'package:money_manager/domain/entities/account.dart';
import 'package:money_manager/domain/repositories/account_repository.dart';

class AccountService {
  final IAccountRepository _accountRepository;
  static const _uuid = Uuid();

  AccountService(this._accountRepository);

  Future<List<Account>> getAllAccounts() => _accountRepository.getAllAccounts();
  Stream<List<Account>> watchAllAccounts() => _accountRepository.watchAllAccounts();

  Future<Account?> getAccountById(String id) => _accountRepository.getAccountById(id);

  Future<Account> createAccount({
    required String name,
    required String accountType,
    required String currencyCode,
    required int initialBalance,
    String? icon,
    String? color,
    String? note,
    String? systemKey,
  }) async {
    final now = DateTime.now();
    final account = Account(
      id: _uuid.v4(),
      name: name,
      accountType: accountType,
      currencyCode: currencyCode,
      initialBalance: initialBalance,
      icon: icon,
      color: color,
      note: note,
      isArchived: false,
      systemKey: systemKey,
      createdAt: now,
      updatedAt: now,
    );
    await _accountRepository.insertAccount(account);
    return account;
  }

  Future<Account> ensurePocket({
    required String systemKey,
    required String name,
    required String currencyCode,
  }) async {
    final accounts = await _accountRepository.getAllAccounts();
    for (final a in accounts) {
      if (a.systemKey == systemKey) return a;
    }
    return createAccount(
      name: name,
      accountType: 'savings',
      currencyCode: currencyCode,
      initialBalance: 0,
      systemKey: systemKey,
    );
  }

  Future<void> updateAccount(Account account) => _accountRepository.updateAccount(account);
  Future<void> deleteAccount(String id) => _accountRepository.deleteAccount(id);
  Future<void> archiveAccount(String id, bool archived) => _accountRepository.archiveAccount(id, archived);
  Future<void> updateSortOrders(List<({String id, int sortOrder})> orders) => _accountRepository.updateSortOrders(orders);
}
