import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taskmaster_app/data/models/news_model.dart';

class NewsService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  final String _apiKey;

  NewsService({required String apiKey}) : _apiKey = apiKey;

  // Obtener noticias por categoría
  Future<List<NewsArticle>> getTopHeadlines({
    String country = 'us',
    String category = 'general',
    int pageSize = 10,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/top-headlines?country=$country&category=$category&pageSize=$pageSize&apiKey=$_apiKey',
      );

      print('📰 [NEWS API] Consultando noticias: $category');
      print('🔗 URL: ${url.toString().replaceAll(_apiKey, '***')}');

      final response = await http.get(url);

      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newsResponse = NewsResponse.fromJson(data);
        
        print('✅ Noticias recibidas: ${newsResponse.articles.length} artículos');
        return newsResponse.articles;
      } else if (response.statusCode == 401) {
        throw Exception('API Key de NewsAPI inválida');
      } else {
        throw Exception('Error al obtener noticias: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en getTopHeadlines: $e');
      rethrow;
    }
  }

  // Obtener noticias por palabra clave
  Future<List<NewsArticle>> searchNews({
    required String query,
    String language = 'es',
    int pageSize = 10,
  }) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse(
        '$_baseUrl/everything?q=$encodedQuery&language=$language&pageSize=$pageSize&apiKey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newsResponse = NewsResponse.fromJson(data);
        return newsResponse.articles;
      } else {
        throw Exception('Error al buscar noticias: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en searchNews: $e');
      rethrow;
    }
  }

  // Categorías disponibles
  static List<String> get categories => [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
  ];

  // Países disponibles
  static Map<String, String> get countries => {
    'us': 'Estados Unidos',
    'gb': 'Reino Unido',
    'es': 'España',
    'mx': 'México',
    'ar': 'Argentina',
    'co': 'Colombia',
    'br': 'Brasil',
  };
}