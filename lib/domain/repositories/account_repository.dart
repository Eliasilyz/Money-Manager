import 'package:money_manager/domain/entities/account.dart';

abstract class IAccountRepository {
  Future<List<Account>> getAllAccounts();
  Future<List<Account>> getActiveAccounts();
  Future<Account?> getAccountById(String id);
  Stream<List<Account>> watchAllAccounts();
  Stream<List<Account>> watchActiveAccounts();
  Future<void> insertAccount(Account account);
  Future<void> updateAccount(Account account);
  Future<void> deleteAccount(String id);
  Future<void> archiveAccount(String id, bool archived);
  Future<void> updateSortOrders(List<({String id, int sortOrder})> orders);
}
