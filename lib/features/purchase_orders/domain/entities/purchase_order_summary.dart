class PurchaseOrderSummary {
  const PurchaseOrderSummary({
    required this.openOrders,
    required this.pendingReceipts,
  });

  final int openOrders;
  final int pendingReceipts;
}
