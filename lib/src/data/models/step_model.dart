import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/route_step.dart';
import '../../domain/entities/location.dart';
import 'location_model.dart';
import 'leg_model.dart';
import 'route_model.dart';

part 'step_model.g.dart';

@JsonSerializable()
class StepModel {
  @JsonKey(name: 'html_instructions')
  final String htmlInstructions;
  final DistanceModel distance;
  final DurationModel duration;
  @JsonKey(name: 'start_location')
  final LocationModel startLocation;
  @JsonKey(name: 'end_location')
  final LocationModel endLocation;
  @JsonKey(name: 'travel_mode')
  final String travelMode;
  @JsonKey(name: 'transit_details')
  final TransitDetailsModel? transitDetails;
  final PolylineModel? polyline;

  const StepModel({
    required this.htmlInstructions,
    required this.distance,
    required this.duration,
    required this.startLocation,
    required this.endLocation,
    required this.travelMode,
    this.transitDetails,
    this.polyline,
  });

  factory StepModel.fromJson(Map<String, dynamic> json) =>
      _$StepModelFromJson(json);

  Map<String, dynamic> toJson() => _$StepModelToJson(this);

  RouteStep toEntity() {
    return RouteStep(
      instruction: _stripHtmlTags(htmlInstructions),
      distance: distance.text,
      duration: duration.text,
      startLocation: Location(
        latitude: startLocation.lat,
        longitude: startLocation.lng,
      ),
      endLocation: Location(
        latitude: endLocation.lat,
        longitude: endLocation.lng,
      ),
      travelMode: _getTravelMode(),
      transitDetails: transitDetails != null ? _buildTransitDetails() : null,
      busNumber: transitDetails?.line?.shortName,
      busColor: null,
      departureStop: transitDetails?.departureStop?.name,
      arrivalStop: transitDetails?.arrivalStop?.name,
      departureTime: null,
      arrivalTime: null,
      polyline: polyline?.points,
      vehicleType: transitDetails?.line?.vehicle?.type?.toUpperCase(),
    );
  }

  String? _buildTransitDetails() {
    if (transitDetails == null) return null;
    
    final parts = <String>[];
    
    if (transitDetails!.line?.shortName != null) {
      parts.add('${transitDetails!.line!.vehicle?.name ?? 'Bus'} ${transitDetails!.line!.shortName}');
    } else if (transitDetails!.line?.name != null) {
      parts.add(transitDetails!.line!.name!);
    }
    
    if (transitDetails!.departureStop != null && transitDetails!.arrivalStop != null) {
      parts.add('${transitDetails!.departureStop!.name} → ${transitDetails!.arrivalStop!.name}');
    }
    
    return parts.isNotEmpty ? parts.join(' • ') : null;
  }

  TravelMode _getTravelMode() {
    switch (travelMode.toLowerCase()) {
      case 'walking':
        return TravelMode.walking;
      case 'transit':
        return TravelMode.transit;
      case 'driving':
        return TravelMode.driving;
      default:
        return TravelMode.walking;
    }
  }

  String _stripHtmlTags(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}

@JsonSerializable()
class TransitDetailsModel {
  @JsonKey(name: 'departure_stop')
  final TransitStopModel? departureStop;
  @JsonKey(name: 'arrival_stop')
  final TransitStopModel? arrivalStop;
  final TransitLineModel? line;

  const TransitDetailsModel({
    this.departureStop,
    this.arrivalStop,
    this.line,
  });

  factory TransitDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$TransitDetailsModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransitDetailsModelToJson(this);

  @override
  String toString() {
    return line?.name ?? 'Transit';
  }
}

@JsonSerializable()
class TransitStopModel {
  final String name;
  final LocationModel location;

  const TransitStopModel({
    required this.name,
    required this.location,
  });

  factory TransitStopModel.fromJson(Map<String, dynamic> json) =>
      _$TransitStopModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransitStopModelToJson(this);
}

@JsonSerializable()
class TransitLineModel {
  final String name;
  @JsonKey(name: 'short_name')
  final String? shortName;
  final TransitVehicleModel? vehicle;

  const TransitLineModel({
    required this.name,
    this.shortName,
    this.vehicle,
  });

  factory TransitLineModel.fromJson(Map<String, dynamic> json) =>
      _$TransitLineModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransitLineModelToJson(this);
}

@JsonSerializable()
class TransitVehicleModel {
  final String name;
  final String type;

  const TransitVehicleModel({
    required this.name,
    required this.type,
  });

  factory TransitVehicleModel.fromJson(Map<String, dynamic> json) =>
      _$TransitVehicleModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransitVehicleModelToJson(this);
}