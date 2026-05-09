import 'package:equatable/equatable.dart';
import '../../../products/domain/entities/item.dart';
import '../../../purchase_orders/domain/entities/purchase_order.dart';

class GRNItem extends Equatable {
  final int id;
  final int grnId;
  final int itemId;
  final String receivedQuantity;
  final String? createdAt;
  final String? updatedAt;
  final Item? item;

  const GRNItem({
    required this.id,
    required this.grnId,
    required this.itemId,
    required this.receivedQuantity,
    this.createdAt,
    this.updatedAt,
    this.item,
  });

  factory GRNItem.fromJson(Map<String, dynamic> json) {
    return GRNItem(
      id: int.parse(json['id'].toString()),
      grnId: int.parse(json['grn_id'].toString()),
      itemId: int.parse(json['item_id'].toString()),
      receivedQuantity: json['received_quantity'].toString(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      item: json['item'] != null ? Item.fromJson(json['item']) : null,
    );
  }

  @override
  List<Object?> get props => [id, grnId, itemId, receivedQuantity, item];
}

class GRN extends Equatable {
  final int id;
  final int purchaseOrderId;
  final String? createdAt;
  final String? updatedAt;
  final int? itemsCount;
  final PurchaseOrder? purchaseOrder;
  final List<GRNItem> items;

  const GRN({
    required this.id,
    required this.purchaseOrderId,
    this.createdAt,
    this.updatedAt,
    this.itemsCount,
    this.purchaseOrder,
    this.items = const [],
  });

  factory GRN.fromJson(Map<String, dynamic> json) {
    return GRN(
      id: int.parse(json['id'].toString()),
      purchaseOrderId: int.parse(json['purchase_order_id'].toString()),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      itemsCount: json['items_count'] != null ? int.parse(json['items_count'].toString()) : null,
      purchaseOrder: json['purchase_order'] != null ? PurchaseOrder.fromJson(json['purchase_order']) : null,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => GRNItem.fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id, purchaseOrderId, createdAt, updatedAt, itemsCount, purchaseOrder, items];
}

class GRNItemInput {
  final int itemId;
  final double receivedQuantity;

  const GRNItemInput({
    required this.itemId,
    required this.receivedQuantity,
  });

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'received_quantity': receivedQuantity,
      };
}
