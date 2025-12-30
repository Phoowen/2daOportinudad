import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:taskmaster_app/data/models/task_model.dart';
import 'package:taskmaster_app/presentation/providers/task_provider.dart';
import 'package:taskmaster_app/presentation/widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedPriority;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final taskProvider = context.read<TaskProvider>();
    await taskProvider.loadTasks();
  }

  void _applyFilters() {
    final taskProvider = context.read<TaskProvider>();
    taskProvider.setFilters(
      status: _selectedStatus,
      priority: _selectedPriority,
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedPriority = null;
      _searchController.clear();
    });
    
    final taskProvider = context.read<TaskProvider>();
    taskProvider.clearFilters();
    taskProvider.searchTasks('');
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTasks,
        child: Column(
          children: [
            // Filtros
            _buildFiltersSection(),
            
            // Lista de tareas
            Expanded(
              child: _buildTaskList(taskProvider),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/tasks/create'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Tarea'),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar tareas...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<TaskProvider>().searchTasks('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              context.read<TaskProvider>().searchTasks(value);
            },
          ),
          const SizedBox(height: 12),
          
          // Filtros rápidos
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'Todos',
                  _selectedStatus == null && _selectedPriority == null,
                  onSelected: (_) => _clearFilters(),
                ),
                _buildFilterChip(
                  'Pendientes',
                  _selectedStatus == 'pendiente',
                  onSelected: (_) {
                    setState(() {
                      _selectedStatus = 'pendiente';
                      _selectedPriority = null;
                    });
                    _applyFilters();
                  },
                ),
                _buildFilterChip(
                  'En Progreso',
                  _selectedStatus == 'en_progreso',
                  onSelected: (_) {
                    setState(() {
                      _selectedStatus = 'en_progreso';
                      _selectedPriority = null;
                    });
                    _applyFilters();
                  },
                ),
                _buildFilterChip(
                  'Completadas',
                  _selectedStatus == 'hecha',
                  onSelected: (_) {
                    setState(() {
                      _selectedStatus = 'hecha';
                      _selectedPriority = null;
                    });
                    _applyFilters();
                  },
                ),
                _buildFilterChip(
                  'Alta Prioridad',
                  _selectedPriority == 'alta',
                  color: Colors.red,
                  onSelected: (_) {
                    setState(() {
                      _selectedStatus = null;
                      _selectedPriority = 'alta';
                    });
                    _applyFilters();
                  },
                ),
                _buildFilterChip(
                  'Urgentes',
                  false,
                  color: Colors.red,
                  icon: Icons.warning,
                  onSelected: (_) {
                    // Filtrar tareas con fecha límite cercana
                    // Implementación avanzada
                  },
                ),
              ],
            ),
          ),
          
          // Filtros avanzados (expandible)
          ExpansionTile(
            title: const Text('Filtros avanzados'),
            initiallyExpanded: false,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Todos los estados'),
                        ),
                        ...Status.values.map((status) {
                          return DropdownMenuItem(
                            value: status.name,
                            child: Row(
                              children: [
                                Icon(
                                  status.icon,
                                  color: status.color,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(status.displayName),
                              ],
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Prioridad',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Todas las prioridades'),
                        ),
                        ...Priority.values.map((priority) {
                          return DropdownMenuItem(
                            value: priority.name,
                            child: Row(
                              children: [
                                Icon(
                                  priority.icon,
                                  color: priority.color,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(priority.displayName),
                              ],
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedPriority = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearFilters,
                      child: const Text('Limpiar filtros'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool selected, {
    Color? color,
    IconData? icon,
    ValueChanged<bool>? onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: selected ? Colors.white : color),
              const SizedBox(width: 4),
            ],
            Text(label),
          ],
        ),
        selected: selected,
        onSelected: onSelected,
        backgroundColor: color?.withOpacity(0.1) ?? Colors.grey.shade200,
        selectedColor: color ?? Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: selected ? Colors.white : color ?? Colors.black,
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildTaskList(TaskProvider taskProvider) {
    if (taskProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (taskProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${taskProvider.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTasks,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (taskProvider.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.task_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty ||
                      _selectedStatus != null ||
                      _selectedPriority != null
                  ? 'No hay tareas con esos filtros'
                  : 'No hay tareas creadas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty ||
                      _selectedStatus != null ||
                      _selectedPriority != null
                  ? 'Prueba con otros filtros o crea una nueva tarea'
                  : '¡Crea tu primera tarea!',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/tasks/create'),
              icon: const Icon(Icons.add),
              label: const Text('Crear primera tarea'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: taskProvider.tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = taskProvider.tasks[index];
        return TaskCard(
          task: task,
          onTap: () => context.go('/tasks/${task.id}'),
          showActions: true,
        );
      },
    );
  }
}