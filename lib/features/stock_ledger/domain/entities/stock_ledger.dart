import 'package:equatable/equatable.dart';

enum StockMovementType {
  purchase('شراء'),
  sale('بيع'),
  adjustmentIncrease('زيادة تسوية'),
  adjustmentDecrease('نقص تسوية'),
  productionInput('دخول إنتاج'),
  productionOutput('خروج إنتاج'),
  waste('هالك'),
  return_('إرجاع');

  const StockMovementType(this.label);
  final String label;

  String get value {
    switch (this) {
      case StockMovementType.purchase:
        return 'purchase';
      case StockMovementType.sale:
        return 'sale';
      case StockMovementType.adjustmentIncrease:
        return 'adjustment_increase';
      case StockMovementType.adjustmentDecrease:
        return 'adjustment_decrease';
      case StockMovementType.productionInput:
        return 'production_input';
      case StockMovementType.productionOutput:
        return 'production_output';
      case StockMovementType.waste:
        return 'waste';
      case StockMovementType.return_:
        return 'return';
    }
  }

  static StockMovementType fromString(String value) {
    switch (value) {
      case 'purchase':
        return StockMovementType.purchase;
      case 'sale':
        return StockMovementType.sale;
      case 'adjustment_increase':
        return StockMovementType.adjustmentIncrease;
      case 'adjustment_decrease':
        return StockMovementType.adjustmentDecrease;
      case 'production_input':
        return StockMovementType.productionInput;
      case 'production_output':
        return StockMovementType.productionOutput;
      case 'waste':
        return StockMovementType.waste;
      case 'return':
        return StockMovementType.return_;
      default:
        return StockMovementType.adjustmentIncrease;
    }
  }
}

class StockLedgerEntry extends Equatable {
  const StockLedgerEntry({
    required this.id,
    required this.productId,
    required this.productName,
    required this.movementType,
    required this.quantity,
    required this.balanceAfter,
    required this.date,
    this.reference,
    this.notes,
  });

  final String id;
  final String productId;
  final String productName;
  final StockMovementType movementType;
  final double quantity;
  final double balanceAfter;
  final DateTime date;
  final String? reference;
  final String? notes;

  Map<String, dynamic> toMap() => {
        'id': id,
        'product_id': productId,
        'product_name': productName,
        'movement_type': movementType.value,
        'quantity': quantity,
        'balance_after': balanceAfter,
        'date': date.toIso8601String(),
        'reference': reference,
        'notes': notes,
      };

  factory StockLedgerEntry.fromMap(Map<String, dynamic> map) => StockLedgerEntry(
        id: map['id'] as String,
        productId: map['product_id'] as String,
        productName: map['product_name'] as String,
        movementType: StockMovementType.fromString(map['movement_type'] as String),
        quantity: (map['quantity'] as num).toDouble(),
        balanceAfter: (map['balance_after'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        reference: map['reference'] as String?,
        notes: map['notes'] as String?,
      );

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        movementType,
        quantity,
        balanceAfter,
        date,
        reference,
        notes,
      ];
}