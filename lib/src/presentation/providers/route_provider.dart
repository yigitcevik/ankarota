import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/route.dart';
import '../../domain/entities/location.dart';
import 'providers.dart';

final routeProvider = AsyncNotifierProvider<RouteNotifier, RouteState?>(() {
  return RouteNotifier();
});

final selectedRouteIndexProvider = StateProvider<int>((ref) => 0);

class RouteState {
  final List<RouteEntity> routes;
  final int selectedIndex;

  const RouteState({
    required this.routes,
    this.selectedIndex = 0,
  });

  RouteEntity get selectedRoute => routes[selectedIndex];

  RouteState copyWith({
    List<RouteEntity>? routes,
    int? selectedIndex,
  }) {
    return RouteState(
      routes: routes ?? this.routes,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}

class RouteNotifier extends AsyncNotifier<RouteState?> {
  @override
  Future<RouteState?> build() async {
    return null;
  }

  Future<void> getRoute({
    required Location origin,
    required Location destination,
    String mode = 'transit',
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final getDirections = ref.read(getDirectionsProvider);
      final routes = await getDirections(
        origin: origin,
        destination: destination,
        mode: mode,
      );
      
      if (routes.isNotEmpty) {
        state = AsyncValue.data(RouteState(routes: routes));
        ref.read(selectedRouteIndexProvider.notifier).state = 0;
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void selectRoute(int index) {
    final currentState = state.value;
    if (currentState != null && index >= 0 && index < currentState.routes.length) {
      state = AsyncValue.data(currentState.copyWith(selectedIndex: index));
      ref.read(selectedRouteIndexProvider.notifier).state = index;
    }
  }

  void clearRoute() {
    state = const AsyncValue.data(null);
    ref.read(selectedRouteIndexProvider.notifier).state = 0;
  }
}