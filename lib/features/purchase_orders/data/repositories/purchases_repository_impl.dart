import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/purchases_repository.dart';

class PurchasesRepositoryImpl implements PurchasesRepository {
  final DioClient _dioClient;

  PurchasesRepositoryImpl(this._dioClient);

  // --- Purchase Orders ---
  @override
  Future<List<PurchaseOrder>> getPurchaseOrders({int page = 1}) async {
    try {
      final response = await _dioClient.getPaginated(ApiConstants.purchases);
      final data = response.data['data']['data'] as List;
      return data.map((json) => PurchaseOrder.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل جلب أوامر الشراء');
    }
  }

  @override
  Future<PurchaseOrder> createPurchaseOrder({
    required int supplierId,
    required List<PurchaseOrderItemInput> items,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.purchases,
        data: {
          'supplier_id': supplierId,
          'items': items.map((i) => i.toJson()).toList(),
        },
      );
      final data = response.data['data'];
      if (data.containsKey('po')) {
        final poData = Map<String, dynamic>.from(data['po']);
        poData['items'] = data['items'];
        return PurchaseOrder.fromJson(poData);
      }
      return PurchaseOrder.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل إنشاء أمر الشراء');
    }
  }

  @override
  Future<PurchaseOrder> updatePurchaseOrder(
    int id, {
    required int supplierId,
    required List<PurchaseOrderItemInput> items,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.purchases}/$id',
        data: {
          'supplier_id': supplierId,
          'items': items.map((i) => i.toJson()).toList(),
        },
      );
      final data = response.data['data'];
      if (data.containsKey('po')) {
        final poData = Map<String, dynamic>.from(data['po']);
        poData['items'] = data['items'];
        return PurchaseOrder.fromJson(poData);
      }
      return PurchaseOrder.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل تحديث أمر الشراء');
    }
  }

  @override
  Future<void> deletePurchaseOrder(int id) async {
    try {
      await _dioClient.dio.delete('${ApiConstants.purchases}/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل حذف أمر الشراء');
    }
  }

  // --- Suppliers ---
  @override
  Future<List<Supplier>> getSuppliers({int page = 1}) async {
    try {
      final response = await _dioClient.getPaginated(ApiConstants.suppliers);
      final data = response.data['data']['data'] as List;
      return data.map((json) => Supplier.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل جلب الموردين');
    }
  }

  @override
  Future<Supplier> createSupplier({
    required String fname,
    required String lname,
    required String email,
    required String phone,
    required String address,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.suppliers,
        data: {
          'fname': fname,
          'lname': lname,
          'email': email,
          'phone': phone,
          'address': address,
        },
      );
      return Supplier.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل إضافة المورد');
    }
  }

  @override
  Future<Supplier> updateSupplier(
    int id, {
    required String fname,
    required String lname,
    required String email,
    required String phone,
    required String address,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.suppliers}/$id',
        data: {
          'fname': fname,
          'lname': lname,
          'email': email,
          'phone': phone,
          'address': address,
        },
      );
      return Supplier.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل تحديث المورد');
    }
  }

  @override
  Future<void> deleteSupplier(int id) async {
    try {
      await _dioClient.dio.delete('${ApiConstants.suppliers}/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل حذف المورد');
    }
  }
}
