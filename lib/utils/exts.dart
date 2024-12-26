import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';

double kelvinToCelsius(double kelvin) {
  return kelvin - 273.15;
}

String formatTimestamp(DateTime timestamp) {
  final DateFormat formatter = DateFormat('d MMM yyyy, hh:mm a');
  return formatter.format(timestamp);
}

Future<bool> hasInternetConnection() async {
  return await InternetConnection().hasInternetAccess;
}