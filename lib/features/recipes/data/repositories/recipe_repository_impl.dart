import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final DioClient _dioClient;

  RecipeRepositoryImpl(this._dioClient);

  @override
  Future<List<Recipe>> getRecipes({int page = 1}) async {
    try {
      final response = await _dioClient.getPaginated(ApiConstants.recipes);
      final data = response.data['data']['data'] as List;
      return data.map((json) => Recipe.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل جلب الوصفات');
    }
  }

  @override
  Future<Recipe> createRecipe({
    required int outputItemId,
    required double outputQuantity,
    required List<RecipeIngredientInput> items,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.recipes,
        data: {
          'output_item_id': outputItemId,
          'output_quantity': outputQuantity,
          'items': items.map((i) => i.toJson()).toList(),
        },
      );
      return Recipe.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل إنشاء الوصفة');
    }
  }

  @override
  Future<Recipe> updateRecipe(
    int id, {
    required int outputItemId,
    required double outputQuantity,
    required List<RecipeIngredientInput> items,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.recipes}/$id',
        data: {
          'output_item_id': outputItemId,
          'output_quantity': outputQuantity,
          'items': items.map((i) => i.toJson()).toList(),
        },
      );
      return Recipe.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل تحديث الوصفة');
    }
  }

  @override
  Future<void> deleteRecipe(int id) async {
    try {
      await _dioClient.dio.delete('${ApiConstants.recipes}/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل حذف الوصفة');
    }
  }
}
