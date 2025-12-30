import 'package:flutter/foundation.dart';
import 'package:taskmaster_app/data/models/weather_model.dart';
import 'package:taskmaster_app/data/services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService weatherService;
  
  WeatherModel? _currentWeather;
  bool _isLoading = false;
  String? _error;
  String _currentCity = 'Madrid'; // Ciudad por defecto

  WeatherProvider({required this.weatherService});

  // Getters
  WeatherModel? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentCity => _currentCity;

  // Obtener clima por ciudad
  Future<void> getWeatherByCity(String city) async {
    try {
      _isLoading = true;
      _error = null;
      _currentCity = city;
      notifyListeners();

      _currentWeather = await weatherService.getWeatherByCity(city);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Actualizar clima
  Future<void> refreshWeather() async {
    if (_currentCity.isNotEmpty) {
      await getWeatherByCity(_currentCity);
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Cambiar ciudad
  void changeCity(String city) {
    _currentCity = city;
    notifyListeners();
  }

  // Obtener icono del clima
  String getWeatherIcon() {
    if (_currentWeather == null) return '☀️';
    
    final main = _currentWeather!.description.toLowerCase();
    
    if (main.contains('lluvia')) return '🌧️';
    if (main.contains('nublado') || main.contains('nubes')) return '☁️';
    if (main.contains('nieve')) return '❄️';
    if (main.contains('tormenta')) return '⛈️';
    if (main.contains('soleado') || main.contains('despejado')) return '☀️';
    if (main.contains('niebla')) return '🌫️';
    
    return '🌤️';
  }

  // Obtener color según temperatura
  String getTemperatureColor() {
    if (_currentWeather == null) return 'blue';
    
    final temp = _currentWeather!.temperature;
    
    if (temp < 0) return 'lightblue';
    if (temp < 10) return 'blue';
    if (temp < 20) return 'green';
    if (temp < 30) return 'orange';
    return 'red';
  }
}