import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/grn.dart';
import '../../domain/repositories/grn_repository.dart';

class GRNRepositoryImpl implements GRNRepository {
  final DioClient _dioClient;

  GRNRepositoryImpl(this._dioClient);

  @override
  Future<List<GRN>> getGRNs({int page = 1}) async {
    try {
      final response = await _dioClient.getPaginated(ApiConstants.grns);
      final data = response.data['data']['data'] as List;
      return data.map((json) => GRN.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل جلب أذونات استلام البضائع');
    }
  }

  @override
  Future<GRN> createGRN({
    required int purchaseOrderId,
    required List<GRNItemInput> items,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.grns,
        data: {
          'purchase_order_id': purchaseOrderId,
          'items': items.map((i) => i.toJson()).toList(),
        },
      );
      return GRN.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل إنشاء إذن الاستلام');
    }
  }

  @override
  Future<GRN> updateGRN(
    int id, {
    required int purchaseOrderId,
    required List<GRNItemInput> items,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.grns}/$id',
        data: {
          'purchase_order_id': purchaseOrderId,
          'items': items.map((i) => i.toJson()).toList(),
        },
      );
      return GRN.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل تحديث إذن الاستلام');
    }
  }

  @override
  Future<void> deleteGRN(int id) async {
    try {
      await _dioClient.dio.delete('${ApiConstants.grns}/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل حذف إذن الاستلام');
    }
  }
}
