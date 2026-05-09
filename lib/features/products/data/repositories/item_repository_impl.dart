import 'dart:io';
import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';

class ItemRepositoryImpl implements ItemRepository {
  final DioClient _dioClient;

  ItemRepositoryImpl(this._dioClient);

  @override
  Future<List<Item>> getItems({int page = 1}) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.items,
        queryParameters: {'page': page},
      );
      final data = response.data['data']['data'] as List;
      return data.map((json) => Item.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل جلب العناصر');
    }
  }

  @override
  Future<Item> createItem({
    required String name,
    required int categoryId,
    required int unitId,
    required String type,
    File? image,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'category_id': categoryId,
        'unit_id': unitId,
        'type': type,
        if (image != null) 'image': await MultipartFile.fromFile(image.path),
      });

      final response = await _dioClient.dio.post(
        ApiConstants.items,
        data: formData,
      );
      return Item.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل إضافة العنصر');
    }
  }

  @override
  Future<Item> updateItem(
    int id, {
    required String name,
    required int categoryId,
    required int unitId,
    required String type,
    File? image,
  }) async {
    try {
      // NOTE: In Laravel/PHP, PUT requests with multipart/form-data can be tricky.
      // Often you need to use POST and append `_method=PUT` inside the body.
      // Assuming standard PUT for now, but added `_method` just in case since we are using formData.
      final formData = FormData.fromMap({
        '_method': 'PUT',
        'name': name,
        'category_id': categoryId,
        'unit_id': unitId,
        'type': type,
        if (image != null) 'image': await MultipartFile.fromFile(image.path),
      });

      final response = await _dioClient.dio.post(
        '${ApiConstants.items}/$id',
        data: formData,
      );
      return Item.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل تحديث العنصر');
    }
  }

  @override
  Future<void> deleteItem(int id) async {
    try {
      await _dioClient.dio.delete('${ApiConstants.items}/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل حذف العنصر');
    }
  }
}
