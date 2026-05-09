import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/waste.dart';
import '../../domain/repositories/waste_repository.dart';
import 'waste_state.dart';

class WasteCubit extends Cubit<WasteState> {
  final WasteRepository _repository;

  WasteCubit(this._repository) : super(const WasteState());

  Future<void> loadWastes({int page = 1, bool refresh = false}) async {
    if (state.status == WasteStatus.loading) return;

    emit(state.copyWith(
      status: WasteStatus.loading,
      currentPage: page,
      wastes: refresh ? [] : state.wastes,
    ));

    try {
      final newWastes = await _repository.getWastes(page: page);
      final allWastes = refresh ? newWastes : [...state.wastes, ...newWastes];

      emit(state.copyWith(
        status: WasteStatus.loaded,
        wastes: allWastes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WasteStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> createWaste({
    required String reason,
    required List<WasteItemInput> items,
  }) async {
    emit(state.copyWith(status: WasteStatus.loading));
    try {
      final waste = await _repository.createWaste(reason: reason, items: items);
      emit(state.copyWith(
        wastes: [waste, ...state.wastes],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WasteStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> updateWaste(
    int id, {
    required String reason,
    required List<WasteItemInput> items,
  }) async {
    emit(state.copyWith(status: WasteStatus.loading));
    try {
      final updated = await _repository.updateWaste(id, reason: reason, items: items);
      final index = state.wastes.indexWhere((w) => w.id == id);
      if (index != -1) {
        final newWastes = List.of(state.wastes);
        newWastes[index] = updated;
        emit(state.copyWith(wastes: newWastes));
      }
    } catch (e) {
      emit(state.copyWith(
        status: WasteStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: WasteStatus.loaded, errorMessage: null));
      rethrow;
    }
  }

  Future<void> deleteWaste(int id) async {
    emit(state.copyWith(status: WasteStatus.loading));
    try {
      await _repository.deleteWaste(id);
      emit(state.copyWith(
        wastes: state.wastes.where((w) => w.id != id).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WasteStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
