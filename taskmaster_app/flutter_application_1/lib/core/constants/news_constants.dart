// lib/core/constants/news_constants.dart
class NewsConstants {
  // Configuración
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;
  static const String defaultCountry = 'us';
  static const String defaultCategory = 'general';
  static const String defaultLanguage = 'es';
  
  // Categorías
  static List<String> get categories => [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
  ];

  // Países
  static Map<String, String> get countries => {
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

  // Nombres legibles
  static Map<String, String> get categoryDisplayNames => {
    'business': 'Negocios',
    'entertainment': 'Entretenimiento',
    'health': 'Salud',
    'science': 'Ciencia',
    'sports': 'Deportes',
    'technology': 'Tecnología',
    'general': 'General',
  };

  static String getCategoryDisplayName(String category) {
    return categoryDisplayNames[category] ?? category;
  }

  static String getCountryDisplayName(String countryCode) {
    return countries[countryCode] ?? countryCode.toUpperCase();
  }
}