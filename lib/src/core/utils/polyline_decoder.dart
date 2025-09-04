import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolylineDecoder {
  static List<LatLng> decode(String polyline) {
    List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < polyline.length) {
      int shift = 0;
      int result = 0;
      int byte;

      do {
        byte = polyline.codeUnitAt(index) - 63;
        index++;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      int deltaLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += deltaLat;

      shift = 0;
      result = 0;

      do {
        byte = polyline.codeUnitAt(index) - 63;
        index++;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      int deltaLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += deltaLng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }
}