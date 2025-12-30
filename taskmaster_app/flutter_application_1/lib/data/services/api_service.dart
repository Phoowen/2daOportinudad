import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taskmaster_app/core/constants/api_constants.dart';

class ApiService {
  final http.Client client;
  final String baseUrl;

  ApiService({required this.client, this.baseUrl = ''});

  String get _effectiveBaseUrl => baseUrl.isNotEmpty ? baseUrl : ApiConstants.baseUrl;

  // Métodos HTTP genéricos
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    String? token,
  }) async {
    final url = Uri.parse('$_effectiveBaseUrl$endpoint');
    final mergedHeaders = {
      ...ApiConstants.defaultHeaders,
      ...?headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await client.get(url, headers: mergedHeaders);
    return response;
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    String? token,
  }) async {
    final url = Uri.parse('$_effectiveBaseUrl$endpoint');
    final mergedHeaders = {
      ...ApiConstants.defaultHeaders,
      ...?headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await client.post(
      url,
      headers: mergedHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
    return response;
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    String? token,
  }) async {
    final url = Uri.parse('$_effectiveBaseUrl$endpoint');
    final mergedHeaders = {
      ...ApiConstants.defaultHeaders,
      ...?headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await client.put(
      url,
      headers: mergedHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
    return response;
  }

  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
    String? token,
  }) async {
    final url = Uri.parse('$_effectiveBaseUrl$endpoint');
    final mergedHeaders = {
      ...ApiConstants.defaultHeaders,
      ...?headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await client.delete(url, headers: mergedHeaders);
    return response;
  }

  // Manejo de errores
  Map<String, dynamic> handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw HttpException(
        message: errorData['error'] ?? 'Error desconocido',
        statusCode: response.statusCode,
      );
    }
  }
}

class HttpException implements Exception {
  final String message;
  final int statusCode;

  HttpException({required this.message, required this.statusCode});

  @override
  String toString() => 'HttpException: $message (Status: $statusCode)';
}