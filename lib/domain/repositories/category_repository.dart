import 'package:money_manager/domain/entities/category.dart';

abstract class ICategoryRepository {
  Future<List<Category>> getAllCategories();
  Stream<List<Category>> watchAllCategories();
  Stream<List<Category>> watchCategoriesByType(String type);
  Future<void> insertCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
}
