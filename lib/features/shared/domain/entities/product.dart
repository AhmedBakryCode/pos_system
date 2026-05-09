import 'package:equatable/equatable.dart';

enum ProductType {
  rawMaterial('مادة خام'),
  finishedProduct('منتج مصنع');

  const ProductType(this.label);
  final String label;
}

class ProductCategory extends Equatable {
  const ProductCategory({
    required this.id,
    required this.name,
    this.description,
  });

  final String id;
  final String name;
  final String? description;

  @override
  List<Object?> get props => [id, name, description];
}

class Supplier extends Equatable {
  const Supplier({
    required this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
  });

  final String id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;

  @override
  List<Object?> get props => [id, name, contactPerson, phone, email, address];
}

class ProductVariant extends Equatable {
  const ProductVariant({
    required this.id,
    required this.name,
    this.sku,
    this.barcode,
    this.additionalPrice,
  });

  final String id;
  final String name;
  final String? sku;
  final String? barcode;
  final double? additionalPrice;

  @override
  List<Object?> get props => [id, name, sku, barcode, additionalPrice];
}

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.availableQuantity,
    required this.type,
    required this.unitOfMeasure,
    this.category,
    this.sku,
    this.barcode,
    this.imageUrl,
    this.description,
    this.supplier,
    this.reorderPoint,
    this.variants,
    this.isActive,
  });

  final String id;
  final String name;
  final double unitPrice;
  final double availableQuantity;
  final ProductType type;
  final String unitOfMeasure;
  final ProductCategory? category;
  final String? sku;
  final String? barcode;
  final String? imageUrl;
  final String? description;
  final Supplier? supplier;
  final double? reorderPoint;
  final List<ProductVariant>? variants;
  final bool? isActive;

  bool get isLowStock => reorderPoint != null && availableQuantity < reorderPoint!;

  Product copyWith({
    String? id,
    String? name,
    double? unitPrice,
    double? availableQuantity,
    ProductType? type,
    String? unitOfMeasure,
    ProductCategory? category,
    String? sku,
    String? barcode,
    String? imageUrl,
    String? description,
    Supplier? supplier,
    double? reorderPoint,
    List<ProductVariant>? variants,
    bool? isActive,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      unitPrice: unitPrice ?? this.unitPrice,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      type: type ?? this.type,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      supplier: supplier ?? this.supplier,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      variants: variants ?? this.variants,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        unitPrice,
        availableQuantity,
        type,
        unitOfMeasure,
        category,
        sku,
        barcode,
        imageUrl,
        description,
        supplier,
        reorderPoint,
        variants,
        isActive,
      ];
}