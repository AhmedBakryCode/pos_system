import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/report_entities.dart';
import '../../domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final DioClient _dioClient;

  ReportsRepositoryImpl(this._dioClient);

  @override
  Future<List<InventoryReportItem>> getInventoryReport() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.inventoryReport);
      final data = response.data['data'] as List;
      return data.map((json) => InventoryReportItem.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل جلب تقرير المخزون');
    }
  }

  @override
  Future<List<ProfitReportItem>> getProfitReport() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.profitReport);
      final data = response.data['data'] as List;
      return data.map((json) => ProfitReportItem.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل جلب تقرير الأرباح');
    }
  }

  @override
  Future<List<MovementReportItem>> getMovementsReport({int page = 1}) async {
    try {
      final response = await _dioClient.getPaginated(ApiConstants.movementsReport);
      // Movements are paginated according to the user's provided body
      final data = response.data['data']['data'] as List;
      return data.map((json) => MovementReportItem.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل جلب تقرير الحركات');
    }
  }

  @override
  Future<List<VarianceReportItem>> getVarianceReport() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.varianceReport);
      final data = response.data['data'] as List;
      return data.map((json) => VarianceReportItem.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل جلب تقرير الانحراف');
    }
  }

  @override
  Future<DailyReport> getDailyReport() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.dailyReport);
      return DailyReport.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل جلب التقرير اليومي');
    }
  }

  @override
  Future<List<TopProductReportItem>> getTopProductsReport() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.topProductsReport);
      final data = response.data['data'] as List;
      return data.map((json) => TopProductReportItem.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل جلب تقرير المنتجات الأكثر مبيعاً');
    }
  }
}
