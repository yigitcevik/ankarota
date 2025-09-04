import '../entities/route.dart';
import '../entities/location.dart';

abstract class DirectionsRepository {
  Future<List<RouteEntity>> getDirections({
    required Location origin,
    required Location destination,
    String? mode,
  });
}