import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/attributes_repository.dart';
import 'units_state.dart';

class UnitsCubit extends Cubit<UnitsState> {
  final AttributesRepository _repository;

  UnitsCubit(this._repository) : super(const UnitsState());

  Future<void> loadUnits({int page = 1, bool refresh = false}) async {
    if (state.status == UnitsStatus.loading) return;

    emit(state.copyWith(
      status: UnitsStatus.loading,
      currentPage: page,
      units: refresh ? [] : state.units,
    ));

    try {
      final newUnits = await _repository.getUnits(page: page);
      final allUnits = refresh ? newUnits : [...state.units, ...newUnits];

      emit(state.copyWith(
        status: UnitsStatus.loaded,
        units: allUnits,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UnitsStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> createUnit(String name, String description) async {
    try {
      final unit = await _repository.createUnit(name: name, description: description);
      emit(state.copyWith(
        units: [unit, ...state.units],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UnitsStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      // Reset back to loaded
      emit(state.copyWith(status: UnitsStatus.loaded, errorMessage: null));
      rethrow;
    }
  }

  Future<void> updateUnit(int id, String name, String description) async {
    try {
      final updatedUnit = await _repository.updateUnit(id, name: name, description: description);
      final index = state.units.indexWhere((u) => u.id == id);
      if (index != -1) {
        final newUnits = List.of(state.units);
        newUnits[index] = updatedUnit;
        emit(state.copyWith(units: newUnits));
      }
    } catch (e) {
      emit(state.copyWith(
        status: UnitsStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: UnitsStatus.loaded, errorMessage: null));
      rethrow;
    }
  }

  Future<void> deleteUnit(int id) async {
    try {
      await _repository.deleteUnit(id);
      final newUnits = state.units.where((u) => u.id != id).toList();
      emit(state.copyWith(units: newUnits));
    } catch (e) {
      emit(state.copyWith(
        status: UnitsStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: UnitsStatus.loaded, errorMessage: null));
      rethrow;
    }
  }
}
