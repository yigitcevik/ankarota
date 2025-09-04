import 'package:json_annotation/json_annotation.dart';
import 'step_model.dart';
import 'location_model.dart';

part 'leg_model.g.dart';

@JsonSerializable()
class LegModel {
  final DistanceModel distance;
  final DurationModel duration;
  @JsonKey(name: 'start_location')
  final LocationModel startLocation;
  @JsonKey(name: 'end_location')
  final LocationModel endLocation;
  final List<StepModel> steps;

  const LegModel({
    required this.distance,
    required this.duration,
    required this.startLocation,
    required this.endLocation,
    required this.steps,
  });

  factory LegModel.fromJson(Map<String, dynamic> json) =>
      _$LegModelFromJson(json);

  Map<String, dynamic> toJson() => _$LegModelToJson(this);
}

@JsonSerializable()
class DistanceModel {
  final String text;
  final int value;

  const DistanceModel({
    required this.text,
    required this.value,
  });

  factory DistanceModel.fromJson(Map<String, dynamic> json) =>
      _$DistanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$DistanceModelToJson(this);
}

@JsonSerializable()
class DurationModel {
  final String text;
  final int value;

  const DurationModel({
    required this.text,
    required this.value,
  });

  factory DurationModel.fromJson(Map<String, dynamic> json) =>
      _$DurationModelFromJson(json);

  Map<String, dynamic> toJson() => _$DurationModelToJson(this);
}