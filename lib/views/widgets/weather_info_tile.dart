import 'package:flutter/material.dart';
import '../../models/weather_model.dart';

/// Widget petak informasi tambahan cuaca
/// Menampilkan: Kelembapan, Kecepatan Angin, Curah Hujan, dan Peluang Hujan Hari Ini
class WeatherInfoTile extends StatelessWidget {
  final CurrentWeather weather;
  final int todayRainProbability; // Diambil dari daily.precipitation_probability_max[0]

  const WeatherInfoTile({
    super.key,
    required this.weather,
    required this.todayRainProbability,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem(
              context: context,
              icon: Icons.water_drop_outlined,
              iconColor: const Color(0xFF0288D1),
              value: '${weather.relativeHumidity}%',
              label: 'Kelembapan',
            ),
            _buildDivider(),
            _buildInfoItem(
              context: context,
              icon: Icons.air_rounded,
              iconColor: const Color(0xFF26A69A),
              value: '${weather.windSpeed.round()} ${weather.windSpeedUnit}',
              label: 'Angin',
            ),
            _buildDivider(),
            _buildInfoItem(
              context: context,
              icon: Icons.umbrella_outlined,
              iconColor: const Color(0xFF5C6BC0),
              value: '$todayRainProbability%',
              label: 'Peluang Hujan',
            ),
            _buildDivider(),
            _buildInfoItem(
              context: context,
              icon: Icons.grain_rounded,
              iconColor: const Color(0xFF42A5F5),
              value: '${weather.precipitation.toStringAsFixed(1)} ${weather.precipitationUnit}',
              label: 'Curah Hujan',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 38,
      width: 1,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 22,
          color: iconColor,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
