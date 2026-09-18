import 'package:money_manager/domain/entities/category.dart';
import 'package:money_manager/domain/repositories/category_repository.dart';

class CategoryService {
  final ICategoryRepository _categoryRepository;

  CategoryService(this._categoryRepository);

  Future<List<Category>> getAllCategories() => _categoryRepository.getAllCategories();
  Stream<List<Category>> watchAllCategories() => _categoryRepository.watchAllCategories();

  Future<void> insertCategory(Category category) => _categoryRepository.insertCategory(category);
  Future<void> updateCategory(Category category) => _categoryRepository.updateCategory(category);
  Future<void> deleteCategory(String id) => _categoryRepository.deleteCategory(id);
}
