import 'package:flutter/material.dart';

class LocationList extends StatelessWidget {
  final List<String> locations;

  const LocationList({Key? key, required this.locations}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        return ListTile(
          title: Text(
            "Location: $location",
            style: TextStyle(fontSize: 16),
          ),
          subtitle: Text("Update #${index + 1}"),
        );
      },
    );
  }
}
