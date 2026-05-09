import '../entities/inventory_reconciliation_issue.dart';
import '../entities/stock_costing_method.dart';

class InventoryPolicyService {
  const InventoryPolicyService();

  bool canPostOutboundMovement({
    required double availableQuantity,
    required double requestedQuantity,
    required bool allowNegativeOverride,
  }) {
    if (allowNegativeOverride) {
      return true;
    }

    return availableQuantity >= requestedQuantity;
  }

  String nextPurchaseOrderStatus({
    required bool isCancelled,
    required double orderedQuantity,
    required double receivedQuantity,
  }) {
    if (isCancelled && receivedQuantity == 0) {
      return 'cancelled';
    }

    if (isCancelled && receivedQuantity > 0) {
      return 'partially_received_cancelled_remainder';
    }

    if (receivedQuantity == 0) {
      return 'approved';
    }

    if (receivedQuantity < orderedQuantity) {
      return 'partially_received';
    }

    return 'fully_received';
  }

  double calculateWeightedAverageCost({
    required double currentQuantity,
    required double currentAverageCost,
    required double receivedQuantity,
    required double receivedUnitCost,
  }) {
    final totalQuantity = currentQuantity + receivedQuantity;

    if (totalQuantity == 0) {
      return 0;
    }

    return ((currentQuantity * currentAverageCost) +
            (receivedQuantity * receivedUnitCost)) /
        totalQuantity;
  }

  List<InventoryReconciliationIssue> detectPosInventoryMismatch({
    required String posOrderId,
    required double posQuantity,
    required double inventoryQuantity,
    required bool movementExists,
  }) {
    final issues = <InventoryReconciliationIssue>[];

    if (!movementExists) {
      issues.add(
        InventoryReconciliationIssue(
          referenceId: posOrderId,
          reason: 'POS order exists without inventory movement.',
          severity: 'high',
          requiresManualReview: true,
        ),
      );
    }

    if (posQuantity != inventoryQuantity) {
      issues.add(
        InventoryReconciliationIssue(
          referenceId: posOrderId,
          reason: 'POS quantity does not match inventory deduction.',
          severity: 'critical',
          requiresManualReview: true,
        ),
      );
    }

    return issues;
  }

  bool supportsMethod(StockCostingMethod method) {
    return method == StockCostingMethod.fifo ||
        method == StockCostingMethod.weightedAverage;
  }
}
