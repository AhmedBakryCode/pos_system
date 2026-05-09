class InventorySummary {
  const InventorySummary({
    required this.stockValue,
    required this.lowStockItems,
  });

  final double stockValue;
  final int lowStockItems;
}
