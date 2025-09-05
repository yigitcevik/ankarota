import 'package:equatable/equatable.dart';
import 'location.dart';

enum TravelMode { walking, transit, driving }

class RouteStep extends Equatable {
  final String instruction;
  final String distance;
  final String duration;
  final Location startLocation;
  final Location endLocation;
  final TravelMode travelMode;
  final String? transitDetails;
  final String? busNumber;
  final String? busColor;
  final String? departureStop;
  final String? arrivalStop;
  final String? departureTime;
  final String? arrivalTime;
  final String? polyline;
  final String? vehicleType;

  const RouteStep({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.startLocation,
    required this.endLocation,
    required this.travelMode,
    this.transitDetails,
    this.busNumber,
    this.busColor,
    this.departureStop,
    this.arrivalStop,
    this.departureTime,
    this.arrivalTime,
    this.polyline,
    this.vehicleType,
  });

  @override
  List<Object?> get props => [
        instruction,
        distance,
        duration,
        startLocation,
        endLocation,
        travelMode,
        transitDetails,
        busNumber,
        busColor,
        departureStop,
        arrivalStop,
        departureTime,
        arrivalTime,
        polyline,
        vehicleType,
      ];
}