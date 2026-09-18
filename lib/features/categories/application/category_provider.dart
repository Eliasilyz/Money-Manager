import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/domain/entities/category.dart';
import 'package:money_manager/domain/repositories/category_repository.dart';
import 'package:money_manager/domain/services/category_service.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(ref.read(categoryRepositoryProvider));
});

final categoryRepositoryProvider = Provider<ICategoryRepository>((ref) {
  throw UnimplementedError('CategoryRepository not initialized');
});

class CategoriesNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final CategoryService _service;

  CategoriesNotifier(this._service) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _service.getAllCategories();
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCategory(Category category) async {
    await _service.insertCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _service.deleteCategory(id);
    await loadCategories();
  }
}

final categoriesNotifierProvider = StateNotifierProvider<CategoriesNotifier, AsyncValue<List<Category>>>((ref) {
  return CategoriesNotifier(ref.read(categoryServiceProvider));
});
