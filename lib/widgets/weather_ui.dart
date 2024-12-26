import 'package:flutter/material.dart';

import '../models/weather.dart';

class WeatherUI extends StatelessWidget {
  final WeatherResponse weather;

  const WeatherUI({Key? key, required this.weather}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract data from the passed weather object
    final temperature = weather.main.temp;
    final realFeel = weather.main.feelsLike;
    final windSpeed = weather.wind.speed;
    final pressure = weather.main.pressure;
    final humidity = weather.main.humidity;
    final location = weather.name;

    // Determine background image based on weather condition
    final condition = weather.weather[0].main.toLowerCase();
    String backgroundImage;
    if (condition.contains('cloud')) {
      backgroundImage = 'assets/cloudy.png';
    } else if (condition.contains('sun') || condition.contains('clear')) {
      backgroundImage = 'assets/sunny.png';
    } else if (condition.contains('night')) {
      backgroundImage = 'assets/night.png';
    } else {
      backgroundImage = 'assets/sunny.png';
    }

    // Format date
    final now = DateTime.now();
    final date = "${now.day} ${_getMonthName(now.month)}";
    final day = _getDayName(now.weekday);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              backgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          // Main Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 56),
                  child: Text(
                    "$date, $day",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Temperature and Real Feel
                Row(
                  children: [
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${temperature.toStringAsFixed(0)}°C",
                          style: TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Real feel ${realFeel.toStringAsFixed(0)}°C",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        )
                      ],
                    )
                  ],
                ),

                Spacer(),

                // Location Name
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(children: [
                    Spacer(),
                    Image.asset(
                      "assets/ic_location_pin.png",
                      height: 24,
                      width: 24,
                      color: Colors.white,
                    ),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500
                      ),
                    )
                  ],),
                ),
                const SizedBox(height: 40),

                // Wind, Pressure, and Humidity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoCard(
                        "Wind",
                        "${windSpeed.toStringAsFixed(1)} km/h",
                        "assets/ic_wind.png"),
                    _buildInfoCard("Pressure", "$pressure MB",
                        "assets/ic_temperature.png"),
                    _buildInfoCard(
                        "Humidity", "$humidity%", "assets/ic_water_drop.png"),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Info Cards
  Widget _buildInfoCard(String title, String value, String image) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            height: 24,
            width: 24,
            color: Colors.white,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to get month name
  String _getMonthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }

  // Helper to get day name
  String _getDayName(int weekday) {
    const days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];
    return days[weekday - 1];
  }
}
