import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/stock_count.dart';
import '../../domain/repositories/stock_count_repository.dart';

class StockCountRepositoryImpl implements StockCountRepository {
  final DioClient _dioClient;

  StockCountRepositoryImpl(this._dioClient);

  @override
  Future<List<StockCount>> getStockCounts({int page = 1}) async {
    try {
      final response = await _dioClient.getPaginated(ApiConstants.stockCounts);
      final data = response.data['data']['data'] as List;
      return data.map((json) => StockCount.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل جلب عمليات الجرد');
    }
  }

  @override
  Future<StockCount> createStockCount({
    required List<StockCountItemInput> items,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.stockCounts,
        data: {
          'items': items.map((i) => i.toJson()).toList(),
        },
      );
      return StockCount.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل إنشاء عملية الجرد');
    }
  }

  @override
  Future<StockCount> updateStockCount(
    int id, {
    required List<StockCountItemInput> items,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.stockCounts}/$id',
        data: {
          'items': items.map((i) => i.toJson()).toList(),
        },
      );
      return StockCount.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل تحديث عملية الجرد');
    }
  }

  @override
  Future<void> applyStockCount(int id) async {
    try {
      await _dioClient.dio.post('${ApiConstants.stockCounts}/$id/apply');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل اعتماد عملية الجرد');
    }
  }

  @override
  Future<void> deleteStockCount(int id) async {
    try {
      await _dioClient.dio.delete('${ApiConstants.stockCounts}/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل حذف عملية الجرد');
    }
  }
}
