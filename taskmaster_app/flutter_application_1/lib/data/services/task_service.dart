import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taskmaster_app/data/models/task_model.dart';

class TaskService {
  static const String _baseUrl = 'http://localhost:3000/api';
  
  // Obtener todas las tareas
  Future<List<TaskModel>> getTasks(String token) async {
    print('🔗 [GET TASKS] URL: $_baseUrl/tasks');
    print('🔑 Token: ${token.isNotEmpty ? 'Presente' : 'Ausente'}');
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        // Verificar si la respuesta está vacía
        if (response.body.trim().isEmpty) {
          print('⚠️ Respuesta vacía, devolviendo lista vacía');
          return [];
        }
        
        try {
          final data = jsonDecode(response.body);
          print('📊 Decoded Data: $data');
          
          // Manejar diferentes estructuras de respuesta
          if (data['data'] != null && data['data']['tasks'] != null) {
            final List<dynamic> tasksJson = data['data']['tasks'] ?? [];
            return tasksJson.map((json) => TaskModel.fromJson(json)).toList();
          } else if (data['tasks'] != null) {
            final List<dynamic> tasksJson = data['tasks'] ?? [];
            return tasksJson.map((json) => TaskModel.fromJson(json)).toList();
          } else if (data is List) {
            // Si la respuesta es directamente una lista
            return data.map((json) => TaskModel.fromJson(json)).toList();
          } else {
            print('⚠️ Estructura de respuesta no reconocida');
            return [];
          }
        } catch (e) {
          print('❌ Error decodificando JSON: $e');
          return [];
        }
      } else {
        print('❌ Error HTTP ${response.statusCode}: ${response.body}');
        throw Exception('Error al obtener tareas: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en getTasks: $e');
      rethrow;
    }
  }

  // Crear nueva tarea - VERSIÓN CORREGIDA
  Future<TaskModel> createTask(String token, TaskModel task) async {
    print('🔗 [CREATE TASK] URL: $_baseUrl/tasks');
    print('📦 Request Body: ${task.toCreateJson()}');
    print('🔑 Token: ${token.isNotEmpty ? 'Presente' : 'Ausente'}');
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(task.toCreateJson()),
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Verificar si la respuesta está vacía
        if (response.body.trim().isEmpty) {
          print('⚠️ Respuesta vacía, creando tarea local con ID temporal');
          // Crear tarea local con ID temporal basado en timestamp
          return task.copyWith(
            id: DateTime.now().millisecondsSinceEpoch,
          );
        }
        
        try {
          final data = jsonDecode(response.body);
          print('📊 Decoded Data: $data');
          
          // Manejar diferentes estructuras de respuesta
          if (data['data'] != null && data['data']['task'] != null) {
            return TaskModel.fromJson(data['data']['task']);
          } else if (data['task'] != null) {
            return TaskModel.fromJson(data['task']);
          } else if (data is Map<String, dynamic>) {
            // Si la respuesta es directamente la tarea
            return TaskModel.fromJson(data);
          } else {
            print('⚠️ Estructura de respuesta no reconocida, creando tarea local');
            return task.copyWith(
              id: DateTime.now().millisecondsSinceEpoch,
            );
          }
        } catch (e) {
          print('❌ Error decodificando JSON: $e');
          print('⚠️ Creando tarea local con ID temporal');
          return task.copyWith(
            id: DateTime.now().millisecondsSinceEpoch,
          );
        }
      } else {
        print('❌ Error HTTP ${response.statusCode}: ${response.body}');
        throw Exception('Error al crear tarea: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en createTask: $e');
      rethrow;
    }
  }
  
  // Obtener tarea por ID - VERSIÓN CORREGIDA
  Future<TaskModel> getTaskById(String token, int id) async {
    print('🔗 [GET TASK BY ID] URL: $_baseUrl/tasks/$id');
    print('🔑 Token: ${token.isNotEmpty ? 'Presente' : 'Ausente'}');
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/tasks/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        // Verificar si la respuesta está vacía
        if (response.body.trim().isEmpty) {
          print('❌ Respuesta vacía para la tarea ID: $id');
          throw Exception('Tarea no encontrada');
        }
        
        try {
          final data = jsonDecode(response.body);
          print('📊 Decoded Data: $data');
          
          // Manejar diferentes estructuras de respuesta
          if (data['data'] != null && data['data']['task'] != null) {
            return TaskModel.fromJson(data['data']['task']);
          } else if (data['task'] != null) {
            return TaskModel.fromJson(data['task']);
          } else if (data is Map<String, dynamic>) {
            return TaskModel.fromJson(data);
          } else {
            print('⚠️ Estructura de respuesta no reconocida');
            throw Exception('Formato de respuesta inválido');
          }
        } catch (e) {
          print('❌ Error decodificando JSON: $e');
          throw Exception('Error al procesar la respuesta del servidor');
        }
      } else {
        print('❌ Error HTTP ${response.statusCode}: ${response.body}');
        throw Exception('Error al obtener tarea: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en getTaskById: $e');
      rethrow;
    }
  }

  // Actualizar tarea - VERSIÓN CORREGIDA
  Future<TaskModel> updateTask(String token, TaskModel task) async {
    print('🔗 [UPDATE TASK] URL: $_baseUrl/tasks/${task.id}');
    print('📦 Request Body: ${task.toUpdateJson()}');
    print('🔑 Token: ${token.isNotEmpty ? 'Presente' : 'Ausente'}');
    
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/tasks/${task.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(task.toUpdateJson()),
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        // Verificar si la respuesta está vacía
        if (response.body.trim().isEmpty) {
          print('⚠️ Respuesta vacía, devolviendo tarea original');
          return task;
        }
        
        try {
          final data = jsonDecode(response.body);
          print('📊 Decoded Data: $data');
          
          // Manejar diferentes estructuras de respuesta
          if (data['data'] != null && data['data']['task'] != null) {
            return TaskModel.fromJson(data['data']['task']);
          } else if (data['task'] != null) {
            return TaskModel.fromJson(data['task']);
          } else if (data is Map<String, dynamic>) {
            return TaskModel.fromJson(data);
          } else {
            print('⚠️ Estructura de respuesta no reconocida, devolviendo tarea original');
            return task;
          }
        } catch (e) {
          print('❌ Error decodificando JSON: $e');
          print('⚠️ Devolviendo tarea original');
          return task;
        }
      } else {
        print('❌ Error HTTP ${response.statusCode}: ${response.body}');
        throw Exception('Error al actualizar tarea: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en updateTask: $e');
      rethrow;
    }
  }

  // Eliminar tarea
  Future<bool> deleteTask(String token, int id) async {
    print('🔗 [DELETE TASK] URL: $_baseUrl/tasks/$id');
    print('🔑 Token: ${token.isNotEmpty ? 'Presente' : 'Ausente'}');
    
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/tasks/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('❌ Error HTTP ${response.statusCode}: ${response.body}');
        throw Exception('Error al eliminar tarea: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en deleteTask: $e');
      rethrow;
    }
  }

  // Filtrar tareas
  Future<List<TaskModel>> filterTasks(
    String token, {
    String? status,
    String? priority,
  }) async {
    String url = '$_baseUrl/tasks?';
    
    if (status != null) url += 'estado=$status&';
    if (priority != null) url += 'prioridad=$priority&';
    
    // Eliminar último & si existe
    if (url.endsWith('&')) url = url.substring(0, url.length - 1);
    
    print('🔗 [FILTER TASKS] URL: $url');
    print('🔑 Token: ${token.isNotEmpty ? 'Presente' : 'Ausente'}');
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        // Verificar si la respuesta está vacía
        if (response.body.trim().isEmpty) {
          print('⚠️ Respuesta vacía, devolviendo lista vacía');
          return [];
        }
        
        try {
          final data = jsonDecode(response.body);
          print('📊 Decoded Data: $data');
          
          // Manejar diferentes estructuras de respuesta
          if (data['data'] != null && data['data']['tasks'] != null) {
            final List<dynamic> tasksJson = data['data']['tasks'] ?? [];
            return tasksJson.map((json) => TaskModel.fromJson(json)).toList();
          } else if (data['tasks'] != null) {
            final List<dynamic> tasksJson = data['tasks'] ?? [];
            return tasksJson.map((json) => TaskModel.fromJson(json)).toList();
          } else if (data is List) {
            return data.map((json) => TaskModel.fromJson(json)).toList();
          } else {
            print('⚠️ Estructura de respuesta no reconocida');
            return [];
          }
        } catch (e) {
          print('❌ Error decodificando JSON: $e');
          return [];
        }
      } else {
        print('❌ Error HTTP ${response.statusCode}: ${response.body}');
        throw Exception('Error al filtrar tareas: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en filterTasks: $e');
      rethrow;
    }
  }
}