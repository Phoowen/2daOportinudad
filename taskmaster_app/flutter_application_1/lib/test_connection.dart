import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const TestApp());

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Test Conexión Backend')),
        body: const TestScreen(),
      ),
    );
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String _result = '';

  Future<void> _testConexion() async {
    setState(() => _result = '🔍 Probando conexión...\n\n');
    
    // URL de tu backend
    const backendUrl = 'http://localhost:3000';
    
    try {
      // 1. Test Health
      _result += '1. 🔗 Probando /api/health...\n';
      final healthResponse = await http.get(
        Uri.parse('$backendUrl/api/health'),
      ).timeout(const Duration(seconds: 5));
      _result += '   ✅ Status: ${healthResponse.statusCode}\n';
      _result += '   📦 Body: ${healthResponse.body}\n\n';

      // 2. Test Register
      _result += '2. 👤 Probando registro...\n';
      final registerResponse = await http.post(
        Uri.parse('$backendUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': 'test_${DateTime.now().millisecondsSinceEpoch}',
          'email': 'test_${DateTime.now().millisecondsSinceEpoch}@test.com',
          'password': 'password123'
        }),
      ).timeout(const Duration(seconds: 10));
      _result += '   ✅ Status: ${registerResponse.statusCode}\n';
      _result += '   📦 Body: ${registerResponse.body}\n\n';

      // 3. Test Login
      _result += '3. 🔐 Probando login...\n';
      final loginResponse = await http.post(
        Uri.parse('$backendUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'prueba@test.com',  // Usa un email que SABES que existe
          'password': 'password123'
        }),
      ).timeout(const Duration(seconds: 10));
      _result += '   ✅ Status: ${loginResponse.statusCode}\n';
      _result += '   📦 Body: ${loginResponse.body}\n\n';

      _result += '🎉 ¡CONEXIÓN EXITOSA!\n';
      _result += 'El backend responde correctamente.';
      
    } catch (e) {
      _result += '\n❌ ERROR DE CONEXIÓN:\n';
      _result += '$e\n\n';
      _result += '🔧 Posibles soluciones:\n';
      _result += '1. ¿El backend está corriendo? (npm run dev)\n';
      _result += '2. ¿La URL es correcta? ($backendUrl)\n';
      _result += '3. ¿Hay error CORS en el backend?\n';
      _result += '4. ¿Firewall bloqueando puerto 3000?\n';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: _testConexion,
            child: const Text('Probar Conexión Backend'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                _result,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}