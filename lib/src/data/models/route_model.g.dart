
part of 'route_model.dart';


RouteModel _$RouteModelFromJson(Map<String, dynamic> json) => RouteModel(
  overviewPolyline: PolylineModel.fromJson(
    json['overview_polyline'] as Map<String, dynamic>,
  ),
  legs: (json['legs'] as List<dynamic>)
      .map((e) => LegModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RouteModelToJson(RouteModel instance) =>
    <String, dynamic>{
      'overview_polyline': instance.overviewPolyline,
      'legs': instance.legs,
    };

PolylineModel _$PolylineModelFromJson(Map<String, dynamic> json) =>
    PolylineModel(points: json['points'] as String);

Map<String, dynamic> _$PolylineModelToJson(PolylineModel instance) =>
    <String, dynamic>{'points': instance.points};
