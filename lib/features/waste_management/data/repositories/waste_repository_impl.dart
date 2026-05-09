import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/waste.dart';
import '../../domain/repositories/waste_repository.dart';

class WasteRepositoryImpl implements WasteRepository {
  final DioClient _dioClient;

  WasteRepositoryImpl(this._dioClient);

  @override
  Future<List<Waste>> getWastes({int page = 1}) async {
    try {
      final response = await _dioClient.getPaginated(ApiConstants.wastes);
      final data = response.data['data']['data'] as List;
      return data.map((json) => Waste.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل جلب الهالك');
    }
  }

  @override
  Future<Waste> createWaste({
    required String reason,
    required List<WasteItemInput> items,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.wastes,
        data: {
          'reason': reason,
          'items': items.map((i) => i.toJson()).toList(),
        },
      );
      return Waste.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل تسجيل الهالك');
    }
  }

  @override
  Future<Waste> updateWaste(
    int id, {
    required String reason,
    required List<WasteItemInput> items,
  }) async {
    try {
      final response = await _dioClient.dio.put(
        '${ApiConstants.wastes}/$id',
        data: {
          'reason': reason,
          'items': items.map((i) => i.toJson()).toList(),
        },
      );
      return Waste.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل تحديث الهالك');
    }
  }

  @override
  Future<void> deleteWaste(int id) async {
    try {
      await _dioClient.dio.delete('${ApiConstants.wastes}/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'فشل حذف الهالك');
    }
  }
}
