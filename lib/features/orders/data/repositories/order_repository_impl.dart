import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final DioClient _dioClient;

  OrderRepositoryImpl(this._dioClient);

  @override
  Future<List<SalesOrder>> getOrders({int page = 1}) async {
    try {
      final response = await _dioClient.getPaginated(ApiConstants.orders);
      final data = response.data['data']['data'] as List;
      return data.map((json) => SalesOrder.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل جلب الطلبات');
    }
  }

  @override
  Future<SalesOrder> createOrder({
    required List<OrderItemInput> items,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.orders,
        data: {
          'items': items.map((i) => i.toJson()).toList(),
        },
      );
      return SalesOrder.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل إنشاء الطلب');
    }
  }

  @override
  Future<void> deleteOrder(int id) async {
    try {
      await _dioClient.dio.delete('${ApiConstants.orders}/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل حذف الطلب');
    }
  }
}
