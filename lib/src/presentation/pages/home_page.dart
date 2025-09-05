import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/map_view.dart';
import '../widgets/route_search_panel.dart';
import '../widgets/route_bottom_sheet.dart';
import '../providers/route_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isBottomSheetVisible = false;

  void _showRouteBottomSheet() {
    if (_isBottomSheetVisible) return;
    
    setState(() {
      _isBottomSheetVisible = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final routeState = ref.read(routeProvider);
        if (!routeState.hasValue || routeState.value == null) {
          return const SizedBox.shrink();
        }
        
        return RouteBottomSheet(
          routes: routeState.value!.routes,
          selectedRouteIndex: routeState.value!.selectedIndex,
          onRouteSelected: (index) {
            ref.read(routeProvider.notifier).selectRoute(index);
          },
        );
      },
    ).whenComplete(() {
      setState(() {
        _isBottomSheetVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeState = ref.watch(routeProvider);

    ref.listen(routeProvider, (previous, current) {
      if (current.hasValue && 
          current.value != null && 
          !_isBottomSheetVisible &&
          (previous?.value == null || previous!.value!.routes.isEmpty)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showRouteBottomSheet();
        });
      }
    });

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
          if (routeState.hasValue && 
              routeState.value != null && 
              !_isBottomSheetVisible)
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButton(
                onPressed: _showRouteBottomSheet,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.route, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}