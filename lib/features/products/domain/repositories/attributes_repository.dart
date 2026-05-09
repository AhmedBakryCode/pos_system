import '../entities/category.dart';
import '../entities/unit.dart';

abstract class AttributesRepository {
  // Units
  Future<List<Unit>> getUnits({int page = 1});
  Future<Unit> createUnit({required String name, required String description});
  Future<Unit> updateUnit(int id, {required String name, required String description});
  Future<void> deleteUnit(int id);

  // Categories
  Future<List<Category>> getCategories({int page = 1});
  Future<Category> createCategory({required String name, required String description});
  Future<Category> updateCategory(int id, {required String name, required String description});
  Future<void> deleteCategory(int id);
}
