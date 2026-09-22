import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/domain/entities/budget.dart';
import 'package:money_manager/domain/repositories/budget_repository.dart';

final budgetRepositoryProvider = Provider<IBudgetRepository>((ref) {
  throw UnimplementedError('BudgetRepository not initialized');
});

class BudgetsNotifier extends StateNotifier<AsyncValue<List<Budget>>> {
  final IBudgetRepository _repo;

  BudgetsNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    state = const AsyncValue.loading();
    try {
      final budgets = await _repo.getAllBudgets();
      state = AsyncValue.data(budgets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addBudget(Budget budget) async {
    await _repo.insertBudget(budget);
    await loadBudgets();
  }

  Future<void> updateBudget(Budget budget) async {
    await _repo.updateBudget(budget);
    await loadBudgets();
  }

  Future<void> deleteBudget(String id) async {
    await _repo.deleteBudget(id);
    await loadBudgets();
  }
}

final budgetsNotifierProvider = StateNotifierProvider<BudgetsNotifier, AsyncValue<List<Budget>>>((ref) {
  return BudgetsNotifier(ref.read(budgetRepositoryProvider));
});
