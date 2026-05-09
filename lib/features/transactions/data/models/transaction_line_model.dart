import '../../domain/entities/transaction_line.dart';

class TransactionLineModel extends TransactionLine {
  const TransactionLineModel({
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.unitOfMeasure,
    super.unitPrice,
    super.totalPrice,
    super.batchNumber,
    super.expiryDate,
    super.metadata = const {},
  });

  factory TransactionLineModel.fromEntity(TransactionLine entity) {
    return TransactionLineModel(
      productId: entity.productId,
      productName: entity.productName,
      quantity: entity.quantity,
      unitOfMeasure: entity.unitOfMeasure,
      unitPrice: entity.unitPrice,
      totalPrice: entity.totalPrice,
      batchNumber: entity.batchNumber,
      expiryDate: entity.expiryDate,
      metadata: entity.metadata,
    );
  }

  factory TransactionLineModel.fromJson(Map<String, Object?> json) {
    return TransactionLineModel(
      productId: json['productId']! as String,
      productName: json['productName']! as String,
      quantity: (json['quantity']! as num).toDouble(),
      unitOfMeasure: json['unitOfMeasure']! as String,
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      batchNumber: json['batchNumber'] as String?,
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate']! as String),
      metadata: (json['metadata'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value),
          ) ??
          const {},
    );
  }

  Map<String, Object?> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice ?? ((unitPrice ?? 0) * quantity),
      'unitOfMeasure': unitOfMeasure,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'metadata': metadata,
    };
  }
}
