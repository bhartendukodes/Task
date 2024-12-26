import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../repositories/weather_repository.dart';
import '../services/location_service.dart';
import '../utils/network_exception.dart';

enum WeatherState { initial, fetchingLocation, fetchingWeather, loaded, error }

class CurrentWeatherProvider extends ChangeNotifier {
  final WeatherRepository _weatherRepository;
  final LocationService _locationService;

  WeatherResponse? _weather;
  WeatherResponse? get weather => _weather;

  WeatherState _state = WeatherState.initial;
  WeatherState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  CurrentWeatherProvider(this._weatherRepository, this._locationService) {
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    _state = WeatherState.fetchingLocation;
    _errorMessage = '';
    notifyListeners();

    try {
      final position = await _locationService.getCurrentLocation();

      _state = WeatherState.fetchingWeather;
      notifyListeners();

      final response = await _weatherRepository.getWeather(
        position.latitude,
        position.longitude,
      );

      if (response.weather.isEmpty) {
        throw Exception("Invalid or incomplete weather data received.");
      }

      // Update weather and state
      _weather = response;
      _state = WeatherState.loaded;
    } on LocationPermissionDeniedException catch (e) {
      _errorMessage = e.message;
      _state = WeatherState.error;
    } on LocationPermissionPermanentlyDeniedException catch (e) {
      _errorMessage = e.message;
      _state = WeatherState.error;
    } on LocationServiceDisabledException catch (e) {
      _errorMessage = e.message;
      _state = WeatherState.error;
    } on NetworkException catch (e) {
      _errorMessage = e.message;
      _state = WeatherState.error;
    } on Exception catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _state = WeatherState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> retry() async {
    reset();
    await fetchWeather();
  }

  void reset() {
    _weather = null;
    _state = WeatherState.initial;
    _errorMessage = '';
    notifyListeners();
  }
}