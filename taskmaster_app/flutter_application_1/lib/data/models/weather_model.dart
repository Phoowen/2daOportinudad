class WeatherModel {
  final String city;
  final String country;
  final double temperature;
  final String description;
  final String icon;
  final double humidity;
  final double windSpeed;
  final DateTime date;

  WeatherModel({
    required this.city,
    required this.country,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.date,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['name'] ?? '',
      country: json['sys']['country'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '01d',
      humidity: (json['main']['humidity'] as num).toDouble(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
    );
  }

  String get temperatureFormatted => '${temperature.round()}°C';
  String get humidityFormatted => '${humidity.round()}%';
  String get windSpeedFormatted => '${windSpeed.toStringAsFixed(1)} m/s';
  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  String get capitalizedDescription {
    if (description.isEmpty) return '';
    return description[0].toUpperCase() + description.substring(1);
  }

  String get formattedDate {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return 'Hoy';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  String get location => '$city, $country';
}