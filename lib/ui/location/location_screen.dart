import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:taskdemo/utils/exts.dart';
import '../../services/native_location_service.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  List<Map<String, dynamic>> locations = [];
  Map<int, String> placeNames = {}; // To store place names by index

  @override
  void initState() {
    super.initState();
    _startLocationService();
    NativeLocationService.initializeMethodChannel((updatedLocations) {
      setState(() {
        locations = updatedLocations;
        _fetchPlaceNames(locations);
      });
    });
  }

  Future<void> _startLocationService() async {
    await NativeLocationService.startService();
  }

  Future<void> _fetchPlaceNames(List<Map<String, dynamic>> updatedLocations) async {
    for (int i = 0; i < updatedLocations.length; i++) {
      final location = updatedLocations[i];
      final latitude = location['latitude'];
      final longitude = location['longitude'];

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          setState(() {
            placeNames[i] = "${place.locality}, ${place.country}";
          });
        }
      } catch (e) {
        print("Error fetching place name for $latitude, $longitude: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Real-Time Location"),
        elevation: 0,
      ),
      body: locations.isEmpty
          ? Center(
        child: Text(
          "Waiting for location updates...",
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];
          final latitude = location['latitude'];
          final longitude = location['longitude'];
          final timestamp = DateTime.fromMillisecondsSinceEpoch(
            location['timestamp'],
          );
          final placeName = placeNames[index] ?? "Fetching place name...";

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              elevation: 4, // Shadow depth
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              child: Padding(
                padding: const EdgeInsets.all(16), // Inner padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      placeName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Latitude: $latitude",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Longitude: $longitude",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      formatTimestamp(timestamp),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}