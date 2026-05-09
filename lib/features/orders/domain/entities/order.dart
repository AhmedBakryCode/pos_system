import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final int id;
  final int orderId;
  final int itemId;
  final String quantity;
  final String sellingPrice;
  final String total;
  final String? unitCost;
  final String? totalCost;
  final String? profit;
  final String? createdAt;
  final String? updatedAt;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.itemId,
    required this.quantity,
    required this.sellingPrice,
    required this.total,
    this.unitCost,
    this.totalCost,
    this.profit,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: int.parse(json['id'].toString()),
      orderId: int.parse(json['order_id'].toString()),
      itemId: int.parse(json['item_id'].toString()),
      quantity: json['quantity'].toString(),
      sellingPrice: json['selling_price'].toString(),
      total: json['total'].toString(),
      unitCost: json['unit_cost']?.toString(),
      totalCost: json['total_cost']?.toString(),
      profit: json['profit']?.toString(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, orderId, itemId, quantity, sellingPrice, total];
}

class SalesOrder extends Equatable {
  final int id;
  final String total;
  final String? totalCost;
  final String? profit;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final List<OrderItem> items;

  const SalesOrder({
    required this.id,
    required this.total,
    this.totalCost,
    this.profit,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  factory SalesOrder.fromJson(Map<String, dynamic> json) {
    return SalesOrder(
      id: int.parse(json['id'].toString()),
      total: json['total'].toString(),
      totalCost: json['total_cost']?.toString(),
      profit: json['profit']?.toString(),
      status: json['status'] as String,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id, total, status, items];
}

class OrderItemInput {
  final int itemId;
  final double quantity;
  final double sellingPrice;

  const OrderItemInput({
    required this.itemId,
    required this.quantity,
    required this.sellingPrice,
  });

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'quantity': quantity,
        'selling_price': sellingPrice,
      };
}
