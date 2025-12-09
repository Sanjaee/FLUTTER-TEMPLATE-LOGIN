import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';

class StorageHelper {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userTypeKey = 'user_type';
  
  // Token management
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setBool(_isLoggedInKey, true);
  }
  
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Alias for getAccessToken
  static Future<String?> getToken() async {
    return getAccessToken();
  }
  
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }
  
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.setBool(_isLoggedInKey, false);
  }
  
  // User data management - save UserModel as JSON
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(user.toJson());
    await prefs.setString(_userDataKey, jsonString);
  }

  // Get UserModel from storage
  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userDataKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        return UserModel.fromJson(jsonMap);
      } catch (e) {
        // Invalid JSON, clear it
        await prefs.remove(_userDataKey);
        return null;
      }
    }
    return null;
  }

  // Legacy method - save user data as string (deprecated, use saveUser instead)
  @Deprecated('Use saveUser(UserModel) instead')
  static Future<void> saveUserData(String userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, userData);
  }
  
  // Legacy method - get user data as string (deprecated, use getUser instead)
  @Deprecated('Use getUser() instead')
  static Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userDataKey);
  }
  
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
  }

  // User type/role management
  static Future<void> saveUserType(String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTypeKey, userType.toLowerCase());
  }

  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey);
  }
  
  // Login status
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final hasToken = prefs.getString(_accessTokenKey)?.isNotEmpty ?? false;
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    return hasToken && isLoggedIn;
  }
  
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }
  
  // Clear all data (logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  
  // Generic storage methods
  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
  
  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
  
  static Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
  
  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future<void> saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }
  
  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
