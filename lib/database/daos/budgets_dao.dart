import 'package:drift/drift.dart';
import 'package:money_manager/database/tables/budgets_table.dart';
import 'package:money_manager/database/database.dart';

part 'budgets_dao.g.dart';

@DriftAccessor(tables: [BudgetsTable])
class BudgetsDao extends DatabaseAccessor<AppDatabase> with _$BudgetsDaoMixin {
  final AppDatabase db;

  BudgetsDao(this.db) : super(db);

  Future<int> insertBudget(BudgetsTableCompanion budget) =>
      into(budgetsTable).insert(budget);

  Future<bool> updateBudget(BudgetsTableCompanion budget) =>
      update(budgetsTable).replace(budget);

  Future<int> deleteBudget(String id) =>
      (delete(budgetsTable)..where((b) => b.id.equals(id))).go();

  Stream<List<Budget>> watchAllBudgets() => select(budgetsTable).watch();

  Future<List<Budget>> getAllBudgets() => select(budgetsTable).get();

  Future<Budget?> getBudgetById(String id) =>
      (select(budgetsTable)..where((b) => b.id.equals(id))).getSingleOrNull();

  Stream<List<Budget>> watchBudgetsByCategory(String categoryId) =>
      (select(budgetsTable)..where((b) => b.categoryId.equals(categoryId)))
          .watch();
}
