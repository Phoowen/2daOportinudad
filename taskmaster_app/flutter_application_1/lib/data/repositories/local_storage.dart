import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskmaster_app/core/constants/app_constants.dart';
import 'package:taskmaster_app/data/models/user_model.dart';

class LocalStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('LocalStorage no inicializado. Llama a init() primero.');
    }
    return _prefs!;
  }

  // Token
  static Future<void> saveToken(String token) async {
    await prefs.setString(AppConstants.tokenKey, token);
  }

  static String? getToken() {
    return prefs.getString(AppConstants.tokenKey);
  }

  static Future<void> removeToken() async {
    await prefs.remove(AppConstants.tokenKey);
  }

  // Usuario
  static Future<void> saveUser(UserModel user) async {
    await prefs.setString(AppConstants.userKey, user.toJson().toString());
  }

  static UserModel? getUser() {
    final userJson = prefs.getString(AppConstants.userKey);
    if (userJson == null) return null;
    
    try {
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      return UserModel.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  static Future<void> removeUser() async {
    await prefs.remove(AppConstants.userKey);
  }

  // Tema
  static Future<void> saveTheme(bool isDark) async {
    await prefs.setBool(AppConstants.themeKey, isDark);
  }

  static bool getTheme() {
    return prefs.getBool(AppConstants.themeKey) ?? false;
  }

  // Limpiar todo (logout)
  static Future<void> clearAll() async {
    await prefs.clear();
  }

  // Verificar si hay sesión activa
  static bool isLoggedIn() {
    return getToken() != null && getUser() != null;
  }
}