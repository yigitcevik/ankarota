import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/map_view.dart';
import '../widgets/route_search_panel.dart';
import '../widgets/route_steps_panel.dart';
import '../providers/route_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeState = ref.watch(routeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AnkaRota'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const MapView(),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: const RouteSearchPanel(),
          ),
          if (routeState.hasValue && routeState.value != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: RouteStepsPanel(
                routes: routeState.value!.routes,
                selectedRouteIndex: routeState.value!.selectedIndex,
                onRouteSelected: (index) {
                  ref.read(routeProvider.notifier).selectRoute(index);
                },
              ),
            ),
        ],
      ),
    );
  }
}