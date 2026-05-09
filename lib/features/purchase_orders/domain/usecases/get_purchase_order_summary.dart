import '../entities/purchase_order_summary.dart';
import '../repositories/purchase_order_repository.dart';

class GetPurchaseOrderSummary {
  const GetPurchaseOrderSummary(this._repository);

  final PurchaseOrderRepository _repository;

  Future<PurchaseOrderSummary> call() => _repository.getSummary();
}
