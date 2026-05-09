import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int categoryId;
  final int unitId;
  final String type;
  final String? image;
  final String? createdAt;
  final String? updatedAt;

  const Item({
    required this.id,
    required this.name,
    this.description,
    required this.categoryId,
    required this.unitId,
    required this.type,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      categoryId: int.parse(json['category_id'].toString()),
      unitId: int.parse(json['unit_id'].toString()),
      type: json['type'] as String,
      image: json['image'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'unit_id': unitId,
      'type': type,
      'image': image,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        categoryId,
        unitId,
        type,
        image,
        createdAt,
        updatedAt,
      ];
}
