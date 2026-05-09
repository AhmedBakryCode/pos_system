import 'package:equatable/equatable.dart';

// --- Inventory Report ---
class InventoryReportItem extends Equatable {
  final int itemId;
  final String quantity;
  final String value;

  const InventoryReportItem({
    required this.itemId,
    required this.quantity,
    required this.value,
  });

  factory InventoryReportItem.fromJson(Map<String, dynamic> json) {
    return InventoryReportItem(
      itemId: int.parse(json['item_id'].toString()),
      quantity: json['quantity'].toString(),
      value: json['value'].toString(),
    );
  }

  @override
  List<Object?> get props => [itemId, quantity, value];
}

// --- Profit Report ---
class ProfitReportItem extends Equatable {
  final int orderId;
  final String revenue;
  final String cost;
  final String profit;

  const ProfitReportItem({
    required this.orderId,
    required this.revenue,
    required this.cost,
    required this.profit,
  });

  factory ProfitReportItem.fromJson(Map<String, dynamic> json) {
    return ProfitReportItem(
      orderId: int.parse(json['order_id'].toString()),
      revenue: json['revenue'].toString(),
      cost: json['cost'].toString(),
      profit: json['profit'].toString(),
    );
  }

  @override
  List<Object?> get props => [orderId, revenue, cost, profit];
}

// --- Movement Report ---
class MovementReportItem extends Equatable {
  final int id;
  final int itemId;
  final String type;
  final String quantity;
  final String beforeQuantity;
  final String afterQuantity;
  final String unitCost;
  final String totalCost;
  final String? referenceType;
  final int? referenceId;
  final String? createdAt;

  const MovementReportItem({
    required this.id,
    required this.itemId,
    required this.type,
    required this.quantity,
    required this.beforeQuantity,
    required this.afterQuantity,
    required this.unitCost,
    required this.totalCost,
    this.referenceType,
    this.referenceId,
    this.createdAt,
  });

  factory MovementReportItem.fromJson(Map<String, dynamic> json) {
    return MovementReportItem(
      id: int.parse(json['id'].toString()),
      itemId: int.parse(json['item_id'].toString()),
      type: json['type'] as String,
      quantity: json['quantity'].toString(),
      beforeQuantity: json['before_quantity'].toString(),
      afterQuantity: json['after_quantity'].toString(),
      unitCost: json['unit_cost'].toString(),
      totalCost: json['total_cost'].toString(),
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] != null ? int.parse(json['reference_id'].toString()) : null,
      createdAt: json['created_at'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, itemId, type, quantity];
}

// --- Variance Report ---
class VarianceReportItem extends Equatable {
  final int id;
  final int stockCountId;
  final int itemId;
  final String systemQuantity;
  final String actualQuantity;
  final String difference;
  final String unitCost;
  final String totalCost;
  final String? createdAt;

  const VarianceReportItem({
    required this.id,
    required this.stockCountId,
    required this.itemId,
    required this.systemQuantity,
    required this.actualQuantity,
    required this.difference,
    required this.unitCost,
    required this.totalCost,
    this.createdAt,
  });

  factory VarianceReportItem.fromJson(Map<String, dynamic> json) {
    return VarianceReportItem(
      id: int.parse(json['id'].toString()),
      stockCountId: int.parse(json['stock_count_id'].toString()),
      itemId: int.parse(json['item_id'].toString()),
      systemQuantity: json['system_quantity'].toString(),
      actualQuantity: json['actual_quantity'].toString(),
      difference: json['difference'].toString(),
      unitCost: json['unit_cost'].toString(),
      totalCost: json['total_cost'].toString(),
      createdAt: json['created_at'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, itemId, difference];
}

// --- Daily Report ---
class DailyReport extends Equatable {
  final String sales;
  final String cost;
  final String profit;
  final String waste;

  const DailyReport({
    required this.sales,
    required this.cost,
    required this.profit,
    required this.waste,
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      sales: json['sales'].toString(),
      cost: json['cost'].toString(),
      profit: json['profit'].toString(),
      waste: json['waste'].toString(),
    );
  }

  @override
  List<Object?> get props => [sales, cost, profit, waste];
}

// --- Top Products Report ---
class TopProductReportItem extends Equatable {
  final int itemId;
  final String totalSold;

  const TopProductReportItem({
    required this.itemId,
    required this.totalSold,
  });

  factory TopProductReportItem.fromJson(Map<String, dynamic> json) {
    return TopProductReportItem(
      itemId: int.parse(json['item_id'].toString()),
      totalSold: json['total_sold'].toString(),
    );
  }

  @override
  List<Object?> get props => [itemId, totalSold];
}
