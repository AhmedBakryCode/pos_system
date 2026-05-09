import 'package:equatable/equatable.dart';
import '../../domain/entities/report_entities.dart';

enum ReportsStatus { initial, loading, loaded, error }

class ReportsState extends Equatable {
  final ReportsStatus status;
  final List<InventoryReportItem> inventoryReport;
  final List<ProfitReportItem> profitReport;
  final List<MovementReportItem> movementsReport;
  final List<VarianceReportItem> varianceReport;
  final DailyReport? dailyReport;
  final List<TopProductReportItem> topProductsReport;
  final String? errorMessage;

  const ReportsState({
    this.status = ReportsStatus.initial,
    this.inventoryReport = const [],
    this.profitReport = const [],
    this.movementsReport = const [],
    this.varianceReport = const [],
    this.dailyReport,
    this.topProductsReport = const [],
    this.errorMessage,
  });

  ReportsState copyWith({
    ReportsStatus? status,
    List<InventoryReportItem>? inventoryReport,
    List<ProfitReportItem>? profitReport,
    List<MovementReportItem>? movementsReport,
    List<VarianceReportItem>? varianceReport,
    DailyReport? dailyReport,
    List<TopProductReportItem>? topProductsReport,
    String? errorMessage,
  }) {
    return ReportsState(
      status: status ?? this.status,
      inventoryReport: inventoryReport ?? this.inventoryReport,
      profitReport: profitReport ?? this.profitReport,
      movementsReport: movementsReport ?? this.movementsReport,
      varianceReport: varianceReport ?? this.varianceReport,
      dailyReport: dailyReport ?? this.dailyReport,
      topProductsReport: topProductsReport ?? this.topProductsReport,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        inventoryReport,
        profitReport,
        movementsReport,
        varianceReport,
        dailyReport,
        topProductsReport,
        errorMessage,
      ];
}
