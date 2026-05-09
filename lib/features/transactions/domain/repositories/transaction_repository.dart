import '../entities/transaction_header.dart';

abstract class TransactionRepository {
  Future<List<TransactionHeader>> listTransactions();
  Future<TransactionHeader> createTransaction(TransactionHeader transaction);
  Future<TransactionHeader> updateTransaction(TransactionHeader transaction);
  Future<TransactionHeader> approveTransaction(String transactionId);
  Future<TransactionHeader> postTransaction(String transactionId);
  Future<TransactionHeader> loadTransaction(String transactionId);
  Future<void> deleteTransaction(String transactionId);
}
