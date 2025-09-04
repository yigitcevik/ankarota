import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/location.dart';
import '../../core/config.dart';
import 'providers.dart';

final currentLocationProvider = AsyncNotifierProvider<LocationNotifier, Location>(() {
  return LocationNotifier();
});

class LocationNotifier extends AsyncNotifier<Location> {
  @override
  Future<Location> build() async {
    return const Location(
      latitude: AppConfig.defaultLatitude,
      longitude: AppConfig.defaultLongitude,
    );
  }

  Future<void> getCurrentLocation() async {
    state = const AsyncValue.loading();
    
    try {
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getCurrentLocation();
      state = AsyncValue.data(location);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      
      state = const AsyncValue.data(Location(
        latitude: AppConfig.defaultLatitude,
        longitude: AppConfig.defaultLongitude,
      ));
    }
  }
}