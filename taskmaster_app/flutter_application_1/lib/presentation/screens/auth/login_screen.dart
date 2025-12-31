import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:taskmaster_app/presentation/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;

  final authProvider = context.read<AuthProvider>();
  
  print('🔄 Iniciando login con:');
  print('   📧 Email: ${_emailController.text}');
  print('   🔐 Password: ${_passwordController.text}');
  
  final success = await authProvider.login(
    email: _emailController.text.trim(),
    password: _passwordController.text,
  );

  if (success && context.mounted) {
    print('✅ Login exitoso!');
    print('   🎫 Token: ${authProvider.token?.substring(0, 20)}...');
    print('   👤 Usuario: ${authProvider.user?.username}');
    
    // Navegar al home
    context.go('/home');
  } else if (context.mounted) {
    print('❌ Login falló');
    print('   💥 Error: ${authProvider.error}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(authProvider.error ?? 'Error en el login'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo y título
              const SizedBox(height: 40),
              _buildLogo(),
              const SizedBox(height: 40),
              
              // Formulario
              _buildForm(authProvider),
              const SizedBox(height: 32),
              
              // Botón de login
              _buildLoginButton(authProvider),
              const SizedBox(height: 24),
              
              // Link a registro
              _buildRegisterLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.blue.shade800,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.task_alt,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'nOWte.app',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bienvenido al módulo de gestión de tareas inteligente',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email
          Text(
            'Email',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              hintText: 'ejemplo@email.com',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu email';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Ingresa un email válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          // Contraseña
          Text(
            'Contraseña',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              hintText: 'Tu contraseña',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu contraseña';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          
          // Error si hay
          if (authProvider.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      authProvider.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoginButton(AuthProvider authProvider) {
    return ElevatedButton(
      onPressed: authProvider.isLoading ? null : _login,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: authProvider.isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : const Text(
              'Iniciar Sesión',
              style: TextStyle(fontSize: 16),
            ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tienes cuenta? ',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        TextButton(
          onPressed: () => context.go('/register'),
          child: const Text('Regístrate aquí'),
        ),
      ],
    );
  }
}