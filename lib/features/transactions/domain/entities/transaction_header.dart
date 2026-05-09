import 'package:equatable/equatable.dart';

import 'transaction_line.dart';
import 'transaction_status.dart';
import 'transaction_type.dart';

class TransactionHeader extends Equatable {
  const TransactionHeader({
    required this.transactionId,
    required this.transactionType,
    required this.status,
    required this.warehouseId,
    required this.branchId,
    required this.createdAt,
    required this.createdBy,
    required this.referenceNumber,
    required this.lines,
    this.notes,
  });

  final String transactionId;
  final TransactionType transactionType;
  final TransactionStatus status;
  final String warehouseId;
  final String branchId;
  final DateTime createdAt;
  final String createdBy;
  final String? notes;
  final String referenceNumber;
  final List<TransactionLine> lines;

  double get totalQuantity => lines.fold(0, (sum, line) => sum + line.quantity);

  double get totalAmount => lines.fold(
    0,
    (sum, line) => sum + (line.totalPrice ?? (line.unitPrice ?? 0) * line.quantity),
  );

  TransactionHeader copyWith({
    String? transactionId,
    TransactionType? transactionType,
    TransactionStatus? status,
    String? warehouseId,
    String? branchId,
    DateTime? createdAt,
    String? createdBy,
    String? notes,
    String? referenceNumber,
    List<TransactionLine>? lines,
  }) {
    return TransactionHeader(
      transactionId: transactionId ?? this.transactionId,
      transactionType: transactionType ?? this.transactionType,
      status: status ?? this.status,
      warehouseId: warehouseId ?? this.warehouseId,
      branchId: branchId ?? this.branchId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      notes: notes ?? this.notes,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      lines: lines ?? this.lines,
    );
  }

  @override
  List<Object?> get props => [
    transactionId,
    transactionType,
    status,
    warehouseId,
    branchId,
    createdAt,
    createdBy,
    notes,
    referenceNumber,
    lines,
  ];
}
