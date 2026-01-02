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
import 'package:taskmaster_app/presentation/screens/news/news_screen.dart';
// Si creaste la pantalla de detalle de noticias, descomenta esta línea:
// import 'package:taskmaster_app/presentation/screens/news/news_detail_screen.dart';

class AppRouter {
  static GoRouter get router => _router;

  // Rutas públicas (no requieren autenticación)
  static const List<String> publicRoutes = [
    '/',
    '/login',
    '/register',
  ];

  // Rutas protegidas (requieren autenticación)
  static const List<String> protectedRoutes = [
    '/home',
    '/tasks',
    '/tasks/create',
    '/tasks/:id',
    '/tasks/:id/edit',
    '/weather',
    '/news', // NUEVA RUTA PROTEGIDA
    // '/news/:id', // Para futuro si implementas detalle de noticia
  ];

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
      
      // ============ RUTAS DE AUTENTICACIÓN ============
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
      
      // ============ RUTAS PRINCIPALES DE LA APP ============
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // ============ RUTAS DE TAREAS ============
      GoRoute(
        path: '/tasks',
        name: 'tasks',
        builder: (context, state) => const TaskListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'task-create',
            builder: (context, state) => TaskFormScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'task-detail',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return TaskDetailScreen(taskId: id);
            },
          ),
          GoRoute(
            path: ':id/edit',
            name: 'task-edit',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return TaskFormScreen(taskId: id, isEditing: true);
            },
          ),
        ],
      ),
      
      // ============ RUTA DE CLIMA ============
      GoRoute(
        path: '/weather',
        name: 'weather',
        builder: (context, state) => const WeatherScreen(),
      ),
      
      // ============ RUTA DE NOTICIAS (NUEVA) ============
      GoRoute(
        path: '/news',
        name: 'news',
        builder: (context, state) => const NewsScreen(),
        // Rutas anidadas para futuro:
        // routes: [
        //   GoRoute(
        //     path: 'detail/:id',
        //     name: 'news-detail',
        //     builder: (context, state) {
        //       final articleId = state.pathParameters['id']!;
        //       // Aquí pasarías el artículo como extra o lo cargarías
        //       return NewsDetailScreen(articleId: articleId);
        //     },
        //   ),
        //   GoRoute(
        //     path: 'category/:category',
        //     name: 'news-category',
        //     builder: (context, state) {
        //       final category = state.pathParameters['category']!;
        //       return NewsScreen(initialCategory: category);
        //     },
        //   ),
        // ],
      ),
      
      // ============ RUTAS ADICIONALES ============
      // Puedes agregar más rutas aquí según necesites
    ],
    
    // ============ MIDDLEWARE DE AUTENTICACIÓN ============
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(
        context,
        listen: false,
      );
      
      final isLoggedIn = authProvider.isLoggedIn;
      final currentPath = state.uri.toString();
      
      // Verificar si la ruta actual es pública
      final isPublicRoute = publicRoutes.any((route) {
        // Manejar rutas con parámetros dinámicos
        if (route.contains(':')) {
          final pattern = RegExp(route.replaceAll(':id', r'(\d+)'));
          return pattern.hasMatch(currentPath);
        }
        return currentPath == route;
      });
      
      // Verificar si la ruta actual es protegida
      final isProtectedRoute = protectedRoutes.any((route) {
        // Manejar rutas con parámetros dinámicos
        if (route.contains(':')) {
          final pattern = RegExp(route.replaceAll(':id', r'(\d+)'));
          return pattern.hasMatch(currentPath);
        }
        return currentPath == route;
      });
      
      // Lógica de redirección
      
      // 1. Usuario NO logueado intentando acceder a ruta protegida
      if (!isLoggedIn && isProtectedRoute) {
        print('🔐 Redirigiendo a login: Usuario no autenticado intentando acceder a $currentPath');
        return '/login';
      }
      
      // 2. Usuario logueado intentando acceder a login/register
      if (isLoggedIn && (currentPath == '/login' || currentPath == '/register')) {
        print('🔐 Redirigiendo a home: Usuario autenticado intentando acceder a $currentPath');
        return '/home';
      }
      
      // 3. Usuario logueado en ruta raíz
      if (isLoggedIn && currentPath == '/') {
        return '/home';
      }
      
      // 4. Usuario no logueado en ruta raíz
      if (!isLoggedIn && currentPath == '/') {
        return '/login';
      }
      
      // Permitir acceso a todas las demás rutas
      return null;
    },
    
    // ============ MANEJO DE ERRORES ============
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Página no encontrada',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'La página que intentas acceder no existe o ha sido movida.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Error: ${state.error}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.home),
                    label: const Text('Ir al inicio'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver atrás'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    
    // ============ CONFIGURACIONES ADICIONALES ============
    //debugLogDiagnostics: true, // Mantener en true para desarrollo
    //refreshListenable: GoRouterRefreshStream(
      // Si tienes un stream de autenticación, puedes usarlo aquí
      // Por ejemplo: authProvider.authStateChanges
    //),
  );
}

// Clase auxiliar para refrescar el router cuando cambia el estado de autenticación
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.listen((_) => notifyListeners());
  }
}

// Extensión para facilitar la navegación
extension GoRouterExtension on GoRouter {
  // Navegar a noticias con categoría específica
  void goToNews({String? category}) {
    if (category != null) {
      // En el futuro podrías navegar a /news/category/:category
      go('/news');
    } else {
      go('/news');
    }
  }
  
  // Verificar si la ruta actual es protegida
  bool isProtectedRoute(String path) {
    return AppRouter.protectedRoutes.any((route) {
      if (route.contains(':')) {
        final pattern = RegExp(route.replaceAll(':id', r'(\d+)'));
        return pattern.hasMatch(path);
      }
      return path == route;
    });
  }
}