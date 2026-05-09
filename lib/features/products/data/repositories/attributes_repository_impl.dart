import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/unit.dart';
import '../../domain/repositories/attributes_repository.dart';

class AttributesRepositoryImpl implements AttributesRepository {
  final DioClient _dioClient;

  AttributesRepositoryImpl(this._dioClient);

  // --- Units ---
  @override
  Future<List<Unit>> getUnits({int page = 1}) async {
    try {
      final response = await _dioClient.getPaginated(ApiConstants.units);
      final data = response.data['data']['data'] as List;
      return data.map((json) => Unit.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل جلب الوحدات');
    }
  }

  @override
  Future<Unit> createUnit({required String name, required String description}) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.units,
        data: {'name': name, 'description': description},
      );
      return Unit.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل إضافة الوحدة');
    }
  }

  @override
  Future<Unit> updateUnit(int id, {required String name, required String description}) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.units}/$id',
        data: {'name': name, 'description': description},
      );
      return Unit.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل تحديث الوحدة');
    }
  }

  @override
  Future<void> deleteUnit(int id) async {
    try {
      await _dioClient.dio.delete('${ApiConstants.units}/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل حذف الوحدة');
    }
  }

  // --- Categories ---
  @override
  Future<List<Category>> getCategories({int page = 1}) async {
    try {
      final response = await _dioClient.getPaginated(ApiConstants.categories);
      final data = response.data['data']['data'] as List;
      return data.map((json) => Category.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل جلب الفئات');
    }
  }

  @override
  Future<Category> createCategory({required String name, required String description}) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.categories,
        data: {'name': name, 'description': description},
      );
      return Category.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل إضافة الفئة');
    }
  }

  @override
  Future<Category> updateCategory(int id, {required String name, required String description}) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.categories}/$id',
        data: {'name': name, 'description': description},
      );
      return Category.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل تحديث الفئة');
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      await _dioClient.dio.delete('${ApiConstants.categories}/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل حذف الفئة');
    }
  }
}
