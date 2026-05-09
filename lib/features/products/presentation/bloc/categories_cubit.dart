import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/attributes_repository.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final AttributesRepository _repository;

  CategoriesCubit(this._repository) : super(const CategoriesState());

  Future<void> loadCategories({int page = 1, bool refresh = false}) async {
    if (state.status == CategoriesStatus.loading) return;

    emit(state.copyWith(
      status: CategoriesStatus.loading,
      currentPage: page,
      categories: refresh ? [] : state.categories,
    ));

    try {
      final newCategories = await _repository.getCategories(page: page);
      final allCategories = refresh ? newCategories : [...state.categories, ...newCategories];

      emit(state.copyWith(
        status: CategoriesStatus.loaded,
        categories: allCategories,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CategoriesStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> createCategory(String name, String description) async {
    try {
      final category = await _repository.createCategory(name: name, description: description);
      emit(state.copyWith(
        categories: [category, ...state.categories],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CategoriesStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: CategoriesStatus.loaded, errorMessage: null));
      rethrow;
    }
  }

  Future<void> updateCategory(int id, String name, String description) async {
    try {
      final updatedCategory = await _repository.updateCategory(id, name: name, description: description);
      final index = state.categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        final newCategories = List.of(state.categories);
        newCategories[index] = updatedCategory;
        emit(state.copyWith(categories: newCategories));
      }
    } catch (e) {
      emit(state.copyWith(
        status: CategoriesStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: CategoriesStatus.loaded, errorMessage: null));
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _repository.deleteCategory(id);
      final newCategories = state.categories.where((c) => c.id != id).toList();
      emit(state.copyWith(categories: newCategories));
    } catch (e) {
      emit(state.copyWith(
        status: CategoriesStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: CategoriesStatus.loaded, errorMessage: null));
      rethrow;
    }
  }
}
