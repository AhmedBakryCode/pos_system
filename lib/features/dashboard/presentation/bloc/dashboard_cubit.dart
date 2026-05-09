import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/domain/services/dashboard_metrics_service.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._dashboardMetricsService) : super(const DashboardState());

  final DashboardMetricsService _dashboardMetricsService;

  Future<void> loadModules() async {
    emit(state.copyWith(status: DashboardStatus.loading));

    try {
      final metrics = await _dashboardMetricsService.getTopMetrics();
      final modules = await _dashboardMetricsService.getModules();

      emit(
        state.copyWith(
          status: DashboardStatus.loaded,
          metrics: metrics,
          modules: modules,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: 'Unable to load dashboard modules.',
        ),
      );
    }
  }
}
