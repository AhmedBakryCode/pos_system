import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  final SharedPreferences _prefs;

  SharedPreferencesService(this._prefs);

  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';

  Future<bool> saveToken(String token) async {
    return await _prefs.setString(_keyToken, token);
  }

  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  Future<bool> removeToken() async {
    return await _prefs.remove(_keyToken);
  }

  Future<bool> saveUser(Map<String, dynamic> userJson) async {
    return await _prefs.setString(_keyUser, jsonEncode(userJson));
  }

  Map<String, dynamic>? getUser() {
    final userStr = _prefs.getString(_keyUser);
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }

  Future<bool> removeUser() async {
    return await _prefs.remove(_keyUser);
  }

  Future<void> clearAuth() async {
    await removeToken();
    await removeUser();
  }
}
