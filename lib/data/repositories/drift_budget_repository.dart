import 'package:drift/drift.dart';
import 'package:money_manager/database/database.dart' as drift;
import 'package:money_manager/domain/entities/budget.dart' as domain;
import 'package:money_manager/domain/repositories/budget_repository.dart';

class DriftBudgetRepository implements IBudgetRepository {
  final drift.AppDatabase _db;

  DriftBudgetRepository(this._db);

  @override
  Future<List<domain.Budget>> getAllBudgets() async {
    final budgets = await _db.budgetsDao.getAllBudgets();
    return budgets.map((b) => _toDomain(b)).toList();
  }

  @override
  Stream<List<domain.Budget>> watchAllBudgets() =>
      _db.budgetsDao.watchAllBudgets().map((budgets) =>
          budgets.map(_toDomain).toList());

  @override
  Stream<List<domain.Budget>> watchBudgetsByCategory(String categoryId) =>
      _db.budgetsDao.watchBudgetsByCategory(categoryId).map((budgets) =>
          budgets.map(_toDomain).toList());

  @override
  Future<void> insertBudget(domain.Budget budget) async {
    await _db.budgetsDao.insertBudget(
      drift.BudgetsTableCompanion(
        id: Value(budget.id),
        categoryId: Value(budget.categoryId),
        amount: Value(budget.amount),
        currencyCode: Value(budget.currencyCode),
        period: Value(budget.period),
        startDate: Value(budget.startDate),
        endDate: Value(budget.endDate),
        createdAt: Value(budget.createdAt),
        updatedAt: Value(budget.updatedAt),
      ),
    );
  }

  @override
  Future<void> updateBudget(domain.Budget budget) async {
    await _db.budgetsDao.updateBudget(
      drift.BudgetsTableCompanion(
        id: Value(budget.id),
        categoryId: Value(budget.categoryId),
        amount: Value(budget.amount),
        currencyCode: Value(budget.currencyCode),
        period: Value(budget.period),
        startDate: Value(budget.startDate),
        endDate: Value(budget.endDate),
        createdAt: Value(budget.createdAt),
        updatedAt: Value(budget.updatedAt),
      ),
    );
  }

  @override
  Future<void> deleteBudget(String id) async {
    await _db.budgetsDao.deleteBudget(id);
  }

  domain.Budget _toDomain(drift.Budget b) => domain.Budget(
        id: b.id,
        categoryId: b.categoryId,
        amount: b.amount,
        currencyCode: b.currencyCode,
        period: b.period,
        startDate: b.startDate,
        endDate: b.endDate,
        createdAt: b.createdAt,
        updatedAt: b.updatedAt,
      );
}
