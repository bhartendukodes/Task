import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskdemo/ui/weather/dashboard/weather_home_screen.dart';
import '../../providers/current_weather_provider.dart';
import '../../repositories/weather_repository.dart';
import '../../services/location_service.dart';
import '../../services/weather_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide the WeatherService
        Provider(create: (_) => WeatherService()),

        // Provide the LocationService
        Provider(create: (_) => LocationService()),

        // Create WeatherRepository and pass WeatherService to it
        ProxyProvider<WeatherService, WeatherRepository>(
          update: (_, weatherService, __) => WeatherRepository(weatherService),
        ),

        // Provide WeatherProvider with WeatherRepository and LocationService
        ChangeNotifierProxyProvider2<WeatherRepository, LocationService, CurrentWeatherProvider>(
          create: (_) => CurrentWeatherProvider(
            WeatherRepository(WeatherService()),
            LocationService(),
          ),
          update: (_, weatherRepository, locationService, __) =>
              CurrentWeatherProvider(weatherRepository, locationService),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(primarySwatch: Colors.blue),
        home: WeatherHomeScreen(),
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
      ),
    );
  }
}