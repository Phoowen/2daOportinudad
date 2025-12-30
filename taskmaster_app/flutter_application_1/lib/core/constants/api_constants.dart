import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Cargar variables de .env
  static String get baseUrl => dotenv.get('API_BASE_URL', fallback: 'http://10.0.2.2:3000/api');
  static String get weatherBaseUrl => 'https://api.openweathermap.org/data/2.5';
  
  static String get weatherApiKey {
    try {
      final key = dotenv.get('OPENWEATHER_API_KEY', fallback: '');
      if (key.isEmpty) {
        print('⚠️ OPENWEATHER_API_KEY está vacía o no encontrada');
      }
      return key;
    } catch (e) {
      print('❌ Error obteniendo API key: $e');
      return '';
    }
  }

  // Endpoints de autenticación
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';

  // Endpoints de tareas
  static const String tasks = '/tasks';
  static String taskById(String id) => '/tasks/$id';
  
  // Endpoints de clima
  static const String weather = '/weather';

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) {
    return {
      ...defaultHeaders,
      'Authorization': 'Bearer $token',
    };
  }
}