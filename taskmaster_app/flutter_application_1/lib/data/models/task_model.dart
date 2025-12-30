import 'package:flutter/material.dart';

enum Priority { alta, media, baja }
enum Status { pendiente, en_progreso, hecha }

extension PriorityExtension on Priority {
  String get name {
    switch (this) {
      case Priority.alta:
        return 'alta';
      case Priority.media:
        return 'media';
      case Priority.baja:
        return 'baja';
    }
  }
  
  String get displayName {
    switch (this) {
      case Priority.alta:
        return 'Alta';
      case Priority.media:
        return 'Media';
      case Priority.baja:
        return 'Baja';
    }
  }
  
  Color get color {
    switch (this) {
      case Priority.alta:
        return Colors.red;
      case Priority.media:
        return Colors.orange;
      case Priority.baja:
        return Colors.green;
    }
  }

  IconData get icon {
    switch (this) {
      case Priority.alta:
        return Icons.warning;
      case Priority.media:
        return Icons.info;
      case Priority.baja:
        return Icons.check_circle;
    }
  }
}

extension StatusExtension on Status {
  String get name {
    switch (this) {
      case Status.pendiente:
        return 'pendiente';
      case Status.en_progreso:
        return 'en_progreso';
      case Status.hecha:
        return 'hecha';
    }
  }
  
  String get displayName {
    switch (this) {
      case Status.pendiente:
        return 'Pendiente';
      case Status.en_progreso:
        return 'En Progreso';
      case Status.hecha:
        return 'Hecha';
    }
  }
  
  Color get color {
    switch (this) {
      case Status.pendiente:
        return Colors.grey;
      case Status.en_progreso:
        return Colors.blue;
      case Status.hecha:
        return Colors.green;
    }
  }

  IconData get icon {
    switch (this) {
      case Status.pendiente:
        return Icons.access_time;
      case Status.en_progreso:
        return Icons.autorenew;
      case Status.hecha:
        return Icons.check_circle_outline;
    }
  }
}

class TaskModel {
  final int? id;
  final int userId;
  final String titulo;
  final String descripcion;
  final Priority prioridad;
  final Status estado;
  final DateTime fechaCreacion;
  final DateTime? fechaLimite;

  TaskModel({
    this.id,
    required this.userId,
    required this.titulo,
    required this.descripcion,
    required this.prioridad,
    required this.estado,
    required this.fechaCreacion,
    this.fechaLimite,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      prioridad: _stringToPriority(json['prioridad']),
      estado: _stringToStatus(json['estado']),
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      fechaLimite: json['fecha_limite'] != null 
          ? DateTime.parse(json['fecha_limite'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'titulo': titulo,
      'descripcion': descripcion,
      'prioridad': prioridad.name,
      'estado': estado.name,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_limite': fechaLimite?.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'prioridad': prioridad.name,
      'estado': estado.name,
      'fecha_limite': fechaLimite?.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'prioridad': prioridad.name,
      'estado': estado.name,
      'fecha_limite': fechaLimite?.toIso8601String(),
    };
  }

  static Priority _stringToPriority(String priority) {
    switch (priority) {
      case 'alta':
        return Priority.alta;
      case 'media':
        return Priority.media;
      case 'baja':
        return Priority.baja;
      default:
        return Priority.media;
    }
  }

  static Status _stringToStatus(String status) {
    switch (status) {
      case 'pendiente':
        return Status.pendiente;
      case 'en_progreso':
        return Status.en_progreso;
      case 'hecha':
        return Status.hecha;
      default:
        return Status.pendiente;
    }
  }

  TaskModel copyWith({
  int? id,
  int? userId,
  String? titulo,
  String? descripcion,
  Priority? prioridad,
  Status? estado,
  DateTime? fechaCreacion,
  DateTime? fechaLimite,
}) {
  return TaskModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    titulo: titulo ?? this.titulo,
    descripcion: descripcion ?? this.descripcion,
    prioridad: prioridad ?? this.prioridad,
    estado: estado ?? this.estado,
    fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    fechaLimite: fechaLimite ?? this.fechaLimite,
  );
}

  bool get isOverdue {
    if (fechaLimite == null) return false;
    return fechaLimite!.isBefore(DateTime.now()) && estado != Status.hecha;
  }

  int get daysRemaining {
    if (fechaLimite == null) return -1;
    final now = DateTime.now();
    final difference = fechaLimite!.difference(now);
    return difference.inDays;
  }

  String get formattedDate {
    if (fechaLimite == null) return 'Sin fecha límite';
    
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    if (fechaLimite!.day == now.day && 
        fechaLimite!.month == now.month && 
        fechaLimite!.year == now.year) {
      return 'Hoy ${fechaLimite!.hour.toString().padLeft(2, '0')}:${fechaLimite!.minute.toString().padLeft(2, '0')}';
    } else if (fechaLimite!.day == tomorrow.day && 
               fechaLimite!.month == tomorrow.month && 
               fechaLimite!.year == tomorrow.year) {
      return 'Mañana ${fechaLimite!.hour.toString().padLeft(2, '0')}:${fechaLimite!.minute.toString().padLeft(2, '0')}';
    } else {
      return '${fechaLimite!.day.toString().padLeft(2, '0')}/${fechaLimite!.month.toString().padLeft(2, '0')}/${fechaLimite!.year}';
    }
  }
}