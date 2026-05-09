import 'package:equatable/equatable.dart';

import '../../../shared/domain/entities/dashboard_metric.dart';
import '../../../shared/domain/entities/dashboard_module.dart';

enum DashboardStatus { initial, loading, loaded, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.metrics = const [],
    this.modules = const [],
    this.errorMessage,
  });

  final DashboardStatus status;
  final List<DashboardMetric> metrics;
  final List<DashboardModule> modules;
  final String? errorMessage;

  DashboardState copyWith({
    DashboardStatus? status,
    List<DashboardMetric>? metrics,
    List<DashboardModule>? modules,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      metrics: metrics ?? this.metrics,
      modules: modules ?? this.modules,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, metrics, modules, errorMessage];
}
