import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';

enum OrderStatus { initial, loading, loaded, error }

class OrderState extends Equatable {
  final OrderStatus status;
  final List<SalesOrder> orders;
  final String? errorMessage;
  final int currentPage;

  const OrderState({
    this.status = OrderStatus.initial,
    this.orders = const [],
    this.errorMessage,
    this.currentPage = 1,
  });

  OrderState copyWith({
    OrderStatus? status,
    List<SalesOrder>? orders,
    String? errorMessage,
    int? currentPage,
  }) {
    return OrderState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [status, orders, errorMessage, currentPage];
}
