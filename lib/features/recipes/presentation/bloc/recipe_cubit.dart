import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import 'recipe_state.dart';

class RecipeCubit extends Cubit<RecipeState> {
  final RecipeRepository _repository;

  RecipeCubit(this._repository) : super(const RecipeState());

  Future<void> loadRecipes({int page = 1, bool refresh = false}) async {
    if (state.status == RecipeStatus.loading) return;

    emit(state.copyWith(
      status: RecipeStatus.loading,
      currentPage: page,
      recipes: refresh ? [] : state.recipes,
    ));

    try {
      final newRecipes = await _repository.getRecipes(page: page);
      final allRecipes = refresh ? newRecipes : [...state.recipes, ...newRecipes];

      emit(state.copyWith(
        status: RecipeStatus.loaded,
        recipes: allRecipes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RecipeStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> createRecipe({
    required int outputItemId,
    required double outputQuantity,
    required List<RecipeIngredientInput> items,
  }) async {
    try {
      final recipe = await _repository.createRecipe(
        outputItemId: outputItemId,
        outputQuantity: outputQuantity,
        items: items,
      );
      emit(state.copyWith(
        recipes: [recipe, ...state.recipes],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RecipeStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: RecipeStatus.loaded, errorMessage: null));
      rethrow;
    }
  }

  Future<void> updateRecipe(
    int id, {
    required int outputItemId,
    required double outputQuantity,
    required List<RecipeIngredientInput> items,
  }) async {
    try {
      final updated = await _repository.updateRecipe(
        id,
        outputItemId: outputItemId,
        outputQuantity: outputQuantity,
        items: items,
      );
      final index = state.recipes.indexWhere((r) => r.id == id);
      if (index != -1) {
        final newRecipes = List.of(state.recipes);
        newRecipes[index] = updated;
        emit(state.copyWith(recipes: newRecipes));
      }
    } catch (e) {
      emit(state.copyWith(
        status: RecipeStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: RecipeStatus.loaded, errorMessage: null));
      rethrow;
    }
  }

  Future<void> deleteRecipe(int id) async {
    try {
      await _repository.deleteRecipe(id);
      emit(state.copyWith(
        recipes: state.recipes.where((r) => r.id != id).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RecipeStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: RecipeStatus.loaded, errorMessage: null));
      rethrow;
    }
  }
}
