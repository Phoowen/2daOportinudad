import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ← AÑADE ESTE IMPORT
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:taskmaster_app/app_router.dart';
import 'package:taskmaster_app/core/theme/app_theme.dart';
import 'package:taskmaster_app/data/repositories/local_storage.dart';
import 'package:taskmaster_app/data/services/auth_service.dart';
import 'package:taskmaster_app/data/services/task_service.dart';
import 'package:taskmaster_app/data/services/weather_service.dart';
import 'package:taskmaster_app/presentation/providers/auth_provider.dart';
import 'package:taskmaster_app/presentation/providers/task_provider.dart';
import 'package:taskmaster_app/presentation/providers/weather_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await LocalStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Crear instancias de servicios
    final authService = AuthService();
    final taskService = TaskService();
    final weatherService = WeatherService(client: http.Client());
    
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (context) => AuthProvider(authService: authService),
        ),
        // Task Provider
        ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(
          create: (context) => TaskProvider(
            taskService: taskService,
            token: '',
          ),
          update: (context, authProvider, taskProvider) {
            if (taskProvider == null) {
              return TaskProvider(
                taskService: taskService,
                token: authProvider.token ?? '',
              );
            }
            
            if (authProvider.token != taskProvider.token) {
              taskProvider.token = authProvider.token ?? '';
            }
            return taskProvider;
          },
        ),
        // Weather Provider
        ChangeNotifierProvider(
          create: (context) => WeatherProvider(weatherService: weatherService),
        ),
      ],
      child: MaterialApp.router(
        title: 'TaskMaster',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        
        // ⭐⭐ AÑADE ESTAS LÍNEAS PARA LAS LOCALIZACIONES ⭐⭐
        locale: const Locale('es', 'ES'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'), // Español
          Locale('en', 'US'), // Inglés como fallback
        ],
        
        routerConfig: AppRouter.router,
      ),
    );
  }
}