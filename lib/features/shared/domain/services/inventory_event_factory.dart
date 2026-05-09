import '../entities/domain_event.dart';

class InventoryEventFactory {
  const InventoryEventFactory();

  DomainEvent goodsReceiptPosted({
    required String grnId,
    required String productId,
    required double quantity,
  }) {
    return DomainEvent(
      name: 'GoodsReceiptPosted',
      aggregateId: grnId,
      occurredAtIso: DateTime.now().toIso8601String(),
      payload: {
        'productId': productId,
        'quantity': quantity,
      },
    );
  }

  DomainEvent posSyncFailed({
    required String posOrderId,
    required String reason,
  }) {
    return DomainEvent(
      name: 'InventorySyncFailed',
      aggregateId: posOrderId,
      occurredAtIso: DateTime.now().toIso8601String(),
      payload: {
        'reason': reason,
      },
    );
  }
}
