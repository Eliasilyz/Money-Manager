import 'package:drift/drift.dart';
import 'package:money_manager/database/tables/categories_table.dart';
import 'package:money_manager/database/database.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [CategoriesTable])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  final AppDatabase db;

  CategoriesDao(this.db) : super(db);

  Future<int> insertCategory(CategoriesTableCompanion category) =>
      into(categoriesTable).insert(category);

  Future<bool> updateCategory(CategoriesTableCompanion category) =>
      update(categoriesTable).replace(category);

  Future<int> deleteCategory(String id) =>
      (delete(categoriesTable)..where((c) => c.id.equals(id))).go();

  Future<List<Category>> getAllCategories() => select(categoriesTable).get();

  Stream<List<Category>> watchAllCategories() =>
      select(categoriesTable).watch();

  Stream<List<Category>> watchCategoriesByType(String type) =>
      (select(categoriesTable)..where((c) => c.type.equals(type))).watch();

  Stream<List<Category>> watchRootCategories(String type) =>
      (select(categoriesTable)
            ..where((c) => c.type.equals(type))
            ..where((c) => c.parentId.isNull()))
          .watch();

  Stream<List<Category>> watchChildrenOf(String parentId) =>
      (select(categoriesTable)..where((c) => c.parentId.equals(parentId)))
          .watch();
}
