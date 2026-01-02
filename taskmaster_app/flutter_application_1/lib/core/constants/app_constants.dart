class AppConstants {
  // ============ RUTAS DE NAVEGACIÓN ============
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String tasksRoute = '/tasks';
  static const String taskDetailRoute = '/tasks/:id';
  static const String taskCreateRoute = '/tasks/create';
  static const String taskEditRoute = '/tasks/:id/edit';
  static const String weatherRoute = '/weather';
  static const String profileRoute = '/profile';
  static const String newsRoute = '/news'; // NUEVA

  // ============ CLAVES DE ALMACENAMIENTO ============
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';
  
  // NUEVO: Para noticias
  static const String newsCategoryKey = 'news_category';
  static const String newsCountryKey = 'news_country';

  // ============ CONFIGURACIÓN DE UI ============
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration splashDuration = Duration(seconds: 2);
  
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Breakpoints para responsive design
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // ============ CACHÉ ============
  static const Duration imageCacheDuration = Duration(days: 7);
  static const Duration newsCacheDuration = Duration(minutes: 15);
  static const Duration weatherCacheDuration = Duration(minutes: 10);
  
  // ============ VALIDACIÓN ============
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int maxTaskTitleLength = 100;
  static const int maxTaskDescriptionLength = 500;

  // ============ MENSAJES Y TEXTO ============
  static const String appName = 'TaskMaster';
  static const String appTagline = 'Gestiona tus tareas, clima y noticias';
  
  // Mensajes de error comunes
  static const String networkErrorMessage = 'Error de conexión. Verifica tu internet.';
  static const String serverErrorMessage = 'Error del servidor. Intenta más tarde.';
  static const String unauthorizedErrorMessage = 'Sesión expirada. Inicia sesión nuevamente.';
  static const String unknownErrorMessage = 'Algo salió mal. Intenta nuevamente.';

  // ============ ESTADOS DE TAREAS ============
  static const String taskStatusPending = 'pending';
  static const String taskStatusInProgress = 'in_progress';
  static const String taskStatusCompleted = 'completed';
  
  // Nombres amigables de estados
  static Map<String, String> get taskStatusDisplayNames {
    return {
      taskStatusPending: 'Pendiente',
      taskStatusInProgress: 'En Progreso',
      taskStatusCompleted: 'Completada',
    };
  }
}