
part of 'leg_model.dart';


LegModel _$LegModelFromJson(Map<String, dynamic> json) => LegModel(
  distance: DistanceModel.fromJson(json['distance'] as Map<String, dynamic>),
  duration: DurationModel.fromJson(json['duration'] as Map<String, dynamic>),
  startLocation: LocationModel.fromJson(
    json['start_location'] as Map<String, dynamic>,
  ),
  endLocation: LocationModel.fromJson(
    json['end_location'] as Map<String, dynamic>,
  ),
  steps: (json['steps'] as List<dynamic>)
      .map((e) => StepModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LegModelToJson(LegModel instance) => <String, dynamic>{
  'distance': instance.distance,
  'duration': instance.duration,
  'start_location': instance.startLocation,
  'end_location': instance.endLocation,
  'steps': instance.steps,
};

DistanceModel _$DistanceModelFromJson(Map<String, dynamic> json) =>
    DistanceModel(
      text: json['text'] as String,
      value: (json['value'] as num).toInt(),
    );

Map<String, dynamic> _$DistanceModelToJson(DistanceModel instance) =>
    <String, dynamic>{'text': instance.text, 'value': instance.value};

DurationModel _$DurationModelFromJson(Map<String, dynamic> json) =>
    DurationModel(
      text: json['text'] as String,
      value: (json['value'] as num).toInt(),
    );

Map<String, dynamic> _$DurationModelToJson(DurationModel instance) =>
    <String, dynamic>{'text': instance.text, 'value': instance.value};
