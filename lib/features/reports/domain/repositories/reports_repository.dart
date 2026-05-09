import '../entities/report_entities.dart';

abstract class ReportsRepository {
  Future<List<InventoryReportItem>> getInventoryReport();
  Future<List<ProfitReportItem>> getProfitReport();
  Future<List<MovementReportItem>> getMovementsReport({int page = 1});
  Future<List<VarianceReportItem>> getVarianceReport();
  Future<DailyReport> getDailyReport();
  Future<List<TopProductReportItem>> getTopProductsReport();
}
