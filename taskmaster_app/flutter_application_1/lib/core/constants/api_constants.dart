import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // ============ URLS BASE ============
  static String get baseUrl => dotenv.get('API_BASE_URL', fallback: 'http://10.0.2.2:3000/api');
  static String get weatherBaseUrl => 'https://api.openweathermap.org/data/2.5';
  static String get newsBaseUrl => 'https://newsapi.org/v2';

  // ============ API KEYS ============
  static String get weatherApiKey {
    try {
      final key = dotenv.get('OPENWEATHER_API_KEY', fallback: '');
      if (key.isEmpty) {
        print('⚠️ OPENWEATHER_API_KEY está vacía o no encontrada');
      }
      return key;
    } catch (e) {
      print('❌ Error obteniendo Weather API key: $e');
      return '';
    }
  }

  static String get newsApiKey {
    try {
      final key = dotenv.get('NEWS_API_KEY', fallback: '');
      if (key.isEmpty) {
        print('⚠️ NEWS_API_KEY está vacía o no encontrada - Usando datos de ejemplo');
      }
      return key;
    } catch (e) {
      print('❌ Error obteniendo NewsAPI key: $e');
      return '';
    }
  }

  // ============ ENDPOINTS ============
  // Autenticación
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';

  // Tareas
  static const String tasks = '/tasks';
  static String taskById(String id) => '/tasks/$id';
  
  // Clima
  static const String weather = '/weather';

  // Noticias
  static const String topHeadlines = '/top-headlines';
  static const String everything = '/everything';

  // ============ CONFIGURACIÓN ============
  static const int defaultNewsPageSize = 10;
  static const int maxNewsPageSize = 50;
  static const String defaultNewsCountry = 'us';
  static const String defaultNewsCategory = 'general';
  static const String defaultNewsLanguage = 'es';

  // ============ HEADERS ============
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

  // ============ MÉTODOS UTILES PARA NEWS ============
  static String getNewsUrl({
    String endpoint = 'top-headlines',
    String country = 'us',
    String category = 'general',
    int pageSize = 10,
    String? query,
    String? language,
  }) {
    final base = '$newsBaseUrl/$endpoint';
    final params = <String>[];
    
    if (endpoint == 'top-headlines') {
      params.add('country=$country');
      params.add('category=$category');
    } else if (endpoint == 'everything' && query != null) {
      params.add('q=${Uri.encodeComponent(query)}');
      if (language != null) {
        params.add('language=$language');
      }
    }
    
    params.add('pageSize=$pageSize');
    params.add('apiKey=$newsApiKey');
    
    return '$base?${params.join('&')}';
  }

  static String getWeatherUrl(String city) {
    return '$weatherBaseUrl/$weather?q=$city&appid=$weatherApiKey&units=metric&lang=es';
  }

  // ============ CATEGORÍAS DE NOTICIAS ============
  static List<String> get newsCategories => [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
  ];

  // ============ PAÍSES DISPONIBLES ============
  static Map<String, String> get newsCountries => {
    'us': 'Estados Unidos',
    'gb': 'Reino Unido',
    'es': 'España',
    'mx': 'México',
    'ar': 'Argentina',
    'co': 'Colombia',
    'br': 'Brasil',
    'fr': 'Francia',
    'de': 'Alemania',
    'it': 'Italia',
  };

  // ============ NOMBRES LEGIBLES ============
  static String getCategoryDisplayName(String category) {
    final names = {
      'business': 'Negocios',
      'entertainment': 'Entretenimiento',
      'health': 'Salud',
      'science': 'Ciencia',
      'sports': 'Deportes',
      'technology': 'Tecnología',
      'general': 'General',
    };
    return names[category] ?? category;
  }

  static String getCountryDisplayName(String countryCode) {
    return newsCountries[countryCode] ?? countryCode.toUpperCase();
  }

  // ============ VALIDACIÓN API ============
  static bool hasWeatherApiKey() => weatherApiKey.isNotEmpty;
  static bool hasNewsApiKey() => newsApiKey.isNotEmpty;
  
  static String get apiStatus {
    final weatherOk = hasWeatherApiKey();
    final newsOk = hasNewsApiKey();
    
    if (weatherOk && newsOk) return '✅ Todas las APIs configuradas';
    if (!weatherOk && !newsOk) return '⚠️ Faltan ambas API Keys';
    if (!weatherOk) return '⚠️ Falta Weather API Key';
    if (!newsOk) return '⚠️ Falta News API Key (usando datos de ejemplo)';
    
    return '✅ APIs listas';
  }
}