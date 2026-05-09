import '../entities/purchase_order.dart';
import '../entities/supplier.dart';

abstract class PurchasesRepository {
  // Purchases
  Future<List<PurchaseOrder>> getPurchaseOrders({int page = 1});
  Future<PurchaseOrder> createPurchaseOrder({
    required int supplierId,
    required List<PurchaseOrderItemInput> items,
  });
  Future<PurchaseOrder> updatePurchaseOrder(
    int id, {
    required int supplierId,
    required List<PurchaseOrderItemInput> items,
  });
  Future<void> deletePurchaseOrder(int id);

  // Suppliers
  Future<List<Supplier>> getSuppliers({int page = 1});
  Future<Supplier> createSupplier({
    required String fname,
    required String lname,
    required String email,
    required String phone,
    required String address,
  });
  Future<Supplier> updateSupplier(
    int id, {
    required String fname,
    required String lname,
    required String email,
    required String phone,
    required String address,
  });
  Future<void> deleteSupplier(int id);
}
