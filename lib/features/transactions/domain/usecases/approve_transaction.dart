import '../entities/transaction_header.dart';
import '../repositories/transaction_repository.dart';

class ApproveTransaction {
  const ApproveTransaction(this._repository);

  final TransactionRepository _repository;

  Future<TransactionHeader> call(String transactionId) {
    return _repository.approveTransaction(transactionId);
  }
}
