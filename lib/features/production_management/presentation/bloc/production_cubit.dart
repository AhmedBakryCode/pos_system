import 'package:flutter_bloc/flutter_bloc.dart';


import '../../domain/repositories/production_repository.dart';
import 'production_state.dart';

class ProductionCubit extends Cubit<ProductionState> {
  final ProductionRepository _repository;

  ProductionCubit(this._repository) : super(const ProductionState());

  Future<void> loadProductions({int page = 1, bool refresh = false}) async {
    if (state.status == ProductionStatus.loading) return;

    emit(state.copyWith(
      status: ProductionStatus.loading,
      currentPage: page,
      productions: refresh ? [] : state.productions,
    ));

    try {
      final newProductions = await _repository.getProductions(page: page);
      final allProductions = refresh ? newProductions : [...state.productions, ...newProductions];

      emit(state.copyWith(
        status: ProductionStatus.loaded,
        productions: allProductions,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductionStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> createProduction({
    required int recipeId,
    required double quantity,
  }) async {
    emit(state.copyWith(status: ProductionStatus.loading));
    try {
      final production = await _repository.createProduction(
        recipeId: recipeId,
        quantity: quantity,
      );
      emit(state.copyWith(
        productions: [production, ...state.productions],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductionStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> updateProduction(
    int id, {
    required int recipeId,
    required double quantity,
  }) async {
    emit(state.copyWith(status: ProductionStatus.loading));
    try {
      final updated = await _repository.updateProduction(
        id,
        recipeId: recipeId,
        quantity: quantity,
      );
      final index = state.productions.indexWhere((p) => p.id == id);
      if (index != -1) {
        final newProductions = List.of(state.productions);
        newProductions[index] = updated;
        emit(state.copyWith(productions: newProductions));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProductionStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> executeProduction(int id) async {
    emit(state.copyWith(status: ProductionStatus.loading));
    try {
      await _repository.executeProduction(id);
      // Refresh list or update status locally
      await loadProductions(refresh: true);
    } catch (e) {
      emit(state.copyWith(
        status: ProductionStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> deleteProduction(int id) async {
    emit(state.copyWith(status: ProductionStatus.loading));
    try {
      await _repository.deleteProduction(id);
      emit(state.copyWith(
        productions: state.productions.where((p) => p.id != id).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductionStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
