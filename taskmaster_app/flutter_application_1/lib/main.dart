import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:taskmaster_app/app_router.dart'; // Ruta corregida
import 'package:taskmaster_app/core/theme/app_theme.dart';
import 'package:taskmaster_app/data/repositories/local_storage.dart';
import 'package:taskmaster_app/data/services/auth_service.dart';
import 'package:taskmaster_app/data/services/news_service.dart';
import 'package:taskmaster_app/data/services/task_service.dart';
import 'package:taskmaster_app/data/services/weather_service.dart';
import 'package:taskmaster_app/presentation/providers/auth_provider.dart';
import 'package:taskmaster_app/presentation/providers/news_provider.dart';
import 'package:taskmaster_app/presentation/providers/task_provider.dart';
import 'package:taskmaster_app/presentation/providers/weather_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=' * 60);
  print('🚀 INICIANDO APLICACIÓN nOWte.app');
  print('=' * 60);
  
  // 1. Cargar variables de entorno
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Archivo .env cargado correctamente');
  } catch (e) {
    print('⚠️  Advertencia: No se pudo cargar .env: $e');
    print('💡 Usando valores por defecto para desarrollo');
  }
  
  // 2. Verificar variables específicas
  print('\n🔍 VERIFICANDO VARIABLES DE ENTORNO:');
  
  final openWeatherKey = dotenv.maybeGet('OPENWEATHER_API_KEY') ?? '';
  print('🌤️  OPENWEATHER_API_KEY:');
  print('   • Presente: ${openWeatherKey.isNotEmpty ? '✅' : '❌'}');
  print('   • Longitud: ${openWeatherKey.length} caracteres');
  
  if (openWeatherKey.length >= 32) {
    print('   • Formato: ✅ Válido (32+ caracteres)');
    final maskedKey = '${openWeatherKey.substring(0, 4)}...${openWeatherKey.substring(openWeatherKey.length - 4)}';
    print('   • Valor: $maskedKey');
  } else if (openWeatherKey.isNotEmpty) {
    print('   • Formato: ❌ Debe tener al menos 32 caracteres');
  } else {
    print('   • Formato: ❌ Vacía o no encontrada');
  }
  
  // NewsAPI Key - Manejo mejorado
  final newsApiKey = dotenv.maybeGet('NEWS_API_KEY') ?? '';
  print('\n📰 NEWS_API_KEY:');
  print('   • Presente: ${newsApiKey.isNotEmpty ? '✅' : '❌'}');
  print('   • Longitud: ${newsApiKey.length} caracteres');
  
  if (newsApiKey.isNotEmpty) {
    if (newsApiKey.length > 20) {
      print('   • Formato: ✅ Válido');
      final maskedKey = '${newsApiKey.substring(0, 4)}...${newsApiKey.substring(newsApiKey.length - 4)}';
      print('   • Valor: $maskedKey');
    } else {
      print('   • Formato: ❌ Demasiado corta (debe tener > 20 caracteres)');
    }
  } else {
    print('   • Formato: ⚠️  No configurada (se usarán datos de ejemplo)');
  }
  
  final apiBaseUrl = dotenv.maybeGet('API_BASE_URL') ?? 'http://localhost:3000';
  print('\n🌐 API_BASE_URL: $apiBaseUrl');
  
  print('\n' + '=' * 60);
  
  // Inicializar almacenamiento local
  try {
    await LocalStorage.init();
    print('💾 LocalStorage inicializado correctamente');
  } catch (e) {
    print('❌ Error inicializando LocalStorage: $e');
  }
  
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
    
    // Servicio de noticias - con validación
    final newsApiKey = dotenv.maybeGet('NEWS_API_KEY') ?? '';
    final newsService = NewsService(
      apiKey: newsApiKey.isNotEmpty ? newsApiKey : 'demo-key-for-dev', // Key dummy para desarrollo
    );
    
    print('🏗️  Construyendo MyApp...');
    print('🔧 WeatherService creado: ${weatherService != null}');
    print('📰 NewsService creado con clave: ${newsApiKey.isNotEmpty ? "API Real" : "Datos de ejemplo"}');
    
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
              taskProvider.updateToken(authProvider.token ?? '');
            }
            return taskProvider;
          },
        ),
        // Weather Provider
        ChangeNotifierProvider(
          create: (context) => WeatherProvider(weatherService: weatherService),
        ),
        // News Provider
        ChangeNotifierProvider(
          create: (context) => NewsProvider(newsService: newsService),
        ),
      ],
      child: MaterialApp.router(
        title: 'nOWte.app',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme, // Opcional: si tienes tema oscuro
        
        // Localizaciones
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
        
        // Router
        routerConfig: AppRouter.router,
      ),
    );
  }
}