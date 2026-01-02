import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:taskmaster_app/presentation/providers/auth_provider.dart';
import 'package:taskmaster_app/presentation/providers/task_provider.dart';
import 'package:taskmaster_app/presentation/providers/weather_provider.dart';
import 'package:taskmaster_app/presentation/widgets/task_card.dart';
import 'package:taskmaster_app/data/models/weather_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Añade esta variable para controlar el índice actual

  @override
  void initState() {
    super.initState();
    // NO usar context.read aquí
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final taskProvider = context.read<TaskProvider>();
    final weatherProvider = context.read<WeatherProvider>();

    // Cargar datos iniciales
    await taskProvider.loadTasks();
    await weatherProvider.getWeatherByCity('México');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final weatherProvider = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('nOWte.app'),
        actions: [
          // Botón de noticias en AppBar (opcional)
          IconButton(
            icon: const Icon(Icons.article),
            onPressed: () {
              _currentIndex = 3; // Actualiza el índice
              context.go('/news');
            },
            tooltip: 'Noticias',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bienvenida
              _buildWelcomeSection(authProvider),
              const SizedBox(height: 24),
              
              // Estadísticas
              _buildStatisticsSection(taskProvider),
              const SizedBox(height: 24),
              
              // Clima
              _buildWeatherSection(weatherProvider),
              const SizedBox(height: 24),
              
              // Tareas recientes
              _buildRecentTasksSection(taskProvider),

              // Sección de noticias (nueva)
              const SizedBox(height: 24),
              _buildNewsSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/tasks/create'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Tarea'),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // NUEVA SECCIÓN: Acceso rápido a noticias
  Widget _buildNewsSection() {
    return Card(
      child: InkWell(
        onTap: () {
          _currentIndex = 3; // Actualiza el índice
          context.go('/news');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.article,
                  color: Colors.blue,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Últimas Noticias',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mantente informado con las noticias más relevantes',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(AuthProvider authProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 30, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, ${authProvider.user?.username ?? 'Usuario'}!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bienvenido a nOWte.app',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(TaskProvider taskProvider) {
    final stats = taskProvider.getStatistics();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildStatCard(
              'Total',
              stats['total']?.toString() ?? '0',
              Icons.task,
              Colors.blue,
            ),
            _buildStatCard(
              'Pendientes',
              stats['pending']?.toString() ?? '0',
              Icons.access_time,
              Colors.orange,
            ),
            _buildStatCard(
              'En Progreso',
              stats['inProgress']?.toString() ?? '0',
              Icons.autorenew,
              Colors.blue,
            ),
            _buildStatCard(
              'Completadas',
              stats['completed']?.toString() ?? '0',
              Icons.check_circle,
              Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherSection(WeatherProvider weatherProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Clima',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => weatherProvider.refreshWeather(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (weatherProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (weatherProvider.error != null)
              Text(
                'Error: ${weatherProvider.error}',
                style: const TextStyle(color: Colors.red),
              )
            else if (weatherProvider.currentWeather != null)
              _buildWeatherInfo(weatherProvider.currentWeather!)
            else
              const Text('No hay datos del clima'),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(WeatherModel weather) {
    return Row(
      children: [
        // Icono
        Column(
          children: [
            Image.network(
              weather.iconUrl,
              width: 60,
              height: 60,
            ),
            Text(weather.capitalizedDescription),
          ],
        ),
        const SizedBox(width: 20),
        
        // Información
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weather.location,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                weather.temperatureFormatted,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.water_drop, size: 16),
                  const SizedBox(width: 4),
                  Text('Humedad: ${weather.humidityFormatted}'),
                  const SizedBox(width: 16),
                  const Icon(Icons.air, size: 16),
                  const SizedBox(width: 4),
                  Text('Viento: ${weather.windSpeedFormatted}'),
                ],
              ),
            ],
          ),
        ),
        
        // Botón para ver más
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            _currentIndex = 2; // Actualiza el índice para clima
            context.go('/weather');
          },
        ),
      ],
    );
  }

  Widget _buildRecentTasksSection(TaskProvider taskProvider) {
    final recentTasks = taskProvider.tasks.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tareas Recientes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                _currentIndex = 1; // Actualiza el índice para tareas
                context.go('/tasks');
              },
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (taskProvider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (taskProvider.error != null)
          Text(
            'Error: ${taskProvider.error}',
            style: const TextStyle(color: Colors.red),
          )
        else if (recentTasks.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('No hay tareas recientes'),
              ),
            ),
          )
        else
          Column(
            children: recentTasks.map((task) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TaskCard(task: task),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/tasks');
            break;
          case 2:
            context.go('/weather');
            break;
          case 3: // NUEVO: Noticias
            context.go('/news');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.task),
          label: 'Tareas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.cloud),
          label: 'Clima',
        ),
        BottomNavigationBarItem( // NUEVO ITEM
          icon: Icon(Icons.article),
          label: 'Noticias',
        ),
      ],
    );
  }
}