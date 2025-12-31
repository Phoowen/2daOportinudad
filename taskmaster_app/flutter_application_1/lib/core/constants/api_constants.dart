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

  // NUEVO: NewsAPI
  static String get newsApiKey {
    try {
      final key = dotenv.get('NEWS_API_KEY', fallback: '');
      if (key.isEmpty) {
        print('⚠️ NEWS_API_KEY está vacía o no encontrada');
      }
      return key;
    } catch (e) {
      print('❌ Error obteniendo NewsAPI key: $e');
      return '';
    }
  }

  static String get newsBaseUrl => 'https://newsapi.org/v2';

  // Endpoints de autenticación
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';

  // Endpoints de tareas
  static const String tasks = '/tasks';
  static String taskById(String id) => '/tasks/$id';
  
  // Endpoints de clima
  static const String weather = '/weather';

  // Endpoints de noticias (NUEVO)
  static String get topHeadlines => '/top-headlines';
  static String get everything => '/everything';

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

  // Métodos útiles para noticias
  static String getNewsUrl({
    String endpoint = 'top-headlines',
    String country = 'us',
    String category = 'general',
    int pageSize = 10,
    String? query,
  }) {
    final base = '$newsBaseUrl/$endpoint';
    
    if (endpoint == 'top-headlines') {
      return '$base?country=$country&category=$category&pageSize=$pageSize&apiKey=$newsApiKey';
    } else if (endpoint == 'everything' && query != null) {
      return '$base?q=$query&pageSize=$pageSize&apiKey=$newsApiKey';
    }
    
    return base;
  }

  // Categorías de noticias disponibles
  static List<String> get newsCategories => [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
  ];

  // Países disponibles para noticias
  static Map<String, String> get newsCountries => {
    'us': 'Estados Unidos',
    'gb': 'Reino Unido',
    'es': 'España',
    'mx': 'México',
    'ar': 'Argentina',
    'co': 'Colombia',
    'br': 'Brasil',
  };

  // Convertir categoría a nombre legible
  static String getCategoryDisplayName(String category) {
    switch (category) {
      case 'business': return 'Negocios';
      case 'entertainment': return 'Entretenimiento';
      case 'health': return 'Salud';
      case 'science': return 'Ciencia';
      case 'sports': return 'Deportes';
      case 'technology': return 'Tecnología';
      case 'general': return 'General';
      default: return category;
    }
  }
}