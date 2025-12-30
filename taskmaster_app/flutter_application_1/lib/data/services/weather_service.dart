import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taskmaster_app/core/constants/api_constants.dart';
import 'package:taskmaster_app/data/models/weather_model.dart';

class WeatherService {
  final http.Client client;

  WeatherService({required this.client});

  // Obtener clima por ciudad - VERSIÓN CORREGIDA
  Future<WeatherModel> getWeatherByCity(String city) async {
    // 1. Verificar API key primero
    final apiKey = ApiConstants.weatherApiKey;
    if (apiKey.isEmpty) {
      print('❌ OPENWEATHER_API_KEY no configurada en .env');
      throw Exception('API key de OpenWeather no configurada. Verifica tu archivo .env');
    }

    // 2. Construir URL
    final url = Uri.parse(
      '${ApiConstants.weatherBaseUrl}/weather?q=$city&appid=$apiKey&units=metric&lang=es'
    );

    // 3. Debug logs
    print('🌤️ Consultando clima para: $city');
    print('🔑 API Key presente: ${apiKey.isNotEmpty}');
    print('🔗 URL (segura): ${url.toString().replaceAll(apiKey, '***')}');

    try {
      final response = await client.get(url);
      
      print('📡 Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Respuesta vacía del servidor de clima');
        }
        
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Datos recibidos correctamente');
        
        return WeatherModel.fromJson(data);
        
      } else if (response.statusCode == 401) {
        print('❌ Error 401 - API Key inválida o expirada');
        print('📄 Respuesta del servidor: ${response.body}');
        throw Exception('API key inválida. Actualiza tu OPENWEATHER_API_KEY en .env');
        
      } else if (response.statusCode == 404) {
        throw Exception('Ciudad "$city" no encontrada');
        
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        throw Exception('Error del servidor de clima: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Error en getWeatherByCity: $e');
      rethrow;
    }
  }

  // Obtener clima por coordenadas (opcional)
  Future<WeatherModel> getWeatherByLocation(double lat, double lon) async {
    final apiKey = ApiConstants.weatherApiKey;
    if (apiKey.isEmpty) {
      throw Exception('API key de OpenWeather no configurada');
    }

    final url = Uri.parse(
      '${ApiConstants.weatherBaseUrl}/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=es'
    );

    final response = await client.get(url);

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener datos del clima');
    }
  }
}