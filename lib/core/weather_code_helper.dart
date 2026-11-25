import 'package:flutter/material.dart';

/// Helper untuk mengonversi WMO Weather Code (Open-Meteo)
/// menjadi deskripsi bahasa Indonesia, IconData Material, dan warna representatif.
class WeatherInfo {
  final String description;
  final IconData icon;
  final Color color;

  const WeatherInfo({
    required this.description,
    required this.icon,
    required this.color,
  });
}

class WeatherCodeHelper {
  static WeatherInfo getWeatherInfo(int code) {
    switch (code) {
      case 0:
        return const WeatherInfo(
          description: 'Cerah',
          icon: Icons.wb_sunny_rounded,
          color: Color(0xFFFFA000), // Amber
        );
      case 1:
        return const WeatherInfo(
          description: 'Cerah Berawan',
          icon: Icons.wb_cloudy_rounded,
          color: Color(0xFFFFB300),
        );
      case 2:
        return const WeatherInfo(
          description: 'Berawan Sebagian',
          icon: Icons.cloud_queue_rounded,
          color: Color(0xFF78909C), // Blue Grey
        );
      case 3:
        return const WeatherInfo(
          description: 'Mendung',
          icon: Icons.cloud_rounded,
          color: Color(0xFF607D8B),
        );
      case 45:
        return const WeatherInfo(
          description: 'Berkabut',
          icon: Icons.foggy,
          color: Color(0xFF90A4AE),
        );
      case 48:
        return const WeatherInfo(
          description: 'Kabut Berembun Es',
          icon: Icons.foggy,
          color: Color(0xFF90A4AE),
        );
      case 51:
        return const WeatherInfo(
          description: 'Gerimis Ringan',
          icon: Icons.grain_rounded,
          color: Color(0xFF4FC3F7),
        );
      case 53:
        return const WeatherInfo(
          description: 'Gerimis Sedang',
          icon: Icons.grain_rounded,
          color: Color(0xFF29B6F6),
        );
      case 55:
        return const WeatherInfo(
          description: 'Gerimis Lebat',
          icon: Icons.grain_rounded,
          color: Color(0xFF0288D1),
        );
      case 56:
      case 57:
        return const WeatherInfo(
          description: 'Gerimis Membeku',
          icon: Icons.ac_unit_rounded,
          color: Color(0xFF80DEEA),
        );
      case 61:
        return const WeatherInfo(
          description: 'Hujan Ringan',
          icon: Icons.water_drop_outlined,
          color: Color(0xFF29B6F6),
        );
      case 63:
        return const WeatherInfo(
          description: 'Hujan Sedang',
          icon: Icons.water_drop_rounded,
          color: Color(0xFF0288D1),
        );
      case 65:
        return const WeatherInfo(
          description: 'Hujan Lebat',
          icon: Icons.water_drop_rounded,
          color: Color(0xFF01579B),
        );
      case 66:
      case 67:
        return const WeatherInfo(
          description: 'Hujan Membeku',
          icon: Icons.ac_unit_rounded,
          color: Color(0xFF4DD0E1),
        );
      case 71:
        return const WeatherInfo(
          description: 'Hujan Salju Ringan',
          icon: Icons.ac_unit_rounded,
          color: Color(0xFF81D4FA),
        );
      case 73:
        return const WeatherInfo(
          description: 'Hujan Salju Sedang',
          icon: Icons.ac_unit_rounded,
          color: Color(0xFF4FC3F7),
        );
      case 75:
        return const WeatherInfo(
          description: 'Hujan Salju Lebat',
          icon: Icons.ac_unit_rounded,
          color: Color(0xFF29B6F6),
        );
      case 77:
        return const WeatherInfo(
          description: 'Butiran Salju',
          icon: Icons.ac_unit_rounded,
          color: Color(0xFFB3E5FC),
        );
      case 80:
        return const WeatherInfo(
          description: 'Hujan Lokal Ringan',
          icon: Icons.beach_access_rounded,
          color: Color(0xFF26A69A),
        );
      case 81:
        return const WeatherInfo(
          description: 'Hujan Lokal Sedang',
          icon: Icons.beach_access_rounded,
          color: Color(0xFF00897B),
        );
      case 82:
        return const WeatherInfo(
          description: 'Hujan Lokal Deras',
          icon: Icons.thunderstorm_rounded,
          color: Color(0xFF00695C),
        );
      case 85:
        return const WeatherInfo(
          description: 'Hujan Salju Lokal Ringan',
          icon: Icons.ac_unit_rounded,
          color: Color(0xFF80CBC4),
        );
      case 86:
        return const WeatherInfo(
          description: 'Hujan Salju Lokal Lebat',
          icon: Icons.ac_unit_rounded,
          color: Color(0xFF4DB6AC),
        );
      case 95:
        return const WeatherInfo(
          description: 'Badai Petir',
          icon: Icons.thunderstorm_rounded,
          color: Color(0xFF7E57C2), // Deep Purple
        );
      case 96:
        return const WeatherInfo(
          description: 'Badai Petir dengan Hujan Es Ringan',
          icon: Icons.thunderstorm_rounded,
          color: Color(0xFF5E35B1),
        );
      case 99:
        return const WeatherInfo(
          description: 'Badai Petir dengan Hujan Es Lebat',
          icon: Icons.thunderstorm_rounded,
          color: Color(0xFF4527A0),
        );
      default:
        return const WeatherInfo(
          description: 'Kondisi Berawan',
          icon: Icons.cloud_queue_rounded,
          color: Color(0xFF78909C),
        );
    }
  }

  /// Helper untuk memformat tanggal ke nama hari & tanggal bahasa Indonesia
  /// Contoh: "Senin, 25 Nov" atau "Hari ini"
  static String formatIndonesianDate(DateTime date, {bool isToday = false}) {
    if (isToday) return 'Hari ini';

    const dayNames = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final dayName = dayNames[date.weekday - 1];
    final dayNum = date.day;
    final monthName = monthNames[date.month - 1];

    return '$dayName, $dayNum $monthName';
  }
}
