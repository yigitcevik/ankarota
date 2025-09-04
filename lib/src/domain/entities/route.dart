import 'package:equatable/equatable.dart';
import 'location.dart';
import 'route_step.dart';

class RouteEntity extends Equatable {
  final String polyline;
  final List<RouteStep> steps;
  final String duration;
  final String distance;
  final Location startLocation;
  final Location endLocation;

  const RouteEntity({
    required this.polyline,
    required this.steps,
    required this.duration,
    required this.distance,
    required this.startLocation,
    required this.endLocation,
  });

  @override
  List<Object?> get props => [
        polyline,
        steps,
        duration,
        distance,
        startLocation,
        endLocation,
      ];
}