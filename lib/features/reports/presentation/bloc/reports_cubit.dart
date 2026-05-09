import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/reports_repository.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final ReportsRepository _repository;

  ReportsCubit(this._repository) : super(const ReportsState());

  Future<void> loadInventoryReport() async {
    emit(state.copyWith(status: ReportsStatus.loading));
    try {
      final data = await _repository.getInventoryReport();
      emit(state.copyWith(status: ReportsStatus.loaded, inventoryReport: data));
    } catch (e) {
      emit(state.copyWith(status: ReportsStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> loadProfitReport() async {
    emit(state.copyWith(status: ReportsStatus.loading));
    try {
      final data = await _repository.getProfitReport();
      emit(state.copyWith(status: ReportsStatus.loaded, profitReport: data));
    } catch (e) {
      emit(state.copyWith(status: ReportsStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> loadMovementsReport({int page = 1, bool refresh = false}) async {
    emit(state.copyWith(status: ReportsStatus.loading));
    try {
      final data = await _repository.getMovementsReport(page: page);
      final all = refresh ? data : [...state.movementsReport, ...data];
      emit(state.copyWith(status: ReportsStatus.loaded, movementsReport: all));
    } catch (e) {
      emit(state.copyWith(status: ReportsStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> loadVarianceReport() async {
    emit(state.copyWith(status: ReportsStatus.loading));
    try {
      final data = await _repository.getVarianceReport();
      emit(state.copyWith(status: ReportsStatus.loaded, varianceReport: data));
    } catch (e) {
      emit(state.copyWith(status: ReportsStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> loadDailyReport() async {
    emit(state.copyWith(status: ReportsStatus.loading));
    try {
      final data = await _repository.getDailyReport();
      emit(state.copyWith(status: ReportsStatus.loaded, dailyReport: data));
    } catch (e) {
      emit(state.copyWith(status: ReportsStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> loadTopProductsReport() async {
    emit(state.copyWith(status: ReportsStatus.loading));
    try {
      final data = await _repository.getTopProductsReport();
      emit(state.copyWith(status: ReportsStatus.loaded, topProductsReport: data));
    } catch (e) {
      emit(state.copyWith(status: ReportsStatus.error, errorMessage: e.toString()));
    }
  }
}
