import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:taskmaster_app/data/models/task_model.dart';
import 'package:taskmaster_app/presentation/providers/task_provider.dart';
import 'package:taskmaster_app/presentation/utils/date_picker_helper.dart';

class TaskFormScreen extends StatefulWidget {
  final int? taskId;
  final bool isEditing;

  const TaskFormScreen({
    super.key,
    this.taskId,
    this.isEditing = false,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  Priority _selectedPriority = Priority.media;
  Status _selectedStatus = Status.pendiente;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  
  bool _isLoading = false;
  String? _error;
  bool _initialLoadComplete = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isEditing && widget.taskId != null) {
        _loadTask();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_initialLoadComplete && widget.isEditing && widget.taskId != null) {
      _loadTask();
      _initialLoadComplete = true;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _loadTask() async {
    try {
      setState(() => _isLoading = true);
      
      final taskProvider = context.read<TaskProvider>();
      await taskProvider.loadTaskById(widget.taskId!);
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      final task = taskProvider.selectedTask;
      if (task != null && mounted) {
        setState(() {
          _tituloController.text = task.titulo;
          _descripcionController.text = task.descripcion;
          _selectedPriority = task.prioridad;
          _selectedStatus = task.estado;
          _selectedDate = task.fechaLimite;
          if (task.fechaLimite != null) {
            _selectedTime = TimeOfDay.fromDateTime(task.fechaLimite!);
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  // ⭐⭐ MÉTODO MODIFICADO - Usa DatePickerHelper ⭐⭐
  Future<void> _selectDate(BuildContext context) async {
    final initialDate = _selectedDate ?? DateTime.now();
    final firstDate = DateTime.now().subtract(const Duration(days: 365));
    final lastDate = DateTime.now().add(const Duration(days: 365 * 5));

    final pickedDate = await DatePickerHelper.showDatePickerDialog(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('es', 'ES'),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        _selectedDate = pickedDate;
        _hasChanges = true;
      });
    }
  }

  // ⭐⭐ MÉTODO MODIFICADO - Usa DatePickerHelper ⭐⭐
  Future<void> _selectTime(BuildContext context) async {
    final initialTime = _selectedTime ?? const TimeOfDay(hour: 12, minute: 0);

    final pickedTime = await DatePickerHelper.showTimePickerDialog(
      context: context,
      initialTime: initialTime,
      locale: const Locale('es', 'ES'),
    );

    if (pickedTime != null && mounted) {
      setState(() {
        _selectedTime = pickedTime;
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    DateTime? fechaLimite;
    if (_selectedDate != null) {
      if (_selectedTime != null) {
        fechaLimite = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
      } else {
        fechaLimite = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          23,
          59,
        );
      }
    }

    final task = TaskModel(
      id: widget.isEditing ? widget.taskId : null,
      userId: 1,
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      prioridad: _selectedPriority,
      estado: _selectedStatus,
      fechaCreacion: DateTime.now(),
      fechaLimite: fechaLimite,
    );

    try {
      setState(() => _isLoading = true);
      
      final taskProvider = context.read<TaskProvider>();
      
      if (widget.isEditing) {
        await taskProvider.updateTask(task);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tarea actualizada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await taskProvider.createTask(task);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tarea creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      
      if (mounted) {
        context.go('/tasks');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _checkForChanges() {
    final taskProvider = context.read<TaskProvider>();
     final originalTask = widget.isEditing && widget.taskId != null
      ? taskProvider.tasks.firstWhere(
          (task) => task.id == widget.taskId,
          orElse: () => TaskModel(
            id: 0,
            userId: 0,
            titulo: '',
            descripcion: '',
            prioridad: Priority.media,
            estado: Status.pendiente,
            fechaCreacion: DateTime.now(),
          ),
        )
      : null;

    if (originalTask == null) {
      _hasChanges = _tituloController.text.isNotEmpty ||
          _descripcionController.text.isNotEmpty ||
          _selectedPriority != Priority.media ||
          _selectedStatus != Status.pendiente ||
          _selectedDate != null;
    } else {
      _hasChanges = _tituloController.text != originalTask.titulo ||
          _descripcionController.text != originalTask.descripcion ||
          _selectedPriority != originalTask.prioridad ||
          _selectedStatus != originalTask.estado ||
          _selectedDate != originalTask.fechaLimite ||
          (_selectedDate != null && _selectedTime != null &&
              TimeOfDay.fromDateTime(originalTask.fechaLimite!) != _selectedTime);
    }
  }

  Future<bool> _onWillPop() async {
    _checkForChanges();
    
    if (_hasChanges) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Descartar cambios?'),
          content: const Text('Tienes cambios sin guardar. ¿Estás seguro de que quieres salir?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Descartar'),
            ),
          ],
        ),
      );
      
      return result ?? false;
    }
    
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // ⭐⭐ BOTÓN DE BACK AGREGADO ⭐⭐
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) {
                context.pop();
              }
            },
          ),
          title: Text(widget.isEditing ? 'Editar Tarea' : 'Nueva Tarea'),
          actions: [
            if (widget.isEditing)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _showDeleteDialog,
                tooltip: 'Eliminar tarea',
              ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveTask,
              tooltip: 'Guardar tarea',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        onChanged: () {
          if (mounted) {
            setState(() {
              _hasChanges = true;
            });
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Título *',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                hintText: 'Ej: Revisar informe mensual',
                border: OutlineInputBorder(),
              ),
              maxLength: 200,
              onChanged: (_) => _hasChanges = true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El título es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            Text(
              'Descripción',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                hintText: 'Descripción detallada de la tarea...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              maxLength: 1000,
              keyboardType: TextInputType.multiline,
              onChanged: (_) => _hasChanges = true,
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prioridad',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Priority>(
                        value: _selectedPriority,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: Priority.values.map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Row(
                              children: [
                                Icon(
                                  priority.icon,
                                  color: priority.color,
                                ),
                                const SizedBox(width: 8),
                                Text(priority.displayName),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedPriority = value;
                              _hasChanges = true;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estado',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Status>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: Status.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Row(
                              children: [
                                Icon(
                                  status.icon,
                                  color: status.color,
                                ),
                                const SizedBox(width: 8),
                                Text(status.displayName),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedStatus = value;
                              _hasChanges = true;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(
                          'Fecha Límite',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (_selectedDate != null)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = null;
                                _selectedTime = null;
                                _hasChanges = true;
                              });
                            },
                            child: const Text('Eliminar'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selectDate(context),
                            icon: const Icon(Icons.calendar_month),
                            label: Text(
                              _selectedDate != null
                                  ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                                  : 'Seleccionar fecha',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (_selectedDate != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _selectTime(context),
                              icon: const Icon(Icons.access_time),
                              label: Text(
                                _selectedTime != null
                                    ? _selectedTime!.format(context)
                                    : 'Sin hora',
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    if (_selectedDate != null && _selectedTime != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Fecha completa: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime(
                          _selectedDate!.year,
                          _selectedDate!.month,
                          _selectedDate!.day,
                          _selectedTime!.hour,
                          _selectedTime!.minute,
                        ))}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final shouldPop = await _onWillPop();
                      if (shouldPop && mounted) {
                        context.go('/tasks');
                      }
                    },
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveTask,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(widget.isEditing ? 'Actualizar' : 'Crear Tarea'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tarea'),
        content: const Text('¿Estás seguro de que quieres eliminar esta tarea? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteTask();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask() async {
    if (widget.taskId == null) return;
    
    try {
      setState(() => _isLoading = true);
      
      final taskProvider = context.read<TaskProvider>();
      await taskProvider.deleteTask(widget.taskId!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarea eliminada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/tasks');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }
}