import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/domain/entities/goal.dart';
import 'package:money_manager/domain/repositories/goal_repository.dart';

final goalRepositoryProvider = Provider<IGoalRepository>((ref) {
  throw UnimplementedError('GoalRepository not initialized');
});

class GoalsNotifier extends StateNotifier<AsyncValue<List<Goal>>> {
  final IGoalRepository _repo;

  GoalsNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadGoals();
  }

  Future<void> loadGoals() async {
    state = const AsyncValue.loading();
    try {
      final goals = await _repo.getAllGoals();
      state = AsyncValue.data(goals);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addGoal(Goal goal) async {
    await _repo.insertGoal(goal);
    await loadGoals();
  }

  Future<void> updateGoal(Goal goal) async {
    await _repo.updateGoal(goal);
    await loadGoals();
  }

  Future<void> deleteGoal(String id) async {
    await _repo.deleteGoal(id);
    await loadGoals();
  }
}

final goalsNotifierProvider = StateNotifierProvider<GoalsNotifier, AsyncValue<List<Goal>>>((ref) {
  return GoalsNotifier(ref.read(goalRepositoryProvider));
});
