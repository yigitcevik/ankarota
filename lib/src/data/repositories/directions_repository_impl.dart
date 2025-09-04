import '../../domain/entities/route.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/directions_repository.dart';
import '../services/directions_service.dart';

class DirectionsRepositoryImpl implements DirectionsRepository {
  final DirectionsService _service;

  DirectionsRepositoryImpl(this._service);
  @override
  Future<List<RouteEntity>> getDirections({
    required Location origin,
    required Location destination,
    String? mode,
  }) async {
    try {
      final response = await _service.getDirections(
        origin: origin,
        destination: destination,
        mode: mode ?? 'transit',
      );

      if (response.routes.isEmpty) {
        throw Exception('No routes found');
      }

      return response.routes.map((route) => route.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get directions: $e');
    }
  }
}