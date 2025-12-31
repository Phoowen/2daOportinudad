import 'package:flutter/material.dart';
import 'package:taskmaster_app/data/models/news_model.dart';
import 'package:taskmaster_app/data/services/news_service.dart';

class NewsProvider extends ChangeNotifier {
  final NewsService newsService;
  
  List<NewsArticle> _articles = [];
  List<NewsArticle> _filteredArticles = [];
  String _selectedCategory = 'general';
  String _selectedCountry = 'us';
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  NewsProvider({required this.newsService});

  // Getters
  List<NewsArticle> get articles => _filteredArticles;
  List<NewsArticle> get allArticles => _articles;
  String get selectedCategory => _selectedCategory;
  String get selectedCountry => _selectedCountry;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  // Cargar noticias
  Future<void> loadNews() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _articles = await newsService.getTopHeadlines(
        country: _selectedCountry,
        category: _selectedCategory,
      );
      
      _applyFilters();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Cambiar categoría
  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
    loadNews(); // Recargar con nueva categoría
  }

  // Cambiar país
  void setCountry(String country) {
    _selectedCountry = country;
    _applyFilters();
    notifyListeners();
    loadNews(); // Recargar con nuevo país
  }

  // Buscar noticias
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Aplicar filtros
  void _applyFilters() {
    var filtered = List<NewsArticle>.from(_articles);
    
    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((article) => 
        article.title.toLowerCase().contains(query) ||
        article.description.toLowerCase().contains(query) ||
        article.sourceName.toLowerCase().contains(query)
      ).toList();
    }
    
    _filteredArticles = filtered;
  }

  // Limpiar filtros
  void clearFilters() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Actualizar manualmente
  Future<void> refresh() async {
    await loadNews();
  }

  // Categorías disponibles
  List<String> get availableCategories => NewsService.categories;

  // Nombre amigable de categoría
  String getCategoryDisplayName(String category) {
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