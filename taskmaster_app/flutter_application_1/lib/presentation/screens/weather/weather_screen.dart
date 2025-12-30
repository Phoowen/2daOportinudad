import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:taskmaster_app/presentation/providers/weather_provider.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _cityController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadInitialWeather();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialWeather() async {
    final weatherProvider = context.read<WeatherProvider>();
    if (weatherProvider.currentWeather == null) {
      await weatherProvider.getWeatherByCity('Madrid');
    }
  }

  Future<void> _searchWeather() async {
    if (_cityController.text.trim().isEmpty) return;
    
    setState(() => _isSearching = true);
    
    try {
      final weatherProvider = context.read<WeatherProvider>();
      await weatherProvider.getWeatherByCity(_cityController.text.trim());
    } catch (e) {
      // El error se maneja en el provider
    } finally {
      setState(() => _isSearching = false);
    }
    
    // Ocultar teclado
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima Actual'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => weatherProvider.refreshWeather(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => weatherProvider.refreshWeather(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Buscador
              _buildSearchBar(),
              const SizedBox(height: 24),
              
              // Información del clima
              if (weatherProvider.isLoading && !_isSearching)
                const Center(child: CircularProgressIndicator())
              else if (weatherProvider.error != null)
                _buildErrorWidget(weatherProvider)
              else if (weatherProvider.currentWeather != null)
                _buildWeatherInfo(weatherProvider)
              else
                _buildEmptyState(),
              
              const SizedBox(height: 24),
              
              // Ciudades comunes
              _buildCommonCities(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Buscar Ciudad',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      hintText: 'Ej: Madrid, Barcelona, Londres...',
                      border: const OutlineInputBorder(),
                      suffixIcon: _cityController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _cityController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _searchWeather(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isSearching ? null : _searchWeather,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(WeatherProvider weatherProvider) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al obtener el clima',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              weatherProvider.error ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => weatherProvider.clearError(),
              child: const Text('Intentar de nuevo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(WeatherProvider weatherProvider) {
    final weather = weatherProvider.currentWeather!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Ciudad y fecha
            Text(
              weather.location,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              weather.formattedDate,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            
            // Temperatura e icono
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono
                Image.network(
                  weather.iconUrl,
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.cloud, size: 100, color: Colors.blue);
                  },
                ),
                const SizedBox(width: 20),
                
                // Temperatura
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.temperatureFormatted,
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      weather.capitalizedDescription,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Detalles
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildDetailCard(
                  Icons.thermostat,
                  'Sensación',
                  '${(weather.temperature + 2).round()}°C', // Simulado
                  Colors.orange,
                ),
                _buildDetailCard(
                  Icons.water_drop,
                  'Humedad',
                  weather.humidityFormatted,
                  Colors.blue,
                ),
                _buildDetailCard(
                  Icons.air,
                  'Viento',
                  weather.windSpeedFormatted,
                  Colors.grey,
                ),
                _buildDetailCard(
                  Icons.compress,
                  'Presión',
                  '1013 hPa', // Simulado
                  Colors.purple,
                ),
              ],
            ),
            
            // Consejo según el clima
            const SizedBox(height: 24),
            _buildWeatherAdvice(weather),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
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
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

  Widget _buildWeatherAdvice(weather) {
    String advice = '';
    Color color = Colors.blue;

    if (weather.description.contains('lluvia')) {
      advice = '¡Lleva paraguas! Va a llover hoy.';
      color = Colors.blue;
    } else if (weather.description.contains('soleado') || 
               weather.description.contains('despejado')) {
      advice = 'Día perfecto para actividades al aire libre.';
      color = Colors.orange;
    } else if (weather.temperature < 10) {
      advice = 'Hace frío, abrígate bien.';
      color = Colors.blue.shade800;
    } else if (weather.temperature > 30) {
      advice = 'Hace mucho calor, mantente hidratado.';
      color = Colors.red;
    } else {
      advice = 'Clima agradable para realizar tus tareas.';
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              advice,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(Icons.cloud_off, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'Sin datos del clima',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Busca una ciudad para ver el clima actual',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonCities() {
    final cities = ['Madrid', 'Barcelona', 'Valencia', 'Sevilla', 'Bilbao'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ciudades Populares',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cities.map((city) {
            return FilterChip(
              label: Text(city),
              onSelected: (_) {
                _cityController.text = city;
                _searchWeather();
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}