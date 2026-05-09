import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _repository;

  OrderCubit(this._repository) : super(const OrderState());

  Future<void> loadOrders({int page = 1, bool refresh = false}) async {
    if (state.status == OrderStatus.loading) return;

    emit(state.copyWith(
      status: OrderStatus.loading,
      currentPage: page,
      orders: refresh ? [] : state.orders,
    ));

    try {
      final newOrders = await _repository.getOrders(page: page);
      final allOrders = refresh ? newOrders : [...state.orders, ...newOrders];

      emit(state.copyWith(
        status: OrderStatus.loaded,
        orders: allOrders,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> createOrder({
    required List<OrderItemInput> items,
  }) async {
    try {
      final order = await _repository.createOrder(
        items: items,
      );
      emit(state.copyWith(
        orders: [order, ...state.orders],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: OrderStatus.loaded, errorMessage: null));
      rethrow;
    }
  }

  Future<void> deleteOrder(int id) async {
    try {
      await _repository.deleteOrder(id);
      emit(state.copyWith(
        orders: state.orders.where((o) => o.id != id).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: OrderStatus.loaded, errorMessage: null));
      rethrow;
    }
  }
}
