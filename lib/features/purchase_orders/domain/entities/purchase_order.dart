import 'package:equatable/equatable.dart';

class PurchaseOrderItem extends Equatable {
  final int id;
  final int purchaseOrderId;
  final int itemId;
  final String quantity;
  final String price;
  final String total;
  final String? createdAt;
  final String? updatedAt;

  const PurchaseOrderItem({
    required this.id,
    required this.purchaseOrderId,
    required this.itemId,
    required this.quantity,
    required this.price,
    required this.total,
    this.createdAt,
    this.updatedAt,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      id: int.parse(json['id'].toString()),
      purchaseOrderId: int.parse(json['purchase_order_id'].toString()),
      itemId: int.parse(json['item_id'].toString()),
      quantity: json['quantity'].toString(),
      price: json['price'].toString(),
      total: json['total'].toString(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'purchase_order_id': purchaseOrderId,
        'item_id': itemId,
        'quantity': quantity,
        'price': price,
        'total': total,
      };

  @override
  List<Object?> get props => [id, purchaseOrderId, itemId, quantity, price, total];
}

class PurchaseOrder extends Equatable {
  final int id;
  final int supplierId;
  final String status;
  final List<PurchaseOrderItem> items;
  final String? createdAt;
  final String? updatedAt;

  const PurchaseOrder({
    required this.id,
    required this.supplierId,
    required this.status,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: int.parse(json['id'].toString()),
      supplierId: int.parse(json['supplier_id'].toString()),
      status: (json['status'] ?? 'pending').toString(),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => PurchaseOrderItem.fromJson(e))
              .toList() ??
          [],
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, supplierId, status, items, createdAt, updatedAt];
}

class PurchaseOrderItemInput {
  final int itemId;
  final double quantity;
  final double price;

  const PurchaseOrderItemInput({
    required this.itemId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'quantity': quantity,
        'price': price,
      };
}
