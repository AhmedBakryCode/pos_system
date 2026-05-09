import 'package:equatable/equatable.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/entities/supplier.dart';

enum PurchasesStatus { initial, loading, loaded, error }

class PurchasesState extends Equatable {
  final PurchasesStatus status;
  final List<PurchaseOrder> orders;
  final List<Supplier> suppliers;
  final String? errorMessage;
  final int currentPage;

  const PurchasesState({
    this.status = PurchasesStatus.initial,
    this.orders = const [],
    this.suppliers = const [],
    this.errorMessage,
    this.currentPage = 1,
  });

  PurchasesState copyWith({
    PurchasesStatus? status,
    List<PurchaseOrder>? orders,
    List<Supplier>? suppliers,
    String? errorMessage,
    int? currentPage,
  }) {
    return PurchasesState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      suppliers: suppliers ?? this.suppliers,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [status, orders, suppliers, errorMessage, currentPage];
}
