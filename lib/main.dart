import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'repositories/weather_repository.dart';
import 'services/local_storage_service.dart';
import 'services/weather_api_service.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Service dan Repository (Single Source of Truth)
  final apiService = WeatherApiService();
  final storageService = LocalStorageService();
  final weatherRepository = WeatherRepository(
    apiService: apiService,
    storageService: storageService,
  );

  runApp(CuacaApp(weatherRepository: weatherRepository));
}

/// Root Widget aplikasi Cuaca
class CuacaApp extends StatelessWidget {
  final WeatherRepository? weatherRepository;

  const CuacaApp({super.key, this.weatherRepository});

  @override
  Widget build(BuildContext context) {
    final repository = weatherRepository ?? WeatherRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WeatherViewModel(repository),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchViewModel(repository),
        ),
      ],
      child: MaterialApp(
        title: 'Cuaca',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
