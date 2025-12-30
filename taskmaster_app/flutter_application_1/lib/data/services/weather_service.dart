import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taskmaster_app/core/constants/api_constants.dart';
import 'package:taskmaster_app/data/models/weather_model.dart';

class WeatherService {
  final http.Client client;

  WeatherService({required this.client});

  // Obtener clima por ciudad
  Future<WeatherModel> getWeatherByCity(String city) async {
    final url = Uri.parse(
      '${ApiConstants.weatherBaseUrl}/weather?q=$city&appid=${ApiConstants.weatherApiKey}&units=metric&lang=es'
    );

    final response = await client.get(url);

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(
        (response.body.isNotEmpty ? 
          (jsonDecode(response.body) as Map<String, dynamic>) 
          : {}
        ),
      );
    } else if (response.statusCode == 404) {
      throw Exception('Ciudad no encontrada');
    } else if (response.statusCode == 401) {
      throw Exception('API key inválida. Actualiza tu API key en .env');
    } else {
      throw Exception('Error al obtener datos del clima: ${response.statusCode}');
    }
  }

  // Obtener clima por coordenadas (opcional)
  Future<WeatherModel> getWeatherByLocation(double lat, double lon) async {
    final url = Uri.parse(
      '${ApiConstants.weatherBaseUrl}/weather?lat=$lat&lon=$lon&appid=${ApiConstants.weatherApiKey}&units=metric&lang=es'
    );

    final response = await client.get(url);

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener datos del clima');
    }
  }
}