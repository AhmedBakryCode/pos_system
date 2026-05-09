import 'package:flutter_bloc/flutter_bloc.dart';


import '../../domain/repositories/purchases_repository.dart';
import 'suppliers_state.dart';

class SuppliersCubit extends Cubit<SuppliersState> {
  final PurchasesRepository _repository;

  SuppliersCubit(this._repository) : super(const SuppliersState());

  Future<void> loadSuppliers({int page = 1, bool refresh = false}) async {
    if (state.status == SuppliersStatus.loading) return;

    emit(state.copyWith(
      status: SuppliersStatus.loading,
      currentPage: page,
      suppliers: refresh ? [] : state.suppliers,
    ));

    try {
      final newSuppliers = await _repository.getSuppliers(page: page);
      final allSuppliers = refresh ? newSuppliers : [...state.suppliers, ...newSuppliers];

      emit(state.copyWith(
        status: SuppliersStatus.loaded,
        suppliers: allSuppliers,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SuppliersStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> createSupplier({
    required String fname,
    required String lname,
    required String email,
    required String phone,
    required String address,
  }) async {
    try {
      final supplier = await _repository.createSupplier(
        fname: fname,
        lname: lname,
        email: email,
        phone: phone,
        address: address,
      );
      emit(state.copyWith(
        suppliers: [supplier, ...state.suppliers],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SuppliersStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: SuppliersStatus.loaded, errorMessage: null));
      rethrow;
    }
  }

  Future<void> updateSupplier(
    int id, {
    required String fname,
    required String lname,
    required String email,
    required String phone,
    required String address,
  }) async {
    try {
      final updated = await _repository.updateSupplier(
        id,
        fname: fname,
        lname: lname,
        email: email,
        phone: phone,
        address: address,
      );
      final index = state.suppliers.indexWhere((s) => s.id == id);
      if (index != -1) {
        final newSuppliers = List.of(state.suppliers);
        newSuppliers[index] = updated;
        emit(state.copyWith(suppliers: newSuppliers));
      }
    } catch (e) {
      emit(state.copyWith(
        status: SuppliersStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: SuppliersStatus.loaded, errorMessage: null));
      rethrow;
    }
  }

  Future<void> deleteSupplier(int id) async {
    try {
      await _repository.deleteSupplier(id);
      emit(state.copyWith(
        suppliers: state.suppliers.where((s) => s.id != id).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SuppliersStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: SuppliersStatus.loaded, errorMessage: null));
      rethrow;
    }
  }
}
