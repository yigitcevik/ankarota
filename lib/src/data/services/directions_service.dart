import 'package:dio/dio.dart';
import '../../core/config.dart';
import '../models/directions_response.dart';
import '../../domain/entities/location.dart';

class DirectionsService {
  final Dio _dio;

  DirectionsService({Dio? dio}) : _dio = dio ?? Dio();

  Future<DirectionsResponse> getDirections({
    required Location origin,
    required Location destination,
    String mode = 'transit',
  }) async {
    try {
      final response = await _dio.get(
        '${AppConfig.googleMapsBaseUrl}/directions/json',
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'mode': mode,
          'alternatives': true,
          'language': 'tr',
          'region': 'tr',
          'key': AppConfig.googleMapsApiKey,
        },
      );

      if (response.statusCode == 200) {
        return DirectionsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load directions: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}