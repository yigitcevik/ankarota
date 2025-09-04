import 'package:json_annotation/json_annotation.dart';
import 'route_model.dart';

part 'directions_response.g.dart';

@JsonSerializable()
class DirectionsResponse {
  final List<RouteModel> routes;
  final String status;

  const DirectionsResponse({
    required this.routes,
    required this.status,
  });

  factory DirectionsResponse.fromJson(Map<String, dynamic> json) =>
      _$DirectionsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DirectionsResponseToJson(this);
}