import 'package:money_manager/domain/entities/budget.dart';

abstract class IBudgetRepository {
  Future<List<Budget>> getAllBudgets();
  Stream<List<Budget>> watchAllBudgets();
  Stream<List<Budget>> watchBudgetsByCategory(String categoryId);
  Future<void> insertBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<void> deleteBudget(String id);
}
