import 'package:equatable/equatable.dart';

import '../../domain/entities/transaction_header.dart';

enum TransactionViewStatus {
  loading,
  loaded,
  editing,
  saved,
  error,
}

class TransactionState extends Equatable {
  const TransactionState({
    required this.status,
    this.transaction,
    this.errorMessage,
  });

  const TransactionState.loading()
    : this(status: TransactionViewStatus.loading);

  const TransactionState.loaded(TransactionHeader transaction)
    : this(status: TransactionViewStatus.loaded, transaction: transaction);

  const TransactionState.editing(TransactionHeader transaction)
    : this(status: TransactionViewStatus.editing, transaction: transaction);

  const TransactionState.saved(TransactionHeader transaction)
    : this(status: TransactionViewStatus.saved, transaction: transaction);

  const TransactionState.error(String message, {TransactionHeader? transaction})
    : this(
        status: TransactionViewStatus.error,
        transaction: transaction,
        errorMessage: message,
      );

  final TransactionViewStatus status;
  final TransactionHeader? transaction;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, transaction, errorMessage];
}
