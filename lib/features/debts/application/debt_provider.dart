import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/domain/entities/debt.dart';
import 'package:money_manager/domain/repositories/debt_repository.dart';

final debtRepositoryProvider = Provider<IDebtRepository>((ref) {
  throw UnimplementedError('DebtRepository not initialized');
});

class DebtsNotifier extends StateNotifier<AsyncValue<List<Debt>>> {
  final IDebtRepository _repo;

  DebtsNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadDebts();
  }

  Future<void> loadDebts() async {
    state = const AsyncValue.loading();
    try {
      final debts = await _repo.getAllDebts();
      state = AsyncValue.data(debts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addDebt(Debt debt) async {
    await _repo.insertDebt(debt);
    await loadDebts();
  }

  Future<void> updateDebt(Debt debt) async {
    await _repo.updateDebt(debt);
    await loadDebts();
  }

  Future<void> deleteDebt(String id) async {
    await _repo.deleteDebt(id);
    await loadDebts();
  }
}

final debtsNotifierProvider = StateNotifierProvider<DebtsNotifier, AsyncValue<List<Debt>>>((ref) {
  return DebtsNotifier(ref.read(debtRepositoryProvider));
});
