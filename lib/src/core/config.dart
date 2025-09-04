import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get googleMapsApiKey => 
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  
  static const String googleMapsBaseUrl = 'https://maps.googleapis.com/maps/api';
  
  static const double defaultLatitude = 39.9334; // Ankara
  static const double defaultLongitude = 32.8597;
  
  static const double defaultZoom = 12.0;
  static const double routeZoom = 15.0;
}