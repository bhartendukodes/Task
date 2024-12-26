
import '../models/weather.dart';
import '../services/weather_service.dart';

class WeatherRepository {
  final WeatherService _weatherService;

  WeatherRepository(this._weatherService);

  Future<WeatherResponse> getWeather(double lat, double lon) async {
    final data = await _weatherService.fetchWeather(lat, lon);
    return WeatherResponse.fromJson(data);
  }
}