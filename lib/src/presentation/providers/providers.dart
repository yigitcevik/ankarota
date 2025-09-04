import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/directions_service.dart';
import '../../data/services/location_service.dart';
import '../../data/repositories/directions_repository_impl.dart';
import '../../domain/usecases/get_directions.dart';

final directionsServiceProvider = Provider<DirectionsService>((ref) {
  return DirectionsService();
});

final directionsRepositoryProvider = Provider<DirectionsRepositoryImpl>((ref) {
  return DirectionsRepositoryImpl(ref.read(directionsServiceProvider));
});

final getDirectionsProvider = Provider<GetDirections>((ref) {
  return GetDirections(ref.read(directionsRepositoryProvider));
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});