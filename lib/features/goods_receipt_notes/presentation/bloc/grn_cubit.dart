import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/grn.dart';
import '../../domain/repositories/grn_repository.dart';
import 'grn_state.dart';

class GRNCubit extends Cubit<GRNState> {
  final GRNRepository _repository;

  GRNCubit(this._repository) : super(const GRNState());

  Future<void> loadGRNs({int page = 1, bool refresh = false}) async {
    if (state.status == GRNStatus.loading) return;

    emit(state.copyWith(
      status: GRNStatus.loading,
      currentPage: page,
      grns: refresh ? [] : state.grns,
    ));

    try {
      final newGRNs = await _repository.getGRNs(page: page);
      final allGRNs = refresh ? newGRNs : [...state.grns, ...newGRNs];

      emit(state.copyWith(
        status: GRNStatus.loaded,
        grns: allGRNs,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GRNStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> createGRN({
    required int purchaseOrderId,
    required List<GRNItemInput> items,
  }) async {
    try {
      final grn = await _repository.createGRN(
        purchaseOrderId: purchaseOrderId,
        items: items,
      );
      emit(state.copyWith(
        grns: [grn, ...state.grns],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GRNStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: GRNStatus.loaded, errorMessage: null));
      rethrow;
    }
  }

  Future<void> updateGRN(
    int id, {
    required int purchaseOrderId,
    required List<GRNItemInput> items,
  }) async {
    try {
      final updated = await _repository.updateGRN(
        id,
        purchaseOrderId: purchaseOrderId,
        items: items,
      );
      final index = state.grns.indexWhere((g) => g.id == id);
      if (index != -1) {
        final newGRNs = List.of(state.grns);
        newGRNs[index] = updated;
        emit(state.copyWith(grns: newGRNs));
      }
    } catch (e) {
      emit(state.copyWith(
        status: GRNStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: GRNStatus.loaded, errorMessage: null));
      rethrow;
    }
  }

  Future<void> deleteGRN(int id) async {
    try {
      await _repository.deleteGRN(id);
      emit(state.copyWith(
        grns: state.grns.where((g) => g.id != id).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GRNStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: GRNStatus.loaded, errorMessage: null));
      rethrow;
    }
  }
}
