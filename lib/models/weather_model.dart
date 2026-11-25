// Model untuk cuaca saat ini (Current Weather)
class CurrentWeather {
  final double temperature;
  final int relativeHumidity;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;
  final String temperatureUnit;
  final String windSpeedUnit;
  final String precipitationUnit;

  const CurrentWeather({
    required this.temperature,
    required this.relativeHumidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    this.temperatureUnit = '°C',
    this.windSpeedUnit = 'km/h',
    this.precipitationUnit = 'mm',
  });

  factory CurrentWeather.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? units,
  }) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      apparentTemperature:
          (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      temperatureUnit: units?['temperature_2m'] as String? ?? '°C',
      windSpeedUnit: units?['wind_speed_10m'] as String? ?? 'km/h',
      precipitationUnit: units?['precipitation'] as String? ?? 'mm',
    );
  }
}

// Model untuk prakiraan cuaca harian (Daily Forecast)
class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double maxTemp;
  final double minTemp;
  final int precipitationProbability; // Peluang hujan maksimal (%)

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
    required this.precipitationProbability,
  });
}

// Model data cuaca lengkap menggabungkan kondisi saat ini dan prakiraan 7 hari
class WeatherData {
  final CurrentWeather current;
  final List<DailyForecast> daily;
  final String timezone;

  const WeatherData({
    required this.current,
    required this.daily,
    required this.timezone,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>? ?? {};
    final currentUnits = json['current_units'] as Map<String, dynamic>?;
    final dailyJson = json['daily'] as Map<String, dynamic>? ?? {};

    // Parsing data harian menjadi List<DailyForecast>
    final List<DailyForecast> dailyList = [];
    final times = (dailyJson['time'] as List<dynamic>?) ?? [];
    final codes = (dailyJson['weather_code'] as List<dynamic>?) ?? [];
    final maxTemps = (dailyJson['temperature_2m_max'] as List<dynamic>?) ?? [];
    final minTemps = (dailyJson['temperature_2m_min'] as List<dynamic>?) ?? [];
    final rainProbs =
        (dailyJson['precipitation_probability_max'] as List<dynamic>?) ?? [];

    for (int i = 0; i < times.length; i++) {
      final dateStr = times[i].toString();
      final date = DateTime.tryParse(dateStr) ?? DateTime.now().add(Duration(days: i));
      final code = i < codes.length ? (codes[i] as num).toInt() : 0;
      final maxT = i < maxTemps.length ? (maxTemps[i] as num).toDouble() : 0.0;
      final minT = i < minTemps.length ? (minTemps[i] as num).toDouble() : 0.0;
      final rainProb =
          i < rainProbs.length && rainProbs[i] != null
              ? (rainProbs[i] as num).toInt()
              : 0;

      dailyList.add(
        DailyForecast(
          date: date,
          weatherCode: code,
          maxTemp: maxT,
          minTemp: minT,
          precipitationProbability: rainProb,
        ),
      );
    }

    return WeatherData(
      current: CurrentWeather.fromJson(currentJson, units: currentUnits),
      daily: dailyList,
      timezone: json['timezone'] as String? ?? 'auto',
    );
  }
}
