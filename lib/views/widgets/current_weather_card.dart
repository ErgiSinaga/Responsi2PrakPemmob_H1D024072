import 'package:flutter/material.dart';
import '../../core/weather_code_helper.dart';
import '../../models/location_model.dart';
import '../../models/weather_model.dart';

/// Kartu utama cuaca saat ini
/// Menampilkan nama kota, deskripsi cuaca, ikon, suhu besar, dan suhu terasa
class CurrentWeatherCard extends StatelessWidget {
  final LocationModel location;
  final CurrentWeather weather;

  const CurrentWeatherCard({
    super.key,
    required this.location,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weatherInfo = WeatherCodeHelper.getWeatherInfo(weather.weatherCode);
    final todayFormatted = WeatherCodeHelper.formatIndonesianDate(
      DateTime.now(),
      isToday: true,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0288D1), // Biru langit cerah
            const Color(0xFF0277BD), // Biru laut tenang
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0288D1).withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nama Kota dan Wilayah
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  location.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Wilayah / Negara & Tanggal
          Text(
            '${location.fullAddress} • $todayFormatted',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),

          // Ikon Cuaca
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              weatherInfo.icon,
              size: 72,
              color: Colors.amber.shade300,
            ),
          ),
          const SizedBox(height: 12),

          // Deskripsi Cuaca (Bahasa Indonesia)
          Text(
            weatherInfo.description,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Suhu Saat Ini (Besar & Menonjol)
          Text(
            '${weather.temperature.round()}°',
            style: theme.textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w300,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),

          // Suhu Terasa (Apparent Temperature)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Terasa seperti ${weather.apparentTemperature.round()}°${weather.temperatureUnit}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
