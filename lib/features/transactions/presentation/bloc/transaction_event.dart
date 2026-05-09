import '../../domain/entities/transaction_header.dart';
import '../../domain/entities/transaction_line.dart';
import '../../domain/entities/transaction_type.dart';

sealed class TransactionEvent {
  const TransactionEvent();
}

class LoadTransaction extends TransactionEvent {
  const LoadTransaction(this.transactionId);

  final String transactionId;
}

class InitializeTransaction extends TransactionEvent {
  const InitializeTransaction({this.transactionType});

  final TransactionType? transactionType;
}

class AddLine extends TransactionEvent {
  const AddLine(this.line);

  final TransactionLine line;
}

class RemoveLine extends TransactionEvent {
  const RemoveLine(this.productId);

  final String productId;
}

class UpdateLineQuantity extends TransactionEvent {
  const UpdateLineQuantity({
    required this.productId,
    required this.quantity,
  });

  final String productId;
  final double quantity;
}

class UpdateHeaderFields extends TransactionEvent {
  const UpdateHeaderFields({
    this.transactionType,
    this.warehouseId,
    this.branchId,
    this.notes,
  });

  final TransactionType? transactionType;
  final String? warehouseId;
  final String? branchId;
  final String? notes;
}

class SaveTransaction extends TransactionEvent {
  const SaveTransaction();
}

class ApproveTransactionRequested extends TransactionEvent {
  const ApproveTransactionRequested();
}

class PostTransactionRequested extends TransactionEvent {
  const PostTransactionRequested();
}

class ReplaceTransaction extends TransactionEvent {
  const ReplaceTransaction(this.transaction);

  final TransactionHeader transaction;
}
