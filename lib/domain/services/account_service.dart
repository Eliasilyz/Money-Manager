import 'package:money_manager/domain/entities/account.dart';
import 'package:money_manager/domain/repositories/account_repository.dart';

class AccountService {
  final IAccountRepository _accountRepository;

  AccountService(this._accountRepository);

  Future<List<Account>> getAllAccounts() => _accountRepository.getAllAccounts();
  Stream<List<Account>> watchAllAccounts() => _accountRepository.watchAllAccounts();

  Future<Account?> getAccountById(String id) => _accountRepository.getAccountById(id);

  Future<void> createAccount({
    required String name,
    required String accountType,
    required String currencyCode,
    required int initialBalance,
    String? icon,
    String? color,
    String? note,
  }) async {
    final account = Account(
      id: _generateId(),
      name: name,
      accountType: accountType,
      currencyCode: currencyCode,
      initialBalance: initialBalance,
      icon: icon,
      color: color,
      note: note,
      isArchived: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _accountRepository.insertAccount(account);
  }

  Future<void> updateAccount(Account account) => _accountRepository.updateAccount(account);
  Future<void> deleteAccount(String id) => _accountRepository.deleteAccount(id);
  Future<void> archiveAccount(String id, bool archived) => _accountRepository.archiveAccount(id, archived);
}

String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
