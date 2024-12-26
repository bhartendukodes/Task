import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskdemo/widgets/weather_ui.dart';
import '../../../providers/current_weather_provider.dart';
import '../../../utils/exts.dart';
import '../../../widgets/error_display.dart';

class WeatherHomeScreen extends StatefulWidget {
  @override
  _WeatherHomeScreenState createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  late final Connectivity _connectivity;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _listenForConnectivityChanges();
  }

  void _listenForConnectivityChanges() {
     _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
      // Checking if there is a valid connection
      if (result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi)) {
        final weatherProvider = Provider.of<CurrentWeatherProvider>(context, listen: false);
        if (weatherProvider.state == WeatherState.error) {
          // Retrying fetching weather data when a network connection is available
          weatherProvider.fetchWeather();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<CurrentWeatherProvider>(context);

    return Scaffold(
      body: _buildBody(weatherProvider),
    );
  }

  Widget _buildBody(CurrentWeatherProvider weatherProvider) {
    switch (weatherProvider.state) {
      case WeatherState.fetchingLocation:
        return const Center(child: Text("Fetching location..."));
      case WeatherState.fetchingWeather:
        return const Center(child: CircularProgressIndicator());
      case WeatherState.loaded:
        return WeatherUI(weather: weatherProvider.weather!);
      case WeatherState.error:
        return _buildErrorUI(weatherProvider);
      default:
        return const Center(child: Text("Initializing..."));
    }
  }

  Widget _buildErrorUI(CurrentWeatherProvider weatherProvider) {
    return FutureBuilder<bool>(
      future: hasInternetConnection(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data == false) {
          return ErrorDisplay(
            title: "No Internet Connection",
            message: "Please check your internet connection and try again.",
            icon: Icons.wifi_off,
            onRetry: () {
              setState(() {
                weatherProvider.retry();
              });
            },
          );
        } else {
          return ErrorDisplay(
            title: "Server Error",
            message: weatherProvider.errorMessage,
            icon: Icons.error_outline,
            onRetry: () {
              setState(() {
                weatherProvider.retry();
              });
            },
          );
        }
      },
    );
  }
}