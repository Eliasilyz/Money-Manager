import 'package:drift/drift.dart';
import 'package:money_manager/database/database.dart' as drift;
import 'package:money_manager/domain/entities/goal.dart' as domain;
import 'package:money_manager/domain/repositories/goal_repository.dart';

class DriftGoalRepository implements IGoalRepository {
  final drift.AppDatabase _db;

  DriftGoalRepository(this._db);

  @override
  Future<List<domain.Goal>> getAllGoals() async {
    final goals = await _db.goalsDao.getAllGoals();
    return goals.map(_toDomain).toList();
  }

  @override
  Stream<List<domain.Goal>> watchAllGoals() =>
      _db.goalsDao.watchAllGoals().map((goals) =>
          goals.map(_toDomain).toList());

  @override
  Future<void> insertGoal(domain.Goal goal) async {
    await _db.goalsDao.insertGoal(
      drift.GoalsTableCompanion(
        id: Value(goal.id),
        name: Value(goal.name),
        targetAmount: Value(goal.targetAmount),
        currentAmount: Value(goal.currentAmount),
        currencyCode: Value(goal.currencyCode),
        linkedAccountId: Value(goal.linkedAccountId),
        startDate: Value(goal.startDate),
        targetDate: Value(goal.targetDate),
        status: Value(goal.status),
        note: Value(goal.note),
        createdAt: Value(goal.createdAt),
        updatedAt: Value(goal.updatedAt),
      ),
    );
  }

  @override
  Future<void> updateGoal(domain.Goal goal) async {
    await _db.goalsDao.updateGoal(
      drift.GoalsTableCompanion(
        id: Value(goal.id),
        name: Value(goal.name),
        targetAmount: Value(goal.targetAmount),
        currentAmount: Value(goal.currentAmount),
        currencyCode: Value(goal.currencyCode),
        linkedAccountId: Value(goal.linkedAccountId),
        startDate: Value(goal.startDate),
        targetDate: Value(goal.targetDate),
        status: Value(goal.status),
        note: Value(goal.note),
        createdAt: Value(goal.createdAt),
        updatedAt: Value(goal.updatedAt),
      ),
    );
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _db.goalsDao.deleteGoal(id);
  }

  domain.Goal _toDomain(drift.Goal g) => domain.Goal(
        id: g.id,
        name: g.name,
        targetAmount: g.targetAmount,
        currentAmount: g.currentAmount,
        currencyCode: g.currencyCode,
        linkedAccountId: g.linkedAccountId,
        startDate: g.startDate,
        targetDate: g.targetDate,
        status: g.status,
        note: g.note,
        createdAt: g.createdAt,
        updatedAt: g.updatedAt,
      );
}
