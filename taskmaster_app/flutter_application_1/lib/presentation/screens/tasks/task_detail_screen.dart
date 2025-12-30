import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:taskmaster_app/data/models/task_model.dart';
import 'package:taskmaster_app/presentation/providers/task_provider.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TaskProvider _taskProvider;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _taskProvider = context.read<TaskProvider>();
    _loadTask();
  }

  Future<void> _loadTask() async {
    try {
      setState(() => _isLoading = true);
      await _taskProvider.loadTaskById(widget.taskId);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _changeStatus(Status newStatus) async {
    final task = _taskProvider.selectedTask;
    if (task == null) return;

    try {
      setState(() => _isLoading = true);
      
      final updatedTask = task.copyWith(estado: newStatus);
      await _taskProvider.updateTask(updatedTask);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estado actualizado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = context.watch<TaskProvider>().selectedTask;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Tarea'),
        actions: [
          if (task != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.go('/tasks/${task.id}/edit'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : task == null
              ? const Center(child: Text('Tarea no encontrada'))
              : _buildTaskDetail(task),
    );
  }

  Widget _buildTaskDetail(TaskModel task) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título y prioridad
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.titulo,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: task.prioridad.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: task.prioridad.color.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                task.prioridad.icon,
                                size: 16,
                                color: task.prioridad.color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                task.prioridad.displayName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: task.prioridad.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (task.isOverdue)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, size: 16, color: Colors.red),
                      SizedBox(width: 6),
                      Text(
                        'VENCIDA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Estado (con opción de cambiar)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estado',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: Status.values.map((status) {
                      final isSelected = task.estado == status;
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(status.icon, size: 16),
                            const SizedBox(width: 6),
                            Text(status.displayName),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: isSelected
                            ? null
                            : (_) => _changeStatus(status),
                        backgroundColor: isSelected
                            ? status.color
                            : status.color.withOpacity(0.1),
                        selectedColor: status.color,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : status.color,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Descripción
          if (task.descripcion.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descripción',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      task.descripcion,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Información de fechas
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Fecha de creación',
                    DateFormat('dd/MM/yyyy HH:mm').format(task.fechaCreacion),
                  ),
                  const SizedBox(height: 12),
                  if (task.fechaLimite != null)
                    _buildInfoRow(
                      Icons.timer,
                      'Fecha límite',
                      DateFormat('dd/MM/yyyy HH:mm').format(task.fechaLimite!),
                      isOverdue: task.isOverdue,
                    ),
                  if (task.fechaLimite == null)
                    _buildInfoRow(
                      Icons.timer_off,
                      'Fecha límite',
                      'Sin fecha límite',
                    ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.update,
                    'Tiempo restante',
                    task.daysRemaining >= 0
                        ? '${task.daysRemaining} días'
                        : 'Sin fecha límite',
                    color: task.isOverdue ? Colors.red : Colors.green,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Acciones rápidas
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/tasks/${task.id}/edit'),
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Marcar como completada si no lo está
                    if (task.estado != Status.hecha) {
                      _changeStatus(Status.hecha);
                    } else {
                      context.go('/tasks');
                    }
                  },
                  icon: const Icon(Icons.check_circle),
                  label: Text(
                    task.estado == Status.hecha ? 'Volver a lista' : 'Completar',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String title,
    String value, {
    Color? color,
    bool isOverdue = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isOverdue ? Colors.red : color ?? Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}