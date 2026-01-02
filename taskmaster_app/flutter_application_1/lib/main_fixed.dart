import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const TaskMasterApp());

class TaskMasterApp extends StatelessWidget {
  const TaskMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'nOWte.app',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';
  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _message = 'Email y contraseña requeridos');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Conectando...';
    });

    try {
      print('🔗 Enviando login a: http://localhost:3000/api/auth/login');
      print('📧 Email: ${_emailController.text}');
      
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📡 Respuesta status: ${response.statusCode}');
      print('📦 Respuesta body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _message = '✅ Login exitoso! Token: ${data['data']['token'].substring(0, 20)}...');
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Error desconocido';
        setState(() => _message = '❌ Error: $error');
      }
    } catch (e) {
      print('🔥 Error completo: $e');
      setState(() => _message = '❌ Error de conexión: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _message = 'Registrando...';
    });

    try {
      print('🔗 Enviando registro a: http://localhost:3000/api/auth/register');
      
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': 'usuario_${DateTime.now().millisecondsSinceEpoch}',
          'email': _emailController.text.isEmpty 
              ? 'test${DateTime.now().millisecondsSinceEpoch}@test.com'
              : _emailController.text,
          'password': _passwordController.text.isEmpty 
              ? 'password123'
              : _passwordController.text,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📡 Status: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 201) {
        setState(() => _message = '✅ Usuario registrado exitosamente!');
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Error';
        setState(() => _message = '❌ Error: $error');
      }
    } catch (e) {
      print('🔥 Error: $e');
      setState(() => _message = '❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('nOWte.app - Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'test@test.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                hintText: 'password123',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
                  ElevatedButton(
                    onPressed: _register,
                    child: const Text('Registrar'),
                  ),
                ],
              ),
            
            const SizedBox(height: 30),
            
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _message.contains('✅') ? Colors.green.shade50 : 
                       _message.contains('❌') ? Colors.red.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _message.contains('✅') ? Colors.green : 
                         _message.contains('❌') ? Colors.red : Colors.grey,
                ),
              ),
              child: Text(
                _message,
                style: TextStyle(
                  color: _message.contains('✅') ? Colors.green : 
                         _message.contains('❌') ? Colors.red : Colors.black,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            const Text(
              'Backend URL: http://localhost:3000',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}