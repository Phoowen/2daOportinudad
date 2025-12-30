import 'package:flutter/foundation.dart';
import 'package:taskmaster_app/data/models/user_model.dart';
import 'package:taskmaster_app/data/services/auth_service.dart';
import 'package:taskmaster_app/data/repositories/local_storage.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;
  
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  AuthProvider({required this.authService}) {
    _loadStoredData();
  }

  // Getters
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _token != null && _user != null;

  // Cargar datos almacenados
  Future<void> _loadStoredData() async {
    _token = LocalStorage.getToken();
    _user = LocalStorage.getUser();
    notifyListeners();
  }

  // Registrar usuario
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await authService.register(
        username: username,
        email: email,
        password: password,
      );

      // Guardar datos
      await LocalStorage.saveToken(response.token);
      await LocalStorage.saveUser(response.user);
      
      _token = response.token;
      _user = response.user;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await authService.login(
        email: email,
        password: password,
      );

      // Guardar datos
      await LocalStorage.saveToken(response.token);
      await LocalStorage.saveUser(response.user);
      
      _token = response.token;
      _user = response.user;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await LocalStorage.clearAll();
    _token = null;
    _user = null;
    _error = null;
    notifyListeners();
  }

  // Obtener perfil
  Future<bool> getProfile() async {
    try {
      if (_token == null) return false;
      
      _isLoading = true;
      notifyListeners();

      final user = await authService.getProfile(_token!);
      await LocalStorage.saveUser(user);
      
      _user = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      // Si el token es inválido, hacer logout
      if (e.toString().contains('401') || e.toString().contains('token')) {
        await logout();
      }
      return false;
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Verificar sesión activa
  Future<bool> checkAuth() async {
    if (_token == null || _user == null) return false;
    
    try {
      await getProfile();
      return true;
    } catch (e) {
      return false;
    }
  }
}