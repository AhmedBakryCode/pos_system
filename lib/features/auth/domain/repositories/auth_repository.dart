import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<User?> refreshToken();
  Future<void> logout();
  Future<User?> getCachedUser();
  Future<User> getProfile();
  Future<User> updateProfile({
    required String fname,
    required String lname,
    required String email,
    required String phone,
    required String address,
    dynamic profileImage, // Can be File or path
  });
}
