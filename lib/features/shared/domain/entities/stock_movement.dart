import 'stock_costing_method.dart';
import 'stock_movement_type.dart';

class StockMovement {
  const StockMovement({
    required this.id,
    required this.eventId,
    required this.transactionId,
    required this.productId,
    required this.warehouseId,
    required this.type,
    required this.quantity,
    required this.unitCost,
    required this.beforeQuantity,
    required this.afterQuantity,
    required this.costingMethod,
    required this.createdBy,
    required this.sourceModule,
  });

  final String id;
  final String eventId;
  final String transactionId;
  final String productId;
  final String warehouseId;
  final StockMovementType type;
  final double quantity;
  final double unitCost;
  final double beforeQuantity;
  final double afterQuantity;
  final StockCostingMethod costingMethod;
  final String createdBy;
  final String sourceModule;
}
