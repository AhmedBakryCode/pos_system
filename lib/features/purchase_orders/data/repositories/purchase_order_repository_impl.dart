import '../../domain/entities/purchase_order_summary.dart';
import '../../domain/repositories/purchase_order_repository.dart';

class PurchaseOrderRepositoryImpl implements PurchaseOrderRepository {
  @override
  Future<PurchaseOrderSummary> getSummary() async {
    return const PurchaseOrderSummary(openOrders: 18, pendingReceipts: 6);
  }
}
