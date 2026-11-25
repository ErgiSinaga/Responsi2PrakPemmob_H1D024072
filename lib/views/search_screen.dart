import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/location_model.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/location_list_tile.dart';

/// Layar Pencarian & Pengelolaan Lokasi (Search / Location Screen)
/// Fitur: Pencarian kota Open-Meteo, Daftar Favorit, Riwayat Pencarian
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Muat data favorit dan riwayat pencarian saat layar dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchViewModel>().loadFavoritesAndHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Memilih kota dan kembali ke layar Home
  void _onSelectCity(LocationModel location) {
    // 1. Simpan ke riwayat pencarian
    context.read<SearchViewModel>().addToHistory(location);
    // 2. Set sebagai kota aktif dan muat cuacanya di Home
    context.read<WeatherViewModel>().setLocation(location);
    // 3. Kembali ke layar Home
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Kota'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Input Pencarian
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: TextField(
                    controller: _searchController,
                    autofocus: false,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama kota (misal: Jakarta, Bandung)...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                context.read<SearchViewModel>().clearQuery();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) {
                      context.read<SearchViewModel>().onQueryChanged(val);
                      setState(() {});
                    },
                    onSubmitted: (val) {
                      context.read<SearchViewModel>().searchCities(val);
                    },
                  ),
                ),

                // Konten: Hasil Pencarian ATAU (Favorit + Riwayat)
                Expanded(
                  child: Consumer<SearchViewModel>(
                    builder: (context, searchVm, child) {
                      // Jika input TIDAK kosong -> Tampilkan hasil pencarian
                      if (searchVm.isSearching) {
                        return _buildSearchResultsView(searchVm);
                      }

                      // Jika input KOSONG -> Tampilkan Favorit & Riwayat Pencarian
                      return _buildFavoritesAndHistoryView(searchVm, theme);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Tampilan hasil pencarian kota dari API Open-Meteo
  Widget _buildSearchResultsView(SearchViewModel searchVm) {
    if (searchVm.isLoading) {
      return const LoadingView(message: 'Mencari kota...');
    }

    if (searchVm.isError) {
      return ErrorView(
        message: searchVm.searchErrorMessage,
        onRetry: () => searchVm.searchCities(searchVm.currentQuery),
      );
    }

    if (searchVm.isEmpty || searchVm.searchResults.isEmpty) {
      return EmptyView(
        icon: Icons.location_off_rounded,
        title: 'Kota Tidak Ditemukan',
        message: 'Tidak ada hasil untuk "${searchVm.currentQuery}". Coba kata kunci lain.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: searchVm.searchResults.length,
      itemBuilder: (context, index) {
        final location = searchVm.searchResults[index];
        final isFav = searchVm.isFavorite(location);

        return LocationListTile(
          location: location,
          isFavorite: isFav,
          onTap: () => _onSelectCity(location),
          onToggleFavorite: () => searchVm.toggleFavorite(location),
        );
      },
    );
  }

  /// Tampilan bagian Favorit dan Riwayat Pencarian
  Widget _buildFavoritesAndHistoryView(SearchViewModel searchVm, ThemeData theme) {
    final favorites = searchVm.favorites;
    final history = searchVm.searchHistory;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // --- SEKSI FAVORIT ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lokasi Favorit',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (favorites.isNotEmpty)
              Text(
                '${favorites.length} kota',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),

        if (favorites.isEmpty)
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.star_outline_rounded, color: Colors.grey),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Belum ada lokasi favorit. Tekan ikon bintang pada hasil pencarian untuk menambahkannya.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...favorites.map((loc) {
            return LocationListTile(
              location: loc,
              isFavorite: true,
              onTap: () => _onSelectCity(loc),
              onToggleFavorite: () => searchVm.removeFavorite(loc),
            );
          }),

        const SizedBox(height: 24),

        // --- SEKSI RIWAYAT PENCARIAN ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Pencarian',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (history.isNotEmpty)
              TextButton.icon(
                onPressed: () => searchVm.clearHistory(),
                icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                label: const Text('Hapus Semua'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade400,
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),

        if (history.isEmpty)
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.history_rounded, color: Colors.grey),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Belum ada riwayat pencarian.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...history.map((loc) {
            final isFav = searchVm.isFavorite(loc);
            return LocationListTile(
              location: loc,
              isFavorite: isFav,
              onTap: () => _onSelectCity(loc),
              onToggleFavorite: () => searchVm.toggleFavorite(loc),
            );
          }),

        const SizedBox(height: 20),
      ],
    );
  }
}
