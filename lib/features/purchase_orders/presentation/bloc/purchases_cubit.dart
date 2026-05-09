import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/purchase_order.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/purchases_repository.dart';
import 'purchases_state.dart';

class PurchasesCubit extends Cubit<PurchasesState> {
  final PurchasesRepository _repository;

  PurchasesCubit(this._repository) : super(const PurchasesState());

  Future<void> loadAll({bool refresh = false}) async {
    if (state.status == PurchasesStatus.loading) return;

    emit(state.copyWith(
      status: PurchasesStatus.loading,
      orders: refresh ? [] : state.orders,
    ));

    try {
      final results = await Future.wait([
        _repository.getPurchaseOrders(),
        _repository.getSuppliers(),
      ]);

      emit(state.copyWith(
        status: PurchasesStatus.loaded,
        orders: results[0] as List<PurchaseOrder>,
        suppliers: results[1] as List<Supplier>,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PurchasesStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> createOrder({
    required int supplierId,
    required List<PurchaseOrderItemInput> items,
  }) async {
    try {
      final order = await _repository.createPurchaseOrder(
        supplierId: supplierId,
        items: items,
      );
      emit(state.copyWith(orders: [order, ...state.orders]));
    } catch (e) {
      emit(state.copyWith(
        status: PurchasesStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: PurchasesStatus.loaded, errorMessage: null));
      rethrow;
    }
  }

  Future<void> updateOrder(
    int id, {
    required int supplierId,
    required List<PurchaseOrderItemInput> items,
  }) async {
    try {
      final updated = await _repository.updatePurchaseOrder(
        id,
        supplierId: supplierId,
        items: items,
      );
      final index = state.orders.indexWhere((o) => o.id == id);
      if (index != -1) {
        final newOrders = List.of(state.orders);
        newOrders[index] = updated;
        emit(state.copyWith(orders: newOrders));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PurchasesStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: PurchasesStatus.loaded, errorMessage: null));
      rethrow;
    }
  }

  Future<void> deleteOrder(int id) async {
    try {
      await _repository.deletePurchaseOrder(id);
      emit(state.copyWith(
        orders: state.orders.where((o) => o.id != id).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PurchasesStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: PurchasesStatus.loaded, errorMessage: null));
      rethrow;
    }
  }
}
