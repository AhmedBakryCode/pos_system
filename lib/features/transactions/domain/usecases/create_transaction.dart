import '../entities/transaction_header.dart';
import '../repositories/transaction_repository.dart';

class CreateTransaction {
  const CreateTransaction(this._repository);

  final TransactionRepository _repository;

  Future<TransactionHeader> call(TransactionHeader transaction) {
    return _repository.createTransaction(transaction);
  }
}
