
part of 'directions_response.dart';


DirectionsResponse _$DirectionsResponseFromJson(Map<String, dynamic> json) =>
    DirectionsResponse(
      routes: (json['routes'] as List<dynamic>)
          .map((e) => RouteModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$DirectionsResponseToJson(DirectionsResponse instance) =>
    <String, dynamic>{'routes': instance.routes, 'status': instance.status};
