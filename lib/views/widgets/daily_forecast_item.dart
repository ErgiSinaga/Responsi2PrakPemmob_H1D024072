import 'package:flutter/material.dart';
import '../../core/weather_code_helper.dart';
import '../../models/weather_model.dart';

/// Item baris prakiraan cuaca harian (7 hari ke depan)
class DailyForecastItem extends StatelessWidget {
  final DailyForecast forecast;
  final bool isToday;

  const DailyForecastItem({
    super.key,
    required this.forecast,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weatherInfo = WeatherCodeHelper.getWeatherInfo(forecast.weatherCode);
    final dateFormatted = WeatherCodeHelper.formatIndonesianDate(
      forecast.date,
      isToday: isToday,
    );

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Tanggal / Nama Hari
            SizedBox(
              width: 105,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormatted,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                      color: isToday
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (forecast.precipitationProbability > 0) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.water_drop_rounded,
                          size: 12,
                          color: Color(0xFF0288D1),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${forecast.precipitationProbability}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF0288D1),
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Ikon Cuaca & Deskripsi
            Expanded(
              child: Row(
                children: [
                  Icon(
                    weatherInfo.icon,
                    size: 26,
                    color: weatherInfo.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      weatherInfo.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Suhu Min / Maks
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${forecast.maxTemp.round()}°',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ' / ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade400,
                  ),
                ),
                Text(
                  '${forecast.minTemp.round()}°',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
