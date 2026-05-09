import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/stock_count.dart';
import '../../domain/repositories/stock_count_repository.dart';
import 'stock_count_state.dart';

class StockCountCubit extends Cubit<StockCountState> {
  final StockCountRepository _repository;

  StockCountCubit(this._repository) : super(const StockCountState());

  Future<void> loadStockCounts({int page = 1, bool refresh = false}) async {
    if (state.status == StockCountStatus.loading) return;

    emit(state.copyWith(
      status: StockCountStatus.loading,
      currentPage: page,
      stockCounts: refresh ? [] : state.stockCounts,
    ));

    try {
      final newCounts = await _repository.getStockCounts(page: page);
      final allCounts = refresh ? newCounts : [...state.stockCounts, ...newCounts];

      emit(state.copyWith(
        status: StockCountStatus.loaded,
        stockCounts: allCounts,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StockCountStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> createStockCount({
    required List<StockCountItemInput> items,
  }) async {
    try {
      final count = await _repository.createStockCount(items: items);
      emit(state.copyWith(
        stockCounts: [count, ...state.stockCounts],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StockCountStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: StockCountStatus.loaded, errorMessage: null));
      rethrow;
    }
  }

  Future<void> updateStockCount(
    int id, {
    required List<StockCountItemInput> items,
  }) async {
    try {
      final updated = await _repository.updateStockCount(id, items: items);
      final index = state.stockCounts.indexWhere((c) => c.id == id);
      if (index != -1) {
        final newCounts = List.of(state.stockCounts);
        newCounts[index] = updated;
        emit(state.copyWith(stockCounts: newCounts));
      }
    } catch (e) {
      emit(state.copyWith(
        status: StockCountStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: StockCountStatus.loaded, errorMessage: null));
      rethrow;
    }
  }

  Future<void> applyStockCount(int id) async {
    try {
      await _repository.applyStockCount(id);
      await loadStockCounts(refresh: true);
    } catch (e) {
      emit(state.copyWith(
        status: StockCountStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: StockCountStatus.loaded, errorMessage: null));
      rethrow;
    }
  }

  Future<void> deleteStockCount(int id) async {
    try {
      await _repository.deleteStockCount(id);
      emit(state.copyWith(
        stockCounts: state.stockCounts.where((c) => c.id != id).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StockCountStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: StockCountStatus.loaded, errorMessage: null));
      rethrow;
    }
  }
}
