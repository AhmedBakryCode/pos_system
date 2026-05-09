import 'dart:io';
import '../entities/item.dart';

abstract class ItemRepository {
  Future<List<Item>> getItems({int page = 1});
  
  Future<Item> createItem({
    required String name,
    required int categoryId,
    required int unitId,
    required String type,
    File? image,
  });

  Future<Item> updateItem(
    int id, {
    required String name,
    required int categoryId,
    required int unitId,
    required String type,
    File? image,
  });

  Future<void> deleteItem(int id);
}
