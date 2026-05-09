import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/production.dart';
import '../../domain/repositories/production_repository.dart';

class ProductionRepositoryImpl implements ProductionRepository {
  final DioClient _dioClient;

  ProductionRepositoryImpl(this._dioClient);

  @override
  Future<List<Production>> getProductions({int page = 1}) async {
    try {
      final response = await _dioClient.getPaginated(ApiConstants.productions);
      final data = response.data['data']['data'] as List;
      return data.map((json) => Production.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل جلب أوامر الإنتاج');
    }
  }

  @override
  Future<Production> createProduction({
    required int recipeId,
    required double quantity,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.productions,
        data: {
          'recipe_id': recipeId,
          'quantity': quantity,
        },
      );
      return Production.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل إنشاء أمر الإنتاج');
    }
  }

  @override
  Future<Production> updateProduction(
    int id, {
    required int recipeId,
    required double quantity,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.productions}/$id',
        data: {
          'recipe_id': recipeId,
          'quantity': quantity,
        },
      );
      return Production.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل تحديث أمر الإنتاج');
    }
  }

  @override
  Future<void> executeProduction(int id) async {
    try {
      await _dioClient.dio.post('${ApiConstants.productions}/$id/execute');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل تنفيذ أمر الإنتاج');
    }
  }

  @override
  Future<void> deleteProduction(int id) async {
    try {
      await _dioClient.dio.delete('${ApiConstants.productions}/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل حذف أمر الإنتاج');
    }
  }
}
