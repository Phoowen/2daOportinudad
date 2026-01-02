import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taskmaster_app/core/constants/api_constants.dart';
import 'package:taskmaster_app/data/models/news_model.dart';

class NewsService {
  final String apiKey;

  NewsService({required this.apiKey});

  // ============ MÉTODOS PRINCIPALES ============

  // Obtener noticias principales por categoría
  Future<List<NewsArticle>> getTopHeadlines({
    String country = 'us',
    String category = 'general',
    int pageSize = 10,
  }) async {
    try {
      // Construir URL usando ApiConstants
      final url = Uri.parse(ApiConstants.getNewsUrl(
        endpoint: 'top-headlines',
        country: country,
        category: category,
        pageSize: pageSize,
      ));

      print('📰 [NEWS API] Consultando noticias: ${ApiConstants.getCategoryDisplayName(category)} ($country)');
      print('🔗 URL: ${_maskApiKeyInUrl(url.toString())}');

      final response = await http.get(url);

      print('📡 Status: ${response.statusCode}');
      print('📊 Tamaño respuesta: ${response.body.length} bytes');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newsResponse = NewsResponse.fromJson(data);
        
        print('✅ Noticias recibidas: ${newsResponse.articles.length} artículos');
        
        // Validar si hay noticias reales o si estamos en modo demo
        if (newsResponse.articles.isEmpty && apiKey.isEmpty) {
          print('ℹ️  API Key no configurada, usando datos de ejemplo');
          return _getMockNews();
        }
        
        return newsResponse.articles;
      } else if (response.statusCode == 401) {
        throw Exception('API Key de NewsAPI inválida o expirada');
      } else if (response.statusCode == 429) {
        throw Exception('Límite de solicitudes excedido (100/día en plan gratis)');
      } else if (response.statusCode == 426) {
        throw Exception('Se requiere actualización del plan de NewsAPI');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Error desconocido';
        throw Exception('Error ${response.statusCode}: $errorMessage');
      }
    } catch (e) {
      print('❌ Error en getTopHeadlines: $e');
      
      // Si no hay API key o hay error de red, usar datos de ejemplo
      if (apiKey.isEmpty || e.toString().contains('SocketException')) {
        print('⚠️  Usando datos de ejemplo para desarrollo');
        return _getMockNews();
      }
      
      rethrow;
    }
  }

  // Buscar noticias por palabra clave
  Future<List<NewsArticle>> searchNews({
    required String query,
    String language = 'es',
    int pageSize = 10,
  }) async {
    try {
      // Validar query
      if (query.trim().isEmpty) {
        return await getTopHeadlines();
      }

      final url = Uri.parse(ApiConstants.getNewsUrl(
        endpoint: 'everything',
        query: query,
        language: language,
        pageSize: pageSize,
      ));

      print('🔍 [NEWS API] Buscando: "$query"');
      print('🔗 URL: ${_maskApiKeyInUrl(url.toString())}');

      final response = await http.get(url);

      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newsResponse = NewsResponse.fromJson(data);
        
        print('✅ Resultados encontrados: ${newsResponse.articles.length} artículos');
        return newsResponse.articles;
      } else if (response.statusCode == 401) {
        throw Exception('API Key de NewsAPI inválida');
      } else if (response.statusCode == 429) {
        throw Exception('Límite de búsquedas excedido');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Error desconocido';
        throw Exception('Error ${response.statusCode}: $errorMessage');
      }
    } catch (e) {
      print('❌ Error en searchNews: $e');
      
      // Si no hay API key, buscar en datos de ejemplo
      if (apiKey.isEmpty) {
        print('⚠️  API Key no configurada, buscando en datos de ejemplo');
        return _searchMockNews(query);
      }
      
      rethrow;
    }
  }

  // ============ MÉTODOS AUXILIARES ============

  // Cargar noticias con manejo de errores mejorado
  Future<List<NewsArticle>> safeLoadNews({
    String country = 'us',
    String category = 'general',
    int pageSize = 10,
  }) async {
    try {
      return await getTopHeadlines(
        country: country,
        category: category,
        pageSize: pageSize,
      );
    } catch (e) {
      print('⚠️  No se pudieron cargar noticias en tiempo real: $e');
      print('🔄 Cargando datos de ejemplo...');
      
      return _getMockNews();
    }
  }

  // Verificar si la API está disponible
  Future<bool> checkApiAvailability() async {
    try {
      if (apiKey.isEmpty) {
        print('ℹ️  NewsAPI: Modo demo (sin API Key)');
        return false;
      }

      final url = Uri.parse(ApiConstants.getNewsUrl(
        endpoint: 'top-headlines',
        country: 'us',
        category: 'general',
        pageSize: 1,
      ));

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        print('✅ NewsAPI: Disponible');
        return true;
      } else {
        print('⚠️  NewsAPI: Error ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ NewsAPI: No disponible - $e');
      return false;
    }
  }

  // ============ DATOS DE EJEMPLO ============

  // Datos de ejemplo para desarrollo/pruebas
  List<NewsArticle> _getMockNews() {
    final now = DateTime.now();
    return [
      NewsArticle(
        author: 'Redacción Tecnología',
        title: 'Flutter 3.19 anunciado con nuevas características',
        description: 'Google anuncia la nueva versión de Flutter con mejoras de rendimiento y nuevas widgets para desarrollo multiplataforma',
        url: 'https://ejemplo.com/flutter-3-19',
        urlToImage: 'https://images.unsplash.com/photo-1551650975-87deedd944c3?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
        publishedAt: now.subtract(const Duration(hours: 2)),
        content: 'Flutter 3.19 incluye mejoras significativas en el rendimiento y nuevas widgets para desarrollo multiplataforma...',
        sourceName: 'Tech News',
      ),
      NewsArticle(
        author: 'Meteorología Nacional',
        title: 'Pronóstico del tiempo para esta semana',
        description: 'Se esperan lluvias moderadas y temperaturas frescas en la mayor parte del país',
        url: 'https://ejemplo.com/pronostico-tiempo',
        urlToImage: 'https://images.unsplash.com/photo-1592210454359-9043f067919b?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
        publishedAt: now.subtract(const Duration(hours: 5)),
        content: 'El pronóstico para esta semana indica la llegada de un frente frío que traerá lluvias y descenso de temperaturas...',
        sourceName: 'Clima Hoy',
      ),
      NewsArticle(
        author: 'Oficina de Productividad',
        title: 'Consejos para mejorar la gestión de tareas',
        description: 'Expertos comparten estrategias efectivas para organizar tus tareas diarias y aumentar la productividad',
        url: 'https://ejemplo.com/gestion-tareas',
        urlToImage: 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
        publishedAt: now.subtract(const Duration(days: 1)),
        content: 'La gestión efectiva de tareas puede aumentar tu productividad hasta en un 40% según estudios recientes...',
        sourceName: 'Productividad Digital',
      ),
      NewsArticle(
        author: 'Equipo de Salud',
        title: 'Nuevos avances en medicina preventiva',
        description: 'Investigadores presentan nuevos métodos para la detección temprana de enfermedades',
        url: 'https://ejemplo.com/avances-medicina',
        urlToImage: 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
        publishedAt: now.subtract(const Duration(days: 2)),
        content: 'Los nuevos avances en inteligencia artificial están revolucionando la medicina preventiva...',
        sourceName: 'Salud Avanzada',
      ),
      NewsArticle(
        author: 'Departamento de Economía',
        title: 'Mercados muestran signos de recuperación',
        description: 'Los índices bursátiles principales muestran ganancias tras semanas de volatilidad',
        url: 'https://ejemplo.com/mercados-recuperacion',
        urlToImage: 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
        publishedAt: now.subtract(const Duration(days: 3)),
        content: 'Analistas predicen una recuperación gradual de los mercados financieros durante el próximo trimestre...',
        sourceName: 'Finanzas Globales',
      ),
    ];
  }

  // Buscar en datos de ejemplo
  List<NewsArticle> _searchMockNews(String query) {
    final mockNews = _getMockNews();
    final searchTerm = query.toLowerCase();
    
    return mockNews.where((article) {
      return article.title.toLowerCase().contains(searchTerm) ||
             article.description.toLowerCase().contains(searchTerm) ||
             article.content.toLowerCase().contains(searchTerm) ||
             article.sourceName.toLowerCase().contains(searchTerm);
    }).toList();
  }

  // ============ GETTERS PARA CONSTANTES ============

  // Categorías disponibles
  static List<String> get categories => ApiConstants.newsCategories;

  // Países disponibles
  static Map<String, String> get countries => ApiConstants.newsCountries;

  // Obtener nombre amigable de categoría
  static String getCategoryDisplayName(String category) {
    return ApiConstants.getCategoryDisplayName(category);
  }

  // Obtener nombre amigable de país
  static String getCountryDisplayName(String countryCode) {
    return ApiConstants.getCountryDisplayName(countryCode);
  }

  // ============ MÉTODOS PRIVADOS ============

  // Enmascarar API Key en logs
  String _maskApiKeyInUrl(String url) {
    if (apiKey.isEmpty) return url.replaceAll('apiKey=', 'apiKey=DEMO_KEY');
    return url.replaceAll(apiKey, '***${apiKey.substring(apiKey.length - 4)}');
  }

  // Validar configuración
  String get apiStatus {
    if (apiKey.isEmpty) {
      return 'Modo demo - Usando datos de ejemplo';
    }
    
    final maskedKey = '${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)}';
    return 'API Key configurada: $maskedKey';
  }

  // Obtener configuración por defecto
  Map<String, dynamic> get defaultConfig {
    return {
      'country': ApiConstants.defaultNewsCountry,
      'category': ApiConstants.defaultNewsCategory,
      'pageSize': ApiConstants.defaultNewsPageSize,
      'language': ApiConstants.defaultNewsLanguage,
      'hasApiKey': apiKey.isNotEmpty,
    };
  }
}