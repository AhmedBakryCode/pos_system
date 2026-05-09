import '../../domain/entities/transaction_header.dart';
import '../../domain/entities/transaction_status.dart';
import '../../domain/entities/transaction_type.dart';
import 'transaction_line_model.dart';

class TransactionHeaderModel extends TransactionHeader {
  const TransactionHeaderModel({
    required super.transactionId,
    required super.transactionType,
    required super.status,
    required super.warehouseId,
    required super.branchId,
    required super.createdAt,
    required super.createdBy,
    required super.referenceNumber,
    required super.lines,
    super.notes,
  });

  factory TransactionHeaderModel.fromEntity(TransactionHeader entity) {
    return TransactionHeaderModel(
      transactionId: entity.transactionId,
      transactionType: entity.transactionType,
      status: entity.status,
      warehouseId: entity.warehouseId,
      branchId: entity.branchId,
      createdAt: entity.createdAt,
      createdBy: entity.createdBy,
      referenceNumber: entity.referenceNumber,
      notes: entity.notes,
      lines: entity.lines
          .map(TransactionLineModel.fromEntity)
          .toList(growable: false),
    );
  }

  factory TransactionHeaderModel.fromJson(Map<String, Object?> json) {
    return TransactionHeaderModel(
      transactionId: json['transactionId']! as String,
      transactionType: TransactionType.values.byName(
        json['transactionType']! as String,
      ),
      status: TransactionStatus.values.byName(json['status']! as String),
      warehouseId: json['warehouseId']! as String,
      branchId: json['branchId']! as String,
      createdAt: DateTime.parse(json['createdAt']! as String),
      createdBy: json['createdBy']! as String,
      notes: json['notes'] as String?,
      referenceNumber: json['referenceNumber']! as String,
      lines: (json['lines']! as List<Object?>)
          .map((line) => TransactionLineModel.fromJson(line! as Map<String, Object?>))
          .toList(growable: false),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'transactionId': transactionId,
      'transactionType': transactionType.name,
      'status': status.name,
      'warehouseId': warehouseId,
      'branchId': branchId,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'notes': notes,
      'referenceNumber': referenceNumber,
      'lines': lines
          .map((line) => TransactionLineModel.fromEntity(line).toJson())
          .toList(growable: false),
    };
  }
}
