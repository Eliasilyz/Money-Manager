import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/domain/entities/account.dart';
import 'package:money_manager/domain/repositories/account_repository.dart';
import 'package:money_manager/domain/services/account_service.dart';

final accountServiceProvider = Provider<AccountService>((ref) {
  return AccountService(ref.read(accountRepositoryProvider));
});

final accountRepositoryProvider = Provider<IAccountRepository>((ref) {
  throw UnimplementedError('AccountRepository not initialized');
});

class AccountsNotifier extends StateNotifier<AsyncValue<List<Account>>> {
  final AccountService _service;

  AccountsNotifier(this._service) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final accounts = await _service.getAllAccounts();
      state = AsyncValue.data(accounts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadAccounts() async {
    state = const AsyncValue.loading();
    await _init();
  }

  Future<void> addAccount({
    required String name,
    required String accountType,
    required String currencyCode,
    required int initialBalance,
    String? icon,
    String? color,
    String? note,
  }) async {
    await _service.createAccount(
      name: name,
      accountType: accountType,
      currencyCode: currencyCode,
      initialBalance: initialBalance,
      icon: icon,
      color: color,
      note: note,
    );
    await loadAccounts();
  }

  Future<void> updateAccount(Account account) async {
    await _service.updateAccount(account);
    await loadAccounts();
  }

  Future<void> deleteAccount(String id) async {
    await _service.deleteAccount(id);
    await loadAccounts();
  }

  Future<void> archiveAccount(String id, bool archived) async {
    await _service.archiveAccount(id, archived);
    await loadAccounts();
  }

  Future<void> updateSortOrders(List<({String id, int sortOrder})> orders) async {
    final currentList = state.valueOrNull;
    if (currentList != null) {
      final orderMap = {for (final o in orders) o.id: o.sortOrder};
      final updatedList = currentList.map((a) {
        if (orderMap.containsKey(a.id)) {
          return a.copyWith(sortOrder: orderMap[a.id]);
        }
        return a;
      }).toList();
      state = AsyncValue.data(updatedList);
    }
    await _service.updateSortOrders(orders);
  }
}

final accountsNotifierProvider = StateNotifierProvider<AccountsNotifier, AsyncValue<List<Account>>>((ref) {
  return AccountsNotifier(ref.read(accountServiceProvider));
});
