import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/domain/entities/recurring_transaction.dart';
import 'package:money_manager/domain/repositories/recurring_repository.dart';

final recurringRepositoryProvider = Provider<IRecurringRepository>((ref) {
  throw UnimplementedError('RecurringRepository not initialized');
});

class RecurringTransactionsNotifier extends StateNotifier<AsyncValue<List<RecurringTransaction>>> {
  final IRecurringRepository _repo;

  RecurringTransactionsNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repo.getAllRecurring();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(RecurringTransaction rt) async {
    await _repo.insertRecurring(rt);
    await loadAll();
  }

  Future<void> update(RecurringTransaction rt) async {
    await _repo.updateRecurring(rt);
    await loadAll();
  }

  Future<void> toggle(RecurringTransaction rt) async {
    await _repo.updateRecurring(rt.copyWith(enabled: !rt.enabled));
    await loadAll();
  }

  Future<void> delete(String id) async {
    await _repo.deleteRecurring(id);
    await loadAll();
  }
}

final recurringTransactionsNotifierProvider =
    StateNotifierProvider<RecurringTransactionsNotifier, AsyncValue<List<RecurringTransaction>>>((ref) {
  return RecurringTransactionsNotifier(ref.read(recurringRepositoryProvider));
});
