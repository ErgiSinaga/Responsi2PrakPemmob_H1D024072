import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
import '../models/weather_model.dart';

/// Service untuk menangani semua panggilan HTTP GET ke Open-Meteo API
class WeatherApiService {
  final http.Client _client;

  // Mendukung dependency injection untuk memudahkan testing jika dibutuhkan
  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  // Waktu timeout untuk setiap request jaringan (10 detik)
  static const Duration _timeout = Duration(seconds: 10);

  /// Mencari kota berdasarkan nama menggunakan Open-Meteo Geocoding API
  /// GET https://geocoding-api.open-meteo.com/v1/search?name={query}&count=10&language=id&format=json
  Future<List<LocationModel>> searchCities(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return [];

    final uri = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {
        'name': trimmedQuery,
        'count': '10',
        'language': 'id',
        'format': 'json',
      },
    );

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Jika 'results' null/tidak ada, kembalikan list kosong (bukan error)
        if (!data.containsKey('results') || data['results'] == null) {
          return [];
        }

        final List<dynamic> results = data['results'] as List<dynamic>;
        return results
            .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException(
          'Gagal mengambil data kota (Status: ${response.statusCode})',
        );
      }
    } on SocketException {
      throw const SocketException(
        'Tidak ada koneksi internet. Periksa jaringan Anda.',
      );
    } on TimeoutException {
      throw TimeoutException(
        'Koneksi waktu habis (timeout). Silakan coba lagi.',
      );
    } on FormatException {
      throw const FormatException('Format respon server tidak valid.');
    } catch (e) {
      if (e is HttpException ||
          e is SocketException ||
          e is TimeoutException ||
          e is FormatException) {
        rethrow;
      }
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }

  /// Mengambil data prakiraan cuaca 7 hari dari Open-Meteo Forecast API
  /// GET https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current=...&daily=...&timezone=auto&forecast_days=7
  Future<WeatherData> getForecast(double latitude, double longitude) async {
    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
        'timezone': 'auto',
        'forecast_days': '7',
      },
    );

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return WeatherData.fromJson(data);
      } else {
        throw HttpException(
          'Gagal mengambil data cuaca (Status: ${response.statusCode})',
        );
      }
    } on SocketException {
      throw const SocketException(
        'Tidak ada koneksi internet. Periksa jaringan Anda.',
      );
    } on TimeoutException {
      throw TimeoutException(
        'Koneksi waktu habis (timeout). Silakan coba lagi.',
      );
    } on FormatException {
      throw const FormatException('Format respon server tidak valid.');
    } catch (e) {
      if (e is HttpException ||
          e is SocketException ||
          e is TimeoutException ||
          e is FormatException) {
        rethrow;
      }
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }
}
