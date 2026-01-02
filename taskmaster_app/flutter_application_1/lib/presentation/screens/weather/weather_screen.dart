import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:taskmaster_app/core/theme/app_theme.dart';
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
      await weatherProvider.getWeatherByCity('Ecatepec de Morelos');
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        // ⭐⭐ BOTÓN DE BACK AGREGADO ⭐⭐
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppTheme.textPrimaryDark : Colors.white,
          ),
          onPressed: () => context.go('/home'),
          tooltip: 'Volver al inicio',
        ),
        title: const Text('Clima Actual'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () => weatherProvider.refreshWeather(),
            tooltip: 'Actualizar clima',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => weatherProvider.refreshWeather(),
        color: AppTheme.primaryColor,
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Buscador
              _buildSearchBar(isDark),
              const SizedBox(height: 24),
              
              // Información del clima
              if (weatherProvider.isLoading && !_isSearching)
                Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                )
              else if (weatherProvider.error != null)
                _buildErrorWidget(weatherProvider, isDark)
              else if (weatherProvider.currentWeather != null)
                _buildWeatherInfo(weatherProvider, isDark)
              else
                _buildEmptyState(isDark),
              
              const SizedBox(height: 24),
              
              // Ciudades comunes
              _buildCommonCities(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDark ? AppTheme.cardDark : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Buscar Ciudad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
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
                      controller: _cityController,
                      decoration: InputDecoration(
                        hintText: 'Ej: México, Tokio, Londres...',
                        hintStyle: TextStyle(
                          color: isDark 
                              ? AppTheme.textSecondaryDark 
                              : AppTheme.textSecondaryLight,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        suffixIcon: _cityController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: AppTheme.errorColor,
                                ),
                                onPressed: () {
                                  _cityController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      style: TextStyle(
                        color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                      ),
                      onSubmitted: (_) => _searchWeather(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isSearching ? null : _searchWeather,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(WeatherProvider weatherProvider, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDark ? AppTheme.cardDark : AppTheme.errorColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.error_outline, 
              size: 64, 
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al obtener el clima',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              weatherProvider.error ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => weatherProvider.clearError(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Intentar de nuevo'),
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

  Widget _buildWeatherInfo(WeatherProvider weatherProvider, bool isDark) {
    final weather = weatherProvider.currentWeather!;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: isDark ? AppTheme.cardDark : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Ciudad y fecha
            Text(
              weather.location,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              weather.formattedDate,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),
            
            // Temperatura e icono
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.getPrimaryGradient(isDark: isDark),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.network(
                    weather.iconUrl,
                    width: 80,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.cloud,
                        size: 80,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                
                // Temperatura
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.temperatureFormatted,
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                      ),
                    ),
                    Text(
                      weather.capitalizedDescription,
                      style: TextStyle(
                        fontSize: 18,
                        color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                      ),
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
                  '${(weather.temperature + 2).round()}°C',
                  Colors.orange,
                  isDark,
                ),
                _buildDetailCard(
                  Icons.water_drop,
                  'Humedad',
                  weather.humidityFormatted,
                  Colors.blue,
                  isDark,
                ),
                _buildDetailCard(
                  Icons.air,
                  'Viento',
                  weather.windSpeedFormatted,
                  AppTheme.accentColor,
                  isDark,
                ),
                _buildDetailCard(
                  Icons.compress,
                  'Presión',
                  '1013 hPa',
                  Colors.purple,
                  isDark,
                ),
              ],
            ),
            
            // Consejo según el clima
            const SizedBox(height: 24),
            _buildWeatherAdvice(weather, isDark),
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
    bool isDark,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDark ? AppTheme.surfaceDark : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
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
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
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

  Widget _buildWeatherAdvice(weather, bool isDark) {
    String advice = '';
    Color color = AppTheme.primaryColor;

    if (weather.description.contains('lluvia') ||
        weather.description.contains('rain') ||
        weather.description.contains('drizzle')) {
      advice = '¡Lleva paraguas! Va a llover hoy.';
      color = Colors.blue;
    } else if (weather.description.contains('soleado') ||
               weather.description.contains('despejado') ||
               weather.description.contains('sunny') ||
               weather.description.contains('clear')) {
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
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              advice,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: isDark ? AppTheme.cardDark : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.cloud_off,
              size: 80,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            ),
            const SizedBox(height: 20),
            Text(
              'Sin datos del clima',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Busca una ciudad para ver el clima actual',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _cityController.text = 'Ecatepec de Morelos';
                _searchWeather();
              },
              icon: const Icon(Icons.search),
              label: const Text('Buscar mi ciudad'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonCities(bool isDark) {
    final cities = [
      'Ecatepec de Morelos',
      'Ciudad de México',
      'Puebla',
      'Monterrey',
      'Guadalajara',
      'Cancún',
      'Tijuana',
      'Mérida'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ciudades Populares',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cities.map((city) {
            return FilterChip(
              label: Text(
                city,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : AppTheme.primaryColor,
                ),
              ),
              onSelected: (_) {
                _cityController.text = city;
                _searchWeather();
              },
              backgroundColor: isDark
                  ? AppTheme.primaryColor.withOpacity(0.2)
                  : AppTheme.primaryColor.withOpacity(0.1),
              selectedColor: AppTheme.primaryColor,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}