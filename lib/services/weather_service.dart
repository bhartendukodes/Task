import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../utils/network_exception.dart';

class WeatherService {
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  final String _apiKey = dotenv.env['OPEN_WEATHER_API_KEY'] ?? '';

  Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    try {
      final Uri url = Uri.parse('$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to fetch current weather data: ${response.body}');
      }
    } on http.ClientException {
      throw NetworkException("Unable to connect to the network.");
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }
}
