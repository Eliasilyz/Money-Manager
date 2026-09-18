import 'package:drift/drift.dart';
import 'package:money_manager/database/tables/goals_table.dart';
import 'package:money_manager/database/database.dart';

part 'goals_dao.g.dart';

@DriftAccessor(tables: [GoalsTable])
class GoalsDao extends DatabaseAccessor<AppDatabase> with _$GoalsDaoMixin {
  final AppDatabase db;

  GoalsDao(this.db) : super(db);

  Future<int> insertGoal(GoalsTableCompanion goal) =>
      into(goalsTable).insert(goal);

  Future<bool> updateGoal(GoalsTableCompanion goal) =>
      update(goalsTable).replace(goal);

  Future<int> deleteGoal(String id) =>
      (delete(goalsTable)..where((g) => g.id.equals(id))).go();

  Stream<List<Goal>> watchAllGoals() => select(goalsTable).watch();

  Future<List<Goal>> getAllGoals() => select(goalsTable).get();

  Future<Goal?> getGoalById(String id) =>
      (select(goalsTable)..where((g) => g.id.equals(id))).getSingleOrNull();
}
