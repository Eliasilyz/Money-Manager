import 'package:money_manager/domain/entities/goal.dart';

abstract class IGoalRepository {
  Future<List<Goal>> getAllGoals();
  Stream<List<Goal>> watchAllGoals();
  Future<void> insertGoal(Goal goal);
  Future<void> updateGoal(Goal goal);
  Future<void> deleteGoal(String id);
}
