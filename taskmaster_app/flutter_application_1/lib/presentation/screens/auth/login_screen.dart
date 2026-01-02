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
              const SizedBox(height: 40),
              _buildLogo(),
              const SizedBox(height: 40),
              _buildForm(authProvider),
              const SizedBox(height: 32),
              _buildLoginButton(authProvider),
              const SizedBox(height: 24),
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
      // Logo con tu imagen personalizada
      Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,  // Cambia a 'contain' si quieres ver todo el logo
            errorBuilder: (context, error, stackTrace) {
              // Fallback en caso de que la imagen no se encuentre
              return Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(
                    Icons.task_alt,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      const SizedBox(height: 40),
      Text(
        'nOWte.app',
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
              fontSize: 32,
            ),
      ),
      const SizedBox(height: 8),
      Text(
        'Organiza, prioriza, ejecuta',
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
          Text(
            'Email',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'tu@email.com',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
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
          Text(
            'Contraseña',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword 
                      ? Icons.visibility_outlined 
                      : Icons.visibility_off_outlined,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
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
                  const Icon(Icons.error_outline, color: Colors.red),
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
        padding: const EdgeInsets.symmetric(vertical: 18),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: authProvider.isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : const Text(
              'Iniciar Sesión',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(50, 30),
          ),
          child: const Text(
            'Regístrate aquí',
            style: TextStyle(
              color: Color(0xFF6366F1),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}