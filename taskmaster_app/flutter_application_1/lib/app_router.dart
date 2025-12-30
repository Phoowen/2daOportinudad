import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:taskmaster_app/presentation/providers/auth_provider.dart';
import 'package:taskmaster_app/presentation/screens/auth/login_screen.dart';
import 'package:taskmaster_app/presentation/screens/auth/register_screen.dart';
import 'package:taskmaster_app/presentation/screens/tasks/task_detail_screen.dart';
import 'package:taskmaster_app/presentation/screens/tasks/task_form_screen.dart';
import 'package:taskmaster_app/presentation/screens/tasks/task_list_screen.dart';
import 'package:taskmaster_app/presentation/screens/weather/weather_screen.dart';
import 'package:taskmaster_app/presentation/screens/home_screen.dart';

class AppRouter {
  static GoRouter get router => _router;

  static final _router = GoRouter(
    initialLocation: '/',
    routes: [
      // Ruta raíz - redirecciona según autenticación
      GoRoute(
        path: '/',
        redirect: (context, state) {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          
          if (authProvider.isLoggedIn) {
            return '/home';
          } else {
            return '/login';
          }
        },
      ),
      
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Main app routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/tasks',
        name: 'tasks',
        builder: (context, state) => const TaskListScreen(),
      ),
      GoRoute(
        path: '/tasks/create',
        name: 'task-create',
        builder: (context, state) => TaskFormScreen(),
      ),
      GoRoute(
        path: '/tasks/:id',
        name: 'task-detail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return TaskDetailScreen(taskId: id);
        },
      ),
      GoRoute(
        path: '/tasks/:id/edit',
        name: 'task-edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return TaskFormScreen(taskId: id, isEditing: true);
        },
      ),
      GoRoute(
        path: '/weather',
        name: 'weather',
        builder: (context, state) => const WeatherScreen(),
      ),
    ],
    
    // Redireccionar si no está autenticado
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(
        context,
        listen: false,
      );
      
      final isLoggedIn = authProvider.isLoggedIn;
      final isAuthPath = state.uri.toString() == '/login' || state.uri.toString() == '/register';
      
      // Si no está logueado y quiere acceder a rutas protegidas
      if (!isLoggedIn && !isAuthPath) {
        return '/login';
      }
      
      // Si está logueado y quiere ir a login/register
      if (isLoggedIn && isAuthPath) {
        return '/home';
      }
      
      return null;
    },
    
    // Error page
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
}