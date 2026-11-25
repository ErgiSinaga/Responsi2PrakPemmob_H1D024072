import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../repositories/weather_repository.dart';
import 'weather_viewmodel.dart';

/// ViewModel untuk mengelola pencarian kota, daftar favorit, dan riwayat pencarian
/// Mendukung debounce pencarian ~500ms
class SearchViewModel extends ChangeNotifier {
  final WeatherRepository _repository;

  SearchViewModel(this._repository);

  ViewState _searchState = ViewState.initial;
  List<LocationModel> _searchResults = [];
  String? _searchErrorMessage;

  List<LocationModel> _favorites = [];
  List<LocationModel> _searchHistory = [];

  String _currentQuery = '';
  Timer? _debounceTimer;
  bool _disposed = false;

  // Getter untuk View
  ViewState get searchState => _searchState;
  List<LocationModel> get searchResults => _searchResults;
  String? get searchErrorMessage => _searchErrorMessage;
  List<LocationModel> get favorites => _favorites;
  List<LocationModel> get searchHistory => _searchHistory;
  String get currentQuery => _currentQuery;

  bool get isSearching => _currentQuery.trim().isNotEmpty;
  bool get isLoading => _searchState == ViewState.loading;
  bool get isEmpty => _searchState == ViewState.empty;
  bool get isError => _searchState == ViewState.error;
  bool get isSuccess => _searchState == ViewState.success;

  @override
  void dispose() {
    _disposed = true;
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  /// Memuat data favorit dan riwayat pencarian dari SharedPreferences saat awal dibuka
  Future<void> loadFavoritesAndHistory() async {
    try {
      final favList = await _repository.getFavorites();
      final histList = await _repository.getSearchHistory();
      _favorites = favList;
      _searchHistory = histList;
      notifyListeners();
    } catch (_) {
      // Abaikan error pembacaan lokal dan biarkan list kosong
    }
  }

  /// Handler saat teks di TextField berubah dengan debounce 500ms
  void onQueryChanged(String query) {
    _currentQuery = query;
    _debounceTimer?.cancel();

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _searchState = ViewState.initial;
      _searchResults = [];
      _searchErrorMessage = null;
      notifyListeners();
      return;
    }

    // Set timer debounce 500ms untuk menghindari request berlebihan saat mengetik
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      searchCities(trimmed);
    });
  }

  /// Eksekusi pencarian kota ke Open-Meteo Geocoding API
  Future<void> searchCities(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _searchState = ViewState.initial;
      _searchResults = [];
      notifyListeners();
      return;
    }

    _searchState = ViewState.loading;
    _searchErrorMessage = null;
    notifyListeners();

    try {
      final results = await _repository.searchCities(trimmed);

      if (results.isEmpty) {
        _searchState = ViewState.empty;
        _searchResults = [];
        _searchErrorMessage = 'Kota "$trimmed" tidak ditemukan.';
      } else {
        _searchState = ViewState.success;
        _searchResults = results;
        _searchErrorMessage = null;
      }
      notifyListeners();
    } catch (e) {
      _searchState = ViewState.error;
      _searchErrorMessage = _cleanErrorMessage(e.toString());
      _searchResults = [];
      notifyListeners();
    }
  }

  /// Menambahkan lokasi ke riwayat pencarian (maksimal 10 lokasi, tanpa duplikat)
  Future<void> addToHistory(LocationModel location) async {
    // Hapus jika sudah ada sebelumnya agar berpindah ke urutan paling atas (terbaru)
    _searchHistory.removeWhere((item) => item.id == location.id);
    _searchHistory.insert(0, location);

    // Batasi riwayat maksimal 10
    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.sublist(0, 10);
    }

    notifyListeners();
    await _repository.saveSearchHistory(_searchHistory);
  }

  /// Menghapus seluruh riwayat pencarian
  Future<void> clearHistory() async {
    _searchHistory.clear();
    notifyListeners();
    await _repository.clearSearchHistory();
  }

  /// Memeriksa apakah suatu lokasi sudah masuk dalam daftar favorit
  bool isFavorite(LocationModel location) {
    return _favorites.any((item) => item.id == location.id);
  }

  /// Toggle status favorit (tambah jika belum ada, hapus jika sudah ada)
  Future<void> toggleFavorite(LocationModel location) async {
    final index = _favorites.indexWhere((item) => item.id == location.id);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(location);
    }
    notifyListeners();
    await _repository.saveFavorites(_favorites);
  }

  /// Menghapus item dari daftar favorit
  Future<void> removeFavorite(LocationModel location) async {
    _favorites.removeWhere((item) => item.id == location.id);
    notifyListeners();
    await _repository.saveFavorites(_favorites);
  }

  /// Membersihkan input pencarian
  void clearQuery() {
    _debounceTimer?.cancel();
    _currentQuery = '';
    _searchState = ViewState.initial;
    _searchResults = [];
    _searchErrorMessage = null;
    notifyListeners();
  }

  /// Helper pesan error bahasa Indonesia yang jelas
  String _cleanErrorMessage(String rawMessage) {
    if (rawMessage.contains('SocketException') ||
        rawMessage.contains('Tidak ada koneksi')) {
      return 'Tidak ada koneksi internet. Silakan periksa jaringan Anda.';
    }
    if (rawMessage.contains('TimeoutException') ||
        rawMessage.contains('timeout')) {
      return 'Koneksi waktu habis (timeout). Server lambat merespon.';
    }
    if (rawMessage.contains('FormatException')) {
      return 'Format respon data tidak valid.';
    }
    return rawMessage.replaceAll('Exception:', '').trim();
  }
}
