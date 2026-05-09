import '../entities/recipe.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> getRecipes({int page = 1});
  
  Future<Recipe> createRecipe({
    required int outputItemId,
    required double outputQuantity,
    required List<RecipeIngredientInput> items,
  });

  Future<Recipe> updateRecipe(
    int id, {
    required int outputItemId,
    required double outputQuantity,
    required List<RecipeIngredientInput> items,
  });

  Future<void> deleteRecipe(int id);
}
