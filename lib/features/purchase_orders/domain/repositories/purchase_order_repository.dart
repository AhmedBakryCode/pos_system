import '../entities/purchase_order_summary.dart';

abstract class PurchaseOrderRepository {
  Future<PurchaseOrderSummary> getSummary();
}
