import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/item_repository.dart';
import 'items_state.dart';

class ItemsCubit extends Cubit<ItemsState> {
  final ItemRepository _repository;

  ItemsCubit(this._repository) : super(const ItemsState());

  Future<void> loadItems({int page = 1, bool refresh = false}) async {
    if (state.status == ItemsStatus.loading) return;

    emit(state.copyWith(
      status: ItemsStatus.loading,
      currentPage: page,
      items: refresh ? [] : state.items,
    ));

    try {
      final newItems = await _repository.getItems(page: page);
      final allItems = refresh ? newItems : [...state.items, ...newItems];

      emit(state.copyWith(
        status: ItemsStatus.loaded,
        items: allItems,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ItemsStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> createItem({
    required String name,
    required int categoryId,
    required int unitId,
    required String type,
    File? image,
  }) async {
    try {
      final item = await _repository.createItem(
        name: name,
        categoryId: categoryId,
        unitId: unitId,
        type: type,
        image: image,
      );
      emit(state.copyWith(
        items: [item, ...state.items],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ItemsStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: ItemsStatus.loaded, errorMessage: null));
      rethrow;
    }
  }

  Future<void> updateItem(
    int id, {
    required String name,
    required int categoryId,
    required int unitId,
    required String type,
    File? image,
  }) async {
    try {
      final updatedItem = await _repository.updateItem(
        id,
        name: name,
        categoryId: categoryId,
        unitId: unitId,
        type: type,
        image: image,
      );
      final index = state.items.indexWhere((i) => i.id == id);
      if (index != -1) {
        final newItems = List.of(state.items);
        newItems[index] = updatedItem;
        emit(state.copyWith(items: newItems));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ItemsStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: ItemsStatus.loaded, errorMessage: null));
      rethrow;
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      await _repository.deleteItem(id);
      final newItems = state.items.where((i) => i.id != id).toList();
      emit(state.copyWith(items: newItems));
    } catch (e) {
      emit(state.copyWith(
        status: ItemsStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(state.copyWith(status: ItemsStatus.loaded, errorMessage: null));
      rethrow;
    }
  }
}
