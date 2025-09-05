import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/route.dart';
import '../../domain/entities/location.dart';
import 'leg_model.dart';

part 'route_model.g.dart';

@JsonSerializable()
class RouteModel {
  @JsonKey(name: 'overview_polyline')
  final PolylineModel overviewPolyline;
  final List<LegModel> legs;

  const RouteModel({
    required this.overviewPolyline,
    required this.legs,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) =>
      _$RouteModelFromJson(json);

  Map<String, dynamic> toJson() => _$RouteModelToJson(this);

  RouteEntity toEntity() {
    final firstLeg = legs.first;
    final lastLeg = legs.last;

    return RouteEntity(
      polyline: overviewPolyline.points,
      steps: legs.expand((leg) => leg.steps.map((step) => step.toEntity())).toList(),
      duration: _formatDuration(legs.fold<int>(0, (sum, leg) => sum + leg.duration.value)),
      distance: _formatDistance(legs.fold<int>(0, (sum, leg) => sum + leg.distance.value)),
      startLocation: Location(
        latitude: firstLeg.startLocation.lat,
        longitude: firstLeg.startLocation.lng,
      ),
      endLocation: Location(
        latitude: lastLeg.endLocation.lat,
        longitude: lastLeg.endLocation.lng,
      ),
    );
  }

  static String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  static String _formatDistance(int meters) {
    if (meters >= 1000) {
      final km = (meters / 1000).toStringAsFixed(1);
      return '$km km';
    } else {
      return '${meters}m';
    }
  }
}

@JsonSerializable()
class PolylineModel {
  final String points;

  const PolylineModel({required this.points});

  factory PolylineModel.fromJson(Map<String, dynamic> json) =>
      _$PolylineModelFromJson(json);

  Map<String, dynamic> toJson() => _$PolylineModelToJson(this);
}