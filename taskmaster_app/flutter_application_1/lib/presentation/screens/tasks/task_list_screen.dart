import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:taskmaster_app/core/theme/app_theme.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        // ⭐⭐ BOTÓN DE BACK CON COLORES DEL TEMA ⭐⭐
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppTheme.textPrimaryDark : Colors.white,
          ),
          onPressed: () => context.go('/home'),
          tooltip: 'Volver al inicio',
        ),
        title: const Text('Mis Tareas'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: _loadTasks,
            tooltip: 'Actualizar tareas',
          ),
          // Opcional: Botón para limpiar filtros rápidamente
          if (_selectedStatus != null || _selectedPriority != null || _searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.filter_alt_off,
                color: Colors.white,
              ),
              onPressed: _clearFilters,
              tooltip: 'Limpiar filtros',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTasks,
        color: AppTheme.primaryColor,
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        child: Column(
          children: [
            // Filtros
            _buildFiltersSection(isDark),
            
            // Lista de tareas
            Expanded(
              child: _buildTaskList(taskProvider, isDark),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/tasks/create'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Tarea'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildFiltersSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : AppTheme.getCardShadow(isDark: isDark),
      ),
      child: Column(
        children: [
          // Barra de búsqueda
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar tareas...',
                hintStyle: TextStyle(
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.primaryColor,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppTheme.errorColor,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          context.read<TaskProvider>().searchTasks('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: TextStyle(
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              ),
              onChanged: (value) {
                context.read<TaskProvider>().searchTasks(value);
              },
            ),
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
                  isDark: isDark,
                ),
                _buildFilterChip(
                  'Pendientes',
                  _selectedStatus == 'pendiente',
                  color: AppTheme.getStatusColor('pendiente', isDark: isDark),
                  onSelected: (_) {
                    setState(() {
                      _selectedStatus = 'pendiente';
                      _selectedPriority = null;
                    });
                    _applyFilters();
                  },
                  isDark: isDark,
                ),
                _buildFilterChip(
                  'En Progreso',
                  _selectedStatus == 'en_progreso',
                  color: AppTheme.getStatusColor('en_progreso', isDark: isDark),
                  onSelected: (_) {
                    setState(() {
                      _selectedStatus = 'en_progreso';
                      _selectedPriority = null;
                    });
                    _applyFilters();
                  },
                  isDark: isDark,
                ),
                _buildFilterChip(
                  'Completadas',
                  _selectedStatus == 'completada',
                  color: AppTheme.getStatusColor('completada', isDark: isDark),
                  onSelected: (_) {
                    setState(() {
                      _selectedStatus = 'completada';
                      _selectedPriority = null;
                    });
                    _applyFilters();
                  },
                  isDark: isDark,
                ),
                _buildFilterChip(
                  'Alta Prioridad',
                  _selectedPriority == 'alta',
                  color: AppTheme.getPriorityColor('alta', isDark: isDark),
                  onSelected: (_) {
                    setState(() {
                      _selectedStatus = null;
                      _selectedPriority = 'alta';
                    });
                    _applyFilters();
                  },
                  isDark: isDark,
                ),
                _buildFilterChip(
                  'Urgentes',
                  false,
                  color: AppTheme.errorColor,
                  icon: Icons.warning,
                  onSelected: (_) {
                    // Filtrar tareas con fecha límite cercana
                    // Implementación avanzada
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),
          
          // Filtros avanzados (expandible)
          Card(
            color: isDark ? AppTheme.cardDark : Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              title: Text(
                'Filtros avanzados',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                ),
              ),
              collapsedIconColor: AppTheme.primaryColor,
              iconColor: AppTheme.primaryColor,
              initiallyExpanded: false,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              decoration: InputDecoration(
                                labelText: 'Estado',
                                labelStyle: TextStyle(
                                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                                ),
                                filled: true,
                                fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppTheme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              dropdownColor: isDark ? AppTheme.cardDark : Colors.white,
                              style: TextStyle(
                                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(
                                    'Todos los estados',
                                    style: TextStyle(
                                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                                    ),
                                  ),
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
                                        Text(
                                          status.displayName,
                                          style: TextStyle(
                                            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                                          ),
                                        ),
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
                              value: _selectedPriority,
                              decoration: InputDecoration(
                                labelText: 'Prioridad',
                                labelStyle: TextStyle(
                                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                                ),
                                filled: true,
                                fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppTheme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              dropdownColor: isDark ? AppTheme.cardDark : Colors.white,
                              style: TextStyle(
                                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(
                                    'Todas las prioridades',
                                    style: TextStyle(
                                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                                    ),
                                  ),
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
                                        Text(
                                          priority.displayName,
                                          style: TextStyle(
                                            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                                          ),
                                        ),
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
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _clearFilters,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: BorderSide(color: AppTheme.primaryColor),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Limpiar filtros'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _applyFilters,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Aplicar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
    required bool isDark,
  }) {
    final chipColor = color ?? AppTheme.primaryColor;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected
                    ? Colors.white
                    : isDark ? chipColor : chipColor.withOpacity(0.8),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected
                    ? Colors.white
                    : isDark ? Colors.white : chipColor,
              ),
            ),
          ],
        ),
        selected: selected,
        onSelected: onSelected,
        backgroundColor: isDark
            ? chipColor.withOpacity(0.2)
            : chipColor.withOpacity(0.1),
        selectedColor: chipColor,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.white : chipColor,
        ),
        showCheckmark: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: selected
              ? BorderSide.none
              : BorderSide(
                  color: chipColor.withOpacity(0.3),
                  width: 1,
                ),
        ),
        elevation: selected ? 2 : 0,
        shadowColor: chipColor.withOpacity(0.3),
      ),
    );
  }

  Widget _buildTaskList(TaskProvider taskProvider, bool isDark) {
    if (taskProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      );
    }

    if (taskProvider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar tareas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                taskProvider.error!,
                style: TextStyle(
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadTasks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Reintentar'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.home),
                label: const Text('Volver al inicio'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (taskProvider.tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.task_outlined,
                size: 80,
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
              ),
              const SizedBox(height: 16),
              Text(
                _searchController.text.isNotEmpty ||
                        _selectedStatus != null ||
                        _selectedPriority != null
                    ? 'No hay tareas con esos filtros'
                    : 'No hay tareas creadas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchController.text.isNotEmpty ||
                        _selectedStatus != null ||
                        _selectedPriority != null
                    ? 'Prueba con otros filtros o crea una nueva tarea'
                    : '¡Crea tu primera tarea!',
                style: TextStyle(
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/tasks/create'),
                icon: const Icon(Icons.add),
                label: const Text('Crear primera tarea'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver al inicio'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
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