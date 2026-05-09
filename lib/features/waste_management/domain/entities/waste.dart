import 'package:equatable/equatable.dart';

class WasteItem extends Equatable {
  final int id;
  final int wasteId;
  final int itemId;
  final String quantity;
  final String? unitCost;
  final String? totalCost;
  final String? createdAt;
  final String? updatedAt;

  const WasteItem({
    required this.id,
    required this.wasteId,
    required this.itemId,
    required this.quantity,
    this.unitCost,
    this.totalCost,
    this.createdAt,
    this.updatedAt,
  });

  factory WasteItem.fromJson(Map<String, dynamic> json) {
    return WasteItem(
      id: int.parse(json['id'].toString()),
      wasteId: int.parse(json['waste_id'].toString()),
      itemId: int.parse(json['item_id'].toString()),
      quantity: json['quantity'].toString(),
      unitCost: json['unit_cost']?.toString(),
      totalCost: json['total_cost']?.toString(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, wasteId, itemId, quantity];
}

class Waste extends Equatable {
  final int id;
  final String reason;
  final String? createdAt;
  final String? updatedAt;
  final List<WasteItem> items;

  const Waste({
    required this.id,
    required this.reason,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  factory Waste.fromJson(Map<String, dynamic> json) {
    return Waste(
      id: int.parse(json['id'].toString()),
      reason: json['reason'] as String,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => WasteItem.fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [id, reason, items];
}

class WasteItemInput {
  final int itemId;
  final double quantity;

  const WasteItemInput({
    required this.itemId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'quantity': quantity,
      };
}
