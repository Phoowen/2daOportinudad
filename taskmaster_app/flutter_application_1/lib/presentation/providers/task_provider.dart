import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:taskmaster_app/data/models/task_model.dart';
import 'package:taskmaster_app/data/services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService taskService;
  String token;

  List<TaskModel> _tasks = [];
  List<TaskModel> _filteredTasks = [];
  TaskModel? _selectedTask;
  bool _isLoading = false;
  String? _error;
  String? _filterStatus;
  String? _filterPriority;
  String _searchQuery = '';

  TaskProvider({
    required this.taskService,
    required this.token,
  });

  // Getters
  List<TaskModel> get tasks => _filteredTasks;
  List<TaskModel> get allTasks => _tasks;
  TaskModel? get selectedTask => _selectedTask;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get filterStatus => _filterStatus;
  String? get filterPriority => _filterPriority;
  String get searchQuery => _searchQuery;

  // Cargar todas las tareas
  Future<void> loadTasks() async {
    // Evitar múltiples llamadas simultáneas
    if (_isLoading) return;
    
    try {
      _isLoading = true;
      _error = null;
      _notifySafe(); // Usar notificación segura

      _tasks = await taskService.getTasks(token);
      _applyFilters();
      
      _isLoading = false;
      _notifySafe();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _notifySafe();
      rethrow;
    }
  }

  // Obtener tarea por ID - VERSIÓN CORREGIDA
  Future<void> loadTaskById(int id) async {
    // Evitar múltiples llamadas simultáneas
    if (_isLoading) return;
    
    try {
      _isLoading = true;
      _error = null;
      _notifySafe(); // Notificar loading

      _selectedTask = await taskService.getTaskById(token, id);
      
      _isLoading = false;
      _notifySafe(); // Notificar éxito
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _notifySafe(); // Notificar error
      rethrow;
    }
  }

  // Crear nueva tarea
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      _isLoading = true;
      _notifySafe();

      final newTask = await taskService.createTask(token, task);
      _tasks.insert(0, newTask);
      _applyFilters();
      
      _isLoading = false;
      _notifySafe();
      return newTask;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _notifySafe();
      rethrow;
    }
  }

  // Actualizar tarea
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      _isLoading = true;
      _notifySafe();

      final updatedTask = await taskService.updateTask(token, task);
      
      // Actualizar en la lista
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
      
      _applyFilters();
      
      _isLoading = false;
      _notifySafe();
      return updatedTask;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _notifySafe();
      rethrow;
    }
  }

  // Eliminar tarea
  Future<void> deleteTask(int id) async {
    try {
      _isLoading = true;
      _notifySafe();

      await taskService.deleteTask(token, id);
      _tasks.removeWhere((task) => task.id == id);
      _applyFilters();
      
      _isLoading = false;
      _notifySafe();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _notifySafe();
      rethrow;
    }
  }

  // Filtrar tareas
  void setFilters({String? status, String? priority}) {
    _filterStatus = status;
    _filterPriority = priority;
    _applyFilters();
    _notifySafe();
  }

  // Buscar tareas
  void searchTasks(String query) {
    _searchQuery = query;
    _applyFilters();
    _notifySafe();
  }

  // Aplicar filtros
  void _applyFilters() {
    var filtered = List<TaskModel>.from(_tasks);
    
    // Filtrar por estado
    if (_filterStatus != null) {
      filtered = filtered.where((task) => task.estado.name == _filterStatus).toList();
    }
    
    // Filtrar por prioridad
    if (_filterPriority != null) {
      filtered = filtered.where((task) => task.prioridad.name == _filterPriority).toList();
    }
    
    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((task) => 
        task.titulo.toLowerCase().contains(query) ||
        task.descripcion.toLowerCase().contains(query)
      ).toList();
    }
    
    _filteredTasks = filtered;
  }

  // Limpiar filtros
  void clearFilters() {
    _filterStatus = null;
    _filterPriority = null;
    _searchQuery = '';
    _applyFilters();
    _notifySafe();
  }

  // Limpiar error
  void clearError() {
    _error = null;
    _notifySafe();
  }

  // Seleccionar tarea
  void selectTask(TaskModel? task) {
    _selectedTask = task;
    _notifySafe();
  }

  // Añade un setter para actualizar token
  void updateToken(String newToken) {
    token = newToken;
    _notifySafe();
  }
  
  // Estadísticas
  Map<String, int> getStatistics() {
    final total = _tasks.length;
    final pending = _tasks.where((t) => t.estado == Status.pendiente).length;
    final inProgress = _tasks.where((t) => t.estado == Status.en_progreso).length;
    final completed = _tasks.where((t) => t.estado == Status.hecha).length;
    final overdue = _tasks.where((t) => t.isOverdue).length;

    return {
      'total': total,
      'pending': pending,
      'inProgress': inProgress,
      'completed': completed,
      'overdue': overdue,
    };
  }

  // MÉTODO DE NOTIFICACIÓN SEGURA - Esto evita el error durante build
  void _notifySafe() {
    // Si estamos en un frame de construcción, esperar al siguiente frame
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      // Si no estamos en fase de construcción, notificar inmediatamente
      notifyListeners();
    }
  }
  
  // Método auxiliar para verificar si estamos en fase de construcción
  bool get _isInBuildPhase {
    return SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks;
  }
}