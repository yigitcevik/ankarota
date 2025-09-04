import '../entities/route.dart';
import '../entities/location.dart';
import '../repositories/directions_repository.dart';

class GetDirections {
  final DirectionsRepository _repository;

  GetDirections(this._repository);

  Future<List<RouteEntity>> call({
    required Location origin,
    required Location destination,
    String? mode,
  }) async {
    return await _repository.getDirections(
      origin: origin,
      destination: destination,
      mode: mode,
    );
  }
}