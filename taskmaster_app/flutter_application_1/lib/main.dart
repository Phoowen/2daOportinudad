import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:taskmaster_app/app_router.dart';
import 'package:taskmaster_app/core/theme/app_theme.dart';
import 'package:taskmaster_app/data/repositories/local_storage.dart';
import 'package:taskmaster_app/data/services/auth_service.dart';
import 'package:taskmaster_app/data/services/news_service.dart'; // NUEVO IMPORT
import 'package:taskmaster_app/data/services/task_service.dart';
import 'package:taskmaster_app/data/services/weather_service.dart';
import 'package:taskmaster_app/presentation/providers/auth_provider.dart';
import 'package:taskmaster_app/presentation/providers/news_provider.dart'; // NUEVO IMPORT
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
    print('❌ Error cargando .env: $e');
  }
  
  // 2. Verificar variables específicas
  print('\n🔍 VERIFICANDO VARIABLES DE ENTORNO:');
  
  final openWeatherKey = dotenv.get('OPENWEATHER_API_KEY', fallback: 'NO_ENCONTRADA');
  print('🌤️  OPENWEATHER_API_KEY:');
  print('   • Presente: ${openWeatherKey != 'NO_ENCONTRADA' ? '✅' : '❌'}');
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
  
  // NUEVO: Verificar NewsAPI Key
  final newsApiKey = dotenv.get('NEWS_API_KEY', fallback: 'NO_ENCONTRADA');
  print('\n📰 NEWS_API_KEY:');
  print('   • Presente: ${newsApiKey != 'NO_ENCONTRADA' ? '✅' : '❌'}');
  print('   • Longitud: ${newsApiKey.length} caracteres');
  
  if (newsApiKey.length > 20) {
    print('   • Formato: ✅ Válido');
    final maskedKey = '${newsApiKey.substring(0, 4)}...${newsApiKey.substring(newsApiKey.length - 4)}';
    print('   • Valor: $maskedKey');
  } else if (newsApiKey.isNotEmpty) {
    print('   • Formato: ❌ Demasiado corta');
  } else {
    print('   • Formato: ❌ Vacía o no encontrada');
  }
  
  final apiBaseUrl = dotenv.get('API_BASE_URL', fallback: 'NO_ENCONTRADA');
  print('\n🌐 API_BASE_URL: $apiBaseUrl');
  
  print('\n' + '=' * 60);
  
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
    
    // NUEVO: Servicio de noticias
    final newsService = NewsService(
      apiKey: dotenv.get('NEWS_API_KEY', fallback: ''),
    );
    
    print('🏗️  Construyendo MyApp...');
    print('🔧 WeatherService creado: ${weatherService != null}');
    print('📰 NewsService creado: ${newsService != null}');
    
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
        // NUEVO: News Provider
        ChangeNotifierProvider(
          create: (context) => NewsProvider(newsService: newsService),
        ),
      ],
      child: MaterialApp.router(
        title: 'nOWte.app',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        
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
        
        routerConfig: AppRouter.router,
      ),
    );
  }
}