import 'package:drift/drift.dart';
import 'package:money_manager/database/database.dart' as drift;
import 'package:money_manager/domain/entities/category.dart' as domain;
import 'package:money_manager/domain/repositories/category_repository.dart';

class DriftCategoryRepository implements ICategoryRepository {
  final drift.AppDatabase _db;

  DriftCategoryRepository(this._db);

  @override
  Future<List<domain.Category>> getAllCategories() async {
    final categories = await _db.categoriesDao.getAllCategories();
    return categories.map((c) => domain.Category(
          id: c.id,
          name: c.name,
          icon: c.icon,
          type: c.type,
          parentId: c.parentId,
          systemKey: c.systemKey,
          createdAt: c.createdAt,
          updatedAt: c.updatedAt,
        )).toList();
  }

  @override
  Stream<List<domain.Category>> watchAllCategories() =>
      _db.categoriesDao.watchAllCategories().map((categories) =>
          categories.map((c) => domain.Category(
                id: c.id,
                name: c.name,
                icon: c.icon,
                type: c.type,
                parentId: c.parentId,
                systemKey: c.systemKey,
                createdAt: c.createdAt,
                updatedAt: c.updatedAt,
              )).toList());

  @override
  Stream<List<domain.Category>> watchCategoriesByType(String type) =>
      _db.categoriesDao.watchCategoriesByType(type).map((categories) =>
          categories.map((c) => domain.Category(
                id: c.id,
                name: c.name,
                icon: c.icon,
                type: c.type,
                parentId: c.parentId,
                systemKey: c.systemKey,
                createdAt: c.createdAt,
                updatedAt: c.updatedAt,
              )).toList());

  @override
  Future<void> insertCategory(domain.Category category) async {
    await _db.categoriesDao.insertCategory(
      drift.CategoriesTableCompanion(
        id: Value(category.id),
        name: Value(category.name),
        icon: Value(category.icon),
        type: Value(category.type),
        parentId: Value(category.parentId),
        systemKey: Value(category.systemKey),
        createdAt: Value(category.createdAt),
        updatedAt: Value(category.updatedAt),
      ),
    );
  }

  @override
  Future<void> updateCategory(domain.Category category) async {
    await _db.categoriesDao.updateCategory(
      drift.CategoriesTableCompanion(
        id: Value(category.id),
        name: Value(category.name),
        icon: Value(category.icon),
        type: Value(category.type),
        parentId: Value(category.parentId),
        systemKey: Value(category.systemKey),
        createdAt: Value(category.createdAt),
        updatedAt: Value(category.updatedAt),
      ),
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _db.categoriesDao.deleteCategory(id);
  }

  @override
  Future<domain.Category?> getCategoryById(String id) async {
    final categories = await _db.categoriesDao.getAllCategories();
    final match = categories.where((c) => c.id == id).firstOrNull;
    if (match == null) return null;
    return domain.Category(
      id: match.id,
      name: match.name,
      icon: match.icon,
      type: match.type,
      parentId: match.parentId,
      systemKey: match.systemKey,
      createdAt: match.createdAt,
      updatedAt: match.updatedAt,
    );
  }
}
