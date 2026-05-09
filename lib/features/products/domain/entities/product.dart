import 'package:equatable/equatable.dart';

class ProductCategory extends Equatable {
  const ProductCategory({
    required this.id,
    required this.name,
    this.description,
  });

  final String id;
  final String name;
  final String? description;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
      };

  factory ProductCategory.fromMap(Map<String, dynamic> map) => ProductCategory(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
      );

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

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'contact_person': contactPerson,
        'phone': phone,
        'email': email,
        'address': address,
      };

  factory Supplier.fromMap(Map<String, dynamic> map) => Supplier(
        id: map['id'] as String,
        name: map['name'] as String,
        contactPerson: map['contact_person'] as String?,
        phone: map['phone'] as String?,
        email: map['email'] as String?,
        address: map['address'] as String?,
      );

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

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'sku': sku,
        'barcode': barcode,
        'additional_price': additionalPrice,
      };

  factory ProductVariant.fromMap(Map<String, dynamic> map) => ProductVariant(
        id: map['id'] as String,
        name: map['name'] as String,
        sku: map['sku'] as String?,
        barcode: map['barcode'] as String?,
        additionalPrice: (map['additional_price'] as num?)?.toDouble(),
      );

  @override
  List<Object?> get props => [id, name, sku, barcode, additionalPrice];
}

enum ProductType {
  rawMaterial('مادة خام'),
  finishedProduct('منتج مصنع');

  const ProductType(this.label);
  final String label;

  String get value {
    switch (this) {
      case ProductType.rawMaterial:
        return 'raw_material';
      case ProductType.finishedProduct:
        return 'finished_product';
    }
  }

  static ProductType fromString(String value) {
    switch (value) {
      case 'raw_material':
        return ProductType.rawMaterial;
      case 'finished_product':
        return ProductType.finishedProduct;
      default:
        return ProductType.finishedProduct;
    }
  }
}

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.availableQuantity,
    required this.type,
    required this.unitOfMeasure,
    this.categoryId,
    this.sku,
    this.barcode,
    this.imageUrl,
    this.description,
    this.supplierId,
    this.reorderPoint,
    this.costPrice,
    this.variants,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final double unitPrice;
  final double availableQuantity;
  final ProductType type;
  final String unitOfMeasure;
  final String? categoryId;
  final String? sku;
  final String? barcode;
  final String? imageUrl;
  final String? description;
  final String? supplierId;
  final double? reorderPoint;
  final double? costPrice;
  final List<ProductVariant>? variants;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isLowStock => reorderPoint != null && availableQuantity < reorderPoint!;

  Product copyWith({
    String? id,
    String? name,
    double? unitPrice,
    double? availableQuantity,
    ProductType? type,
    String? unitOfMeasure,
    String? categoryId,
    String? sku,
    String? barcode,
    String? imageUrl,
    String? description,
    String? supplierId,
    double? reorderPoint,
    double? costPrice,
    List<ProductVariant>? variants,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      unitPrice: unitPrice ?? this.unitPrice,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      type: type ?? this.type,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      categoryId: categoryId ?? this.categoryId,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      supplierId: supplierId ?? this.supplierId,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      costPrice: costPrice ?? this.costPrice,
      variants: variants ?? this.variants,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'unit_price': unitPrice,
        'available_quantity': availableQuantity,
        'type': type.value,
        'unit_of_measure': unitOfMeasure,
        'category_id': categoryId,
        'sku': sku,
        'barcode': barcode,
        'image_url': imageUrl,
        'description': description,
        'supplier_id': supplierId,
        'reorder_point': reorderPoint,
        'cost_price': costPrice,
        'is_active': isActive ?? true ? 1 : 0,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'] as String,
        name: map['name'] as String,
        unitPrice: (map['unit_price'] as num).toDouble(),
        availableQuantity: (map['available_quantity'] as num).toDouble(),
        type: ProductType.fromString(map['type'] as String),
        unitOfMeasure: map['unit_of_measure'] as String,
        categoryId: map['category_id'] as String?,
        sku: map['sku'] as String?,
        barcode: map['barcode'] as String?,
        imageUrl: map['image_url'] as String?,
        description: map['description'] as String?,
        supplierId: map['supplier_id'] as String?,
        reorderPoint: (map['reorder_point'] as num?)?.toDouble(),
        costPrice: (map['cost_price'] as num?)?.toDouble(),
        isActive: map['is_active'] == 1,
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'] as String)
            : null,
        updatedAt: map['updated_at'] != null
            ? DateTime.parse(map['updated_at'] as String)
            : null,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        unitPrice,
        availableQuantity,
        type,
        unitOfMeasure,
        categoryId,
        sku,
        barcode,
        imageUrl,
        description,
        supplierId,
        reorderPoint,
        costPrice,
        variants,
        isActive,
      ];
}