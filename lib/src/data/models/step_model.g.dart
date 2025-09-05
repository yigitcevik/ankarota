
part of 'step_model.dart';


StepModel _$StepModelFromJson(Map<String, dynamic> json) => StepModel(
  htmlInstructions: json['html_instructions'] as String,
  distance: DistanceModel.fromJson(json['distance'] as Map<String, dynamic>),
  duration: DurationModel.fromJson(json['duration'] as Map<String, dynamic>),
  startLocation: LocationModel.fromJson(
    json['start_location'] as Map<String, dynamic>,
  ),
  endLocation: LocationModel.fromJson(
    json['end_location'] as Map<String, dynamic>,
  ),
  travelMode: json['travel_mode'] as String,
  transitDetails: json['transit_details'] == null
      ? null
      : TransitDetailsModel.fromJson(
          json['transit_details'] as Map<String, dynamic>,
        ),
  polyline: json['polyline'] == null
      ? null
      : PolylineModel.fromJson(json['polyline'] as Map<String, dynamic>),
);

Map<String, dynamic> _$StepModelToJson(StepModel instance) => <String, dynamic>{
  'html_instructions': instance.htmlInstructions,
  'distance': instance.distance,
  'duration': instance.duration,
  'start_location': instance.startLocation,
  'end_location': instance.endLocation,
  'travel_mode': instance.travelMode,
  'transit_details': instance.transitDetails,
  'polyline': instance.polyline,
};

TransitDetailsModel _$TransitDetailsModelFromJson(Map<String, dynamic> json) =>
    TransitDetailsModel(
      departureStop: json['departure_stop'] == null
          ? null
          : TransitStopModel.fromJson(
              json['departure_stop'] as Map<String, dynamic>,
            ),
      arrivalStop: json['arrival_stop'] == null
          ? null
          : TransitStopModel.fromJson(
              json['arrival_stop'] as Map<String, dynamic>,
            ),
      line: json['line'] == null
          ? null
          : TransitLineModel.fromJson(json['line'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TransitDetailsModelToJson(
  TransitDetailsModel instance,
) => <String, dynamic>{
  'departure_stop': instance.departureStop,
  'arrival_stop': instance.arrivalStop,
  'line': instance.line,
};

TransitStopModel _$TransitStopModelFromJson(Map<String, dynamic> json) =>
    TransitStopModel(
      name: json['name'] as String,
      location: LocationModel.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$TransitStopModelToJson(TransitStopModel instance) =>
    <String, dynamic>{'name': instance.name, 'location': instance.location};

TransitLineModel _$TransitLineModelFromJson(Map<String, dynamic> json) =>
    TransitLineModel(
      name: json['name'] as String,
      shortName: json['short_name'] as String?,
      vehicle: json['vehicle'] == null
          ? null
          : TransitVehicleModel.fromJson(
              json['vehicle'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$TransitLineModelToJson(TransitLineModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'short_name': instance.shortName,
      'vehicle': instance.vehicle,
    };

TransitVehicleModel _$TransitVehicleModelFromJson(Map<String, dynamic> json) =>
    TransitVehicleModel(
      name: json['name'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$TransitVehicleModelToJson(
  TransitVehicleModel instance,
) => <String, dynamic>{'name': instance.name, 'type': instance.type};
