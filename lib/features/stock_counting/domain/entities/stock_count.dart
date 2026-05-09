import 'package:equatable/equatable.dart';

class StockCountItem extends Equatable {
  final int id;
  final int stockCountId;
  final int itemId;
  final String systemQuantity;
  final String actualQuantity;
  final String difference;
  final String unitCost;
  final String totalCost;
  final String? createdAt;
  final String? updatedAt;

  const StockCountItem({
    required this.id,
    required this.stockCountId,
    required this.itemId,
    required this.systemQuantity,
    required this.actualQuantity,
    required this.difference,
    required this.unitCost,
    required this.totalCost,
    this.createdAt,
    this.updatedAt,
  });

  factory StockCountItem.fromJson(Map<String, dynamic> json) {
    return StockCountItem(
      id: int.parse(json['id'].toString()),
      stockCountId: int.parse(json['stock_count_id'].toString()),
      itemId: int.parse(json['item_id'].toString()),
      systemQuantity: json['system_quantity'].toString(),
      actualQuantity: json['actual_quantity'].toString(),
      difference: json['difference'].toString(),
      unitCost: json['unit_cost'].toString(),
      totalCost: json['total_cost'].toString(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, stockCountId, itemId, systemQuantity, actualQuantity, difference];
}

class StockCount extends Equatable {
  final int id;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final List<StockCountItem> items;

  const StockCount({
    required this.id,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  factory StockCount.fromJson(Map<String, dynamic> json) {
    return StockCount(
      id: int.parse(json['id'].toString()),
      status: json['status'] as String,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => StockCountItem.fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id, status, items];
}

class StockCountItemInput {
  final int itemId;
  final double actualQuantity;

  const StockCountItemInput({
    required this.itemId,
    required this.actualQuantity,
  });

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'actual_quantity': actualQuantity,
      };
}
