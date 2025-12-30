import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taskmaster_app/data/models/user_model.dart';

class AuthService {
  // 🔥 URL DIRECTA a tu backend (cambia si usas Android emulador)
  static const String _baseUrl = 'http://localhost:3000/api';
  
  // Registrar usuario
  Future<LoginResponse> register({
    required String username,
    required String email,
    required String password,
  }) async {
    print('🔗 [REGISTER] URL: $_baseUrl/auth/register');
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      print('📡 Status: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return LoginResponse.fromJson(data['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Error en registro');
      }
    } catch (e) {
      print('❌ Error en register: $e');
      rethrow;
    }
  }

  // Login de usuario
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    print('🔗 [LOGIN] URL: $_baseUrl/auth/login');
    print('📧 Email: $email');
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('📡 Status: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LoginResponse.fromJson(data['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Error en login');
      }
    } catch (e) {
      print('❌ Error en login: $e');
      rethrow;
    }
  }

  // Obtener perfil (requiere token)
  Future<UserModel> getProfile(String token) async {
    print('🔗 [PROFILE] URL: $_baseUrl/auth/profile');
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data['data']['user']);
      } else {
        throw Exception('Error al obtener perfil');
      }
    } catch (e) {
      print('❌ Error en getProfile: $e');
      rethrow;
    }
  }
}