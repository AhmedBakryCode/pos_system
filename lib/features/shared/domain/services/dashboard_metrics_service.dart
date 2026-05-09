import '../entities/dashboard_metric.dart';
import '../entities/dashboard_module.dart';

abstract class DashboardMetricsService {
  Future<List<DashboardMetric>> getTopMetrics();
  Future<List<DashboardModule>> getModules();
}
