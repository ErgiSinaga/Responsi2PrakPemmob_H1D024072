import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../repositories/weather_repository.dart';

/// Enum status state aplikasi (Initial, Loading, Success, Empty, Error)
enum ViewState { initial, loading, success, empty, error }

/// ViewModel untuk mengelola state cuaca lokasi terpilih
/// Tidak mengimpor widget UI agar arsitektur MVVM tetap bersih
class WeatherViewModel extends ChangeNotifier {
  final WeatherRepository _repository;

  WeatherViewModel(this._repository);

  ViewState _state = ViewState.initial;
  LocationModel? _selectedLocation;
  WeatherData? _weatherData;
  String? _errorMessage;
  bool _disposed = false;

  // Getter untuk View
  ViewState get state => _state;
  LocationModel? get selectedLocation => _selectedLocation;
  WeatherData? get weatherData => _weatherData;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == ViewState.loading;
  bool get isSuccess => _state == ViewState.success;
  bool get isError => _state == ViewState.error;
  bool get isEmpty => _state == ViewState.empty;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  /// Inisialisasi awal saat aplikasi dibuka:
  /// 1. Cek apakah ada lokasi terakhir tersimpan di SharedPreferences.
  /// 2. Jika ada, muat cuaca untuk lokasi tersebut.
  /// 3. Jika belum ada, cari "Purwokerto" lewat Geocoding API lalu ambil hasil pertama.
  Future<void> initializeWeather() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final savedLocation = await _repository.getLastLocation();

      if (savedLocation != null) {
        _selectedLocation = savedLocation;
      } else {
        // Cari "Purwokerto" secara dinamis via API (bukan koordinat hardcode)
        final searchResults = await _repository.searchCities('Purwokerto');
        if (searchResults.isNotEmpty) {
          _selectedLocation = searchResults.first;
          await _repository.saveLastLocation(_selectedLocation!);
        } else {
          _state = ViewState.empty;
          _errorMessage = 'Lokasi default Purwokerto tidak ditemukan di server.';
          notifyListeners();
          return;
        }
      }

      // Ambil prakiraan cuaca untuk lokasi terpilih
      await _fetchWeatherForSelectedLocation();
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = _cleanErrorMessage(e.toString());
      notifyListeners();
    }
  }

  /// Memilih lokasi baru dari layar pencarian
  Future<void> setLocation(LocationModel location) async {
    _selectedLocation = location;
    await _repository.saveLastLocation(location);
    await fetchWeather();
  }

  /// Mengambil data cuaca untuk lokasi yang saat ini terpilih
  Future<void> fetchWeather() async {
    if (_selectedLocation == null) {
      _state = ViewState.empty;
      _errorMessage = 'Belum ada kota yang dipilih.';
      notifyListeners();
      return;
    }

    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _fetchWeatherForSelectedLocation();
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = _cleanErrorMessage(e.toString());
      notifyListeners();
    }
  }

  /// Pull-to-refresh atau tombol refresh cuaca
  Future<void> refreshWeather() async {
    if (_selectedLocation == null) {
      await initializeWeather();
      return;
    }

    try {
      final data = await _repository.getForecast(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
      );
      _weatherData = data;
      _state = ViewState.success;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      // Jika refresh gagal, tampilkan pesan error namun pertahankan data sebelumnya jika ada
      _errorMessage = _cleanErrorMessage(e.toString());
      if (_weatherData == null) {
        _state = ViewState.error;
      }
      notifyListeners();
    }
  }

  /// Helper internal untuk memanggil service forecast
  Future<void> _fetchWeatherForSelectedLocation() async {
    final data = await _repository.getForecast(
      _selectedLocation!.latitude,
      _selectedLocation!.longitude,
    );
    _weatherData = data;
    _state = ViewState.success;
    _errorMessage = null;
    notifyListeners();
  }

  /// Membersihkan teks error agar ramah untuk pengguna
  String _cleanErrorMessage(String rawMessage) {
    if (rawMessage.contains('SocketException') ||
        rawMessage.contains('Tidak ada koneksi')) {
      return 'Tidak ada koneksi internet. Pastikan perangkat terhubung ke internet.';
    }
    if (rawMessage.contains('TimeoutException') ||
        rawMessage.contains('timeout')) {
      return 'Koneksi waktu habis (timeout). Server membutuhkan waktu terlalu lama merespon.';
    }
    if (rawMessage.contains('FormatException')) {
      return 'Format data dari server tidak dapat diproses.';
    }
    return rawMessage.replaceAll('Exception:', '').trim();
  }
}
