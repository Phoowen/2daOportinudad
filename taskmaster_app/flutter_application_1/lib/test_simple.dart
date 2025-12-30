import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Conexión Simple')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _testBackend,
                child: const Text('Probar Backend'),
              ),
              ElevatedButton(
                onPressed: _registerUser,
                child: const Text('Registrar Usuario'),
              ),
              ElevatedButton(
                onPressed: _loginUser,
                child: const Text('Login Usuario'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _testBackend() async {
    try {
      print('🔗 Probando: http://localhost:3000/api/health');
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/health'),
      ).timeout(const Duration(seconds: 5));
      
      print('✅ Status: ${response.statusCode}');
      print('📦 Body: ${response.body}');
      
      _showMessage('Backend OK: ${response.statusCode}');
    } catch (e) {
      print('❌ Error: $e');
      _showMessage('Error: $e');
    }
  }

  Future<void> _registerUser() async {
    try {
      print('🔗 Registrando en: http://localhost:3000/api/auth/register');
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': 'test${DateTime.now().millisecondsSinceEpoch}',
          'email': 'test${DateTime.now().millisecondsSinceEpoch}@test.com',
          'password': 'password123'
        }),
      ).timeout(const Duration(seconds: 10));
      
      print('✅ Status: ${response.statusCode}');
      print('📦 Body: ${response.body}');
      
      _showMessage('Registro: ${response.statusCode}');
    } catch (e) {
      print('❌ Error: $e');
      _showMessage('Error: $e');
    }
  }

  Future<void> _loginUser() async {
    try {
      print('🔗 Login en: http://localhost:3000/api/auth/login');
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'test@test.com',
          'password': 'password123'
        }),
      ).timeout(const Duration(seconds: 10));
      
      print('✅ Status: ${response.statusCode}');
      print('📦 Body: ${response.body}');
      
      _showMessage('Login: ${response.statusCode}');
    } catch (e) {
      print('❌ Error: $e');
      _showMessage('Error: $e');
    }
  }

  void _showMessage(String message) {
    // Mostrar en snackbar o alerta
    print('💬 Mensaje: $message');
  }
}