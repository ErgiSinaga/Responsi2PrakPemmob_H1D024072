import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';

/// Repository sebagai jembatan tunggal antara ViewModel dan Data Source
/// (WeatherApiService untuk remote data & LocalStorageService untuk local data)
class WeatherRepository {
  final WeatherApiService _apiService;
  final LocalStorageService _storageService;

  WeatherRepository({
    WeatherApiService? apiService,
    LocalStorageService? storageService,
  })  : _apiService = apiService ?? WeatherApiService(),
        _storageService = storageService ?? LocalStorageService();

  // --- REMOTE DATA (API) ---

  /// Cari kota dari Open-Meteo Geocoding
  Future<List<LocationModel>> searchCities(String query) {
    return _apiService.searchCities(query);
  }

  /// Ambil ramalan cuaca dari Open-Meteo Forecast
  Future<WeatherData> getForecast(double latitude, double longitude) {
    return _apiService.getForecast(latitude, longitude);
  }

  // --- LOCAL DATA (SharedPreferences) ---

  /// Ambil lokasi terakhir
  Future<LocationModel?> getLastLocation() {
    return _storageService.getLastLocation();
  }

  /// Simpan lokasi terakhir
  Future<void> saveLastLocation(LocationModel location) {
    return _storageService.saveLastLocation(location);
  }

  /// Ambil daftar favorit
  Future<List<LocationModel>> getFavorites() {
    return _storageService.getFavorites();
  }

  /// Simpan daftar favorit
  Future<void> saveFavorites(List<LocationModel> favorites) {
    return _storageService.saveFavorites(favorites);
  }

  /// Ambil riwayat pencarian
  Future<List<LocationModel>> getSearchHistory() {
    return _storageService.getSearchHistory();
  }

  /// Simpan riwayat pencarian
  Future<void> saveSearchHistory(List<LocationModel> history) {
    return _storageService.saveSearchHistory(history);
  }

  /// Hapus seluruh riwayat pencarian
  Future<void> clearSearchHistory() {
    return _storageService.clearSearchHistory();
  }
}
