import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'search_screen.dart';
import 'widgets/current_weather_card.dart';
import 'widgets/daily_forecast_item.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/weather_info_tile.dart';

/// Layar Utama Cuaca (Home / Weather Screen)
/// Menampilkan cuaca saat ini, detail metrik, dan prakiraan 7 hari ke depan
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Memuat cuaca awal setelah frame pertama dirender
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherViewModel>().initializeWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuaca'),
        actions: [
          // Tombol Buka Layar Pencarian
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Cari Kota',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          // Tombol Refresh Cuaca
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: () {
              context.read<WeatherViewModel>().refreshWeather();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<WeatherViewModel>(
          builder: (context, vm, child) {
            // 1. STATE LOADING
            if (vm.isLoading) {
              return const LoadingView(message: 'Mengambil prakiraan cuaca...');
            }

            // 2. STATE ERROR
            if (vm.isError) {
              return ErrorView(
                message: vm.errorMessage,
                onRetry: () => vm.refreshWeather(),
              );
            }

            // 3. STATE EMPTY
            if (vm.isEmpty || vm.selectedLocation == null || vm.weatherData == null) {
              return EmptyView(
                icon: Icons.location_off_rounded,
                title: 'Belum Ada Kota',
                message: vm.errorMessage ?? 'Silakan cari dan pilih kota terlebih dahulu.',
                actionLabel: 'Cari Kota Sekarang',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
              );
            }

            // 4. STATE SUCCESS
            final location = vm.selectedLocation!;
            final weather = vm.weatherData!;
            final dailyList = weather.daily;
            final todayRainProb =
                dailyList.isNotEmpty ? dailyList.first.precipitationProbability : 0;

            return RefreshIndicator(
              onRefresh: () => vm.refreshWeather(),
              child: Center(
                // Membatasi lebar konten maksimal pada layar lebar/desktop/tablet
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    children: [
                      // Kartu Cuaca Saat Ini
                      CurrentWeatherCard(
                        location: location,
                        weather: weather.current,
                      ),
                      const SizedBox(height: 16),

                      // Petak Informasi Tambahan (Kelembapan, Angin, Peluang Hujan, Curah Hujan)
                      WeatherInfoTile(
                        weather: weather.current,
                        todayRainProbability: todayRainProb,
                      ),
                      const SizedBox(height: 20),

                      // Header Bagian Prakiraan 7 Hari
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Prakiraan 7 Hari ke Depan',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Maks / Min',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Daftar Prakiraan Cuaca Harian
                      ...dailyList.asMap().entries.map((entry) {
                        final index = entry.key;
                        final forecast = entry.value;
                        return DailyForecastItem(
                          forecast: forecast,
                          isToday: index == 0,
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
