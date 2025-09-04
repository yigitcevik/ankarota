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
      duration: legs.fold<int>(0, (sum, leg) => sum + leg.duration.value).toString(),
      distance: legs.fold<int>(0, (sum, leg) => sum + leg.distance.value).toString(),
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
}

@JsonSerializable()
class PolylineModel {
  final String points;

  const PolylineModel({required this.points});

  factory PolylineModel.fromJson(Map<String, dynamic> json) =>
      _$PolylineModelFromJson(json);

  Map<String, dynamic> toJson() => _$PolylineModelToJson(this);
}