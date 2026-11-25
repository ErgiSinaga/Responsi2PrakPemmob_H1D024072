import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

/// Service untuk membaca dan menulis data lokal (SharedPreferences)
/// Semua data disimpan dalam bentuk JSON String
class LocalStorageService {
  static const String _keyLastLocation = 'last_selected_location';
  static const String _keyFavorites = 'favorite_locations';
  static const String _keySearchHistory = 'search_history';

  // --- LOKASI TERAKHIR TERPILIH ---

  /// Mengambil lokasi terakhir yang dipilih pengguna
  Future<LocationModel?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyLastLocation);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    try {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      return LocationModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Menyimpan lokasi terakhir yang dipilih
  Future<void> saveLastLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(location.toJson());
    await prefs.setString(_keyLastLocation, jsonString);
  }

  // --- DAFTAR FAVORIT ---

  /// Mengambil daftar lokasi favorit yang tersimpan
  Future<List<LocationModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyFavorites);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list
          .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Menyimpan daftar lokasi favorit
  Future<void> saveFavorites(List<LocationModel> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = favorites.map((loc) => loc.toJson()).toList();
    await prefs.setString(_keyFavorites, jsonEncode(jsonList));
  }

  // --- RIWAYAT PENCARIAN (Maksimal 10 lokasi) ---

  /// Mengambil riwayat pencarian lokasi
  Future<List<LocationModel>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keySearchHistory);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list
          .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Menyimpan riwayat pencarian lokasi
  Future<void> saveSearchHistory(List<LocationModel> history) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = history.map((loc) => loc.toJson()).toList();
    await prefs.setString(_keySearchHistory, jsonEncode(jsonList));
  }

  /// Menghapus seluruh riwayat pencarian
  Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySearchHistory);
  }
}
