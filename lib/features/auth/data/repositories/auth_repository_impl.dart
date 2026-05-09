import 'package:dio/dio.dart';
import 'package:pos_system/core/network/api_constants.dart';
import 'package:pos_system/core/network/dio_client.dart';
import 'package:pos_system/core/services/shared_preferences_service.dart';
import 'package:pos_system/features/auth/domain/entities/user.dart';
import 'package:pos_system/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dioClient;
  final SharedPreferencesService _prefsService;

  AuthRepositoryImpl(this._dioClient, this._prefsService);

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final token = data['token'] as String;
        final userJson = data['user'] as Map<String, dynamic>;

        await _prefsService.saveToken(token);
        await _prefsService.saveUser(userJson);

        return User.fromJson(userJson);
      } else {
        throw Exception(response.data['message'] ?? 'فشل تسجيل الدخول');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'حدث خطأ أثناء تسجيل الدخول';
      throw Exception(message);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  @override
  Future<User?> refreshToken() async {
    final newToken = await _dioClient.refreshToken();
    if (newToken != null) {
      final userJson = _prefsService.getUser();
      return userJson != null ? User.fromJson(userJson) : null;
    }
    return null;
  }

  @override
  Future<void> logout() async {
    try {
      await _dioClient.dio.post(ApiConstants.logout);
    } catch (e) {
      // Even if API fails, we should clear local data
    } finally {
      await _prefsService.clearAuth();
    }
  }

  @override
  Future<User?> getCachedUser() async {
    final userJson = _prefsService.getUser();
    if (userJson != null) {
      return User.fromJson(userJson);
    }
    return null;
  }

  @override
  Future<User> getProfile() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.profile);
      if (response.statusCode == 200) {
        final userJson = response.data['data'] as Map<String, dynamic>;
        await _prefsService.saveUser(userJson);
        return User.fromJson(userJson);
      } else {
        throw Exception(
          response.data['message'] ?? 'فشل جلب بيانات الملف الشخصي',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'حدث خطأ أثناء جلب الملف الشخصي',
      );
    }
  }

  @override
  Future<User> updateProfile({
    required String address,
    required String email,
    required String fname,
    required String lname,
    required String phone,
    dynamic profileImage,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'fname': fname,
        'lname': lname,
        'email': email,
        'phone': phone,
        'address': address,
      };

      dynamic requestData;

      if (profileImage != null && profileImage is String && profileImage.isNotEmpty) {
        requestData = FormData.fromMap({
          ...data,
          'image': await MultipartFile.fromFile(profileImage),
        });
      } else {
        requestData = data;
      }

      final response = await _dioClient.dio.put(
        ApiConstants.profile,
        data: requestData,
      );

      if (response.statusCode == 200) {
        if (response.data['data'] is Map<String, dynamic>) {
          final userJson = response.data['data'] as Map<String, dynamic>;
          await _prefsService.saveUser(userJson);
          return User.fromJson(userJson);
        } else {
          // If the backend returns true but not the user object, fetch the latest profile
          return await getProfile();
        }
      } else {
        throw Exception(response.data['message'] ?? 'فشل تحديث الملف الشخصي');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'حدث خطأ أثناء تحديث الملف الشخصي',
      );
    }
  }

  // @override
  // Future<User> updateProfileImage(String filePath) async {
  //   try {
  //     final formData = FormData.fromMap({
  //       'image': await MultipartFile.fromFile(filePath),
  //       '_method': 'PUT',
  //     });
  //     final response = await _dioClient.dio.post(
  //       ApiConstants.profile,
  //       data: formData,
  //     );
  //     if (response.statusCode == 200) {
  //       final userJson = response.data['data'] as Map<String, dynamic>;
  //       await _prefsService.saveUser(userJson);
  //       return User.fromJson(userJson);
  //     } else {
  //       throw Exception(response.data['message'] ?? 'فشل تحديث الصورة');
  //     }
  //   } on DioException catch (e) {
  //     throw Exception(
  //       e.response?.data['message'] ?? 'حدث خطأ أثناء تحديث الصورة',
  //     );
  //   }
  // }

}
