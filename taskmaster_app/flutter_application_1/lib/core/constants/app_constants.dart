class AppConstants {
  // Nombres de rutas
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String tasksRoute = '/tasks';
  static const String taskDetailRoute = '/tasks/:id';
  static const String taskCreateRoute = '/tasks/create';
  static const String taskEditRoute = '/tasks/:id/edit';
  static const String weatherRoute = '/weather';
  static const String profileRoute = '/profile';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';

  // Tiempos
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration splashDuration = Duration(seconds: 2);

  // Validación
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
}