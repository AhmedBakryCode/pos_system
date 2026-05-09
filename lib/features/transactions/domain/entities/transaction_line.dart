import 'package:equatable/equatable.dart';

class TransactionLine extends Equatable {
  const TransactionLine({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitOfMeasure,
    this.unitPrice,
    this.totalPrice,
    this.batchNumber,
    this.expiryDate,
    this.metadata = const {},
  });

  final String productId;
  final String productName;
  final double quantity;
  final double? unitPrice;
  final double? totalPrice;
  final String unitOfMeasure;
  final String? batchNumber;
  final DateTime? expiryDate;
  final Map<String, Object?> metadata;

  TransactionLine copyWith({
    String? productId,
    String? productName,
    double? quantity,
    double? unitPrice,
    double? totalPrice,
    String? unitOfMeasure,
    String? batchNumber,
    DateTime? expiryDate,
    Map<String, Object?>? metadata,
  }) {
    return TransactionLine(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    productId,
    productName,
    quantity,
    unitPrice,
    totalPrice,
    unitOfMeasure,
    batchNumber,
    expiryDate,
    metadata,
  ];
}
