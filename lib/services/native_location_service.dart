import 'dart:async';
import 'package:flutter/services.dart';

class NativeLocationService {
  static const _platform = MethodChannel('locationChannel');

  static Future<void> startService() async {
    try {
      final result = await _platform.invokeMethod('startService');
      print(result);
    } catch (e) {
      print("Error starting location service: $e");
    }
  }

  static void initializeMethodChannel(
      Function(List<Map<String, dynamic>>) onLocationsUpdate) {
    _platform.setMethodCallHandler((call) async {
      if (call.method == 'savedLocations') {
        try {
          // Explicitly cast the data
          final locations = (call.arguments as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
          onLocationsUpdate(locations);
        } catch (e) {
          print("Error parsing locations: $e");
        }
      }
    });
  }
}
