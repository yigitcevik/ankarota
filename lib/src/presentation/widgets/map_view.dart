import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/config.dart';
import '../providers/location_provider.dart';
import '../providers/route_provider.dart';
import '../../core/utils/polyline_decoder.dart';
import '../../domain/entities/route_step.dart';

class MapView extends ConsumerStatefulWidget {
  const MapView({super.key});

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  GoogleMapController? _controller;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentLocationProvider.notifier).getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(currentLocationProvider);

    ref.listen(routeProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        _updateRoute(next.value!.selectedRoute);
      } else {
        _clearRoute();
      }
    });

    ref.listen(selectedRouteIndexProvider, (previous, next) {
      final routeState = ref.read(routeProvider);
      if (routeState.hasValue && routeState.value != null) {
        _updateRoute(routeState.value!.selectedRoute);
      }
    });


    return Stack(
      children: [
        GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(
          locationState.value?.latitude ?? AppConfig.defaultLatitude,
          locationState.value?.longitude ?? AppConfig.defaultLongitude,
        ),
        zoom: AppConfig.defaultZoom,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      polylines: _polylines,
      markers: _markers,
      compassEnabled: true,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      trafficEnabled: false,
      buildingsEnabled: true,
    ),
        
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () => _goToCurrentLocation(locationState),
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            elevation: 4,
            mini: true,
            child: const Icon(
              Icons.my_location,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  void _updateRoute(route) {
    setState(() {
      _polylines = _createColoredPolylines(route);
      _markers = _createMarkers(route);
    });

    _fitBounds(route);
  }

  Set<Marker> _createMarkers(route) {
    Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('start'),
        position: LatLng(
          route.startLocation.latitude,
          route.startLocation.longitude,
        ),
        infoWindow: const InfoWindow(title: 'Start'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('end'),
        position: LatLng(
          route.endLocation.latitude,
          route.endLocation.longitude,
        ),
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    if (route.steps != null) {
      for (int i = 0; i < route.steps.length; i++) {
        final step = route.steps[i];
        if (step.travelMode == TravelMode.transit) {
          if (step.departureStop != null) {
            markers.add(
              Marker(
                markerId: MarkerId('transit_start_$i'),
                position: LatLng(
                  step.startLocation.latitude,
                  step.startLocation.longitude,
                ),
                infoWindow: InfoWindow(
                  title: step.departureStop!,
                  snippet: step.busNumber ?? 'Transit',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerHue(step.vehicleType)),
              ),
            );
          }
          if (step.arrivalStop != null) {
            markers.add(
              Marker(
                markerId: MarkerId('transit_end_$i'),
                position: LatLng(
                  step.endLocation.latitude,
                  step.endLocation.longitude,
                ),
                infoWindow: InfoWindow(
                  title: step.arrivalStop!,
                  snippet: step.busNumber ?? 'Transit',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerHue(step.vehicleType)),
              ),
            );
          }
        }
      }
    }

    return markers;
  }

  Set<Polyline> _createColoredPolylines(route) {
    Set<Polyline> polylines = {};
    
    if (route.steps == null || route.steps.isEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: PolylineDecoder.decode(route.polyline),
          color: Colors.blue,
          width: 5,
        ),
      );
      return polylines;
    }

    for (int i = 0; i < route.steps.length; i++) {
      final step = route.steps[i];
      if (step.polyline != null && step.polyline.isNotEmpty) {
        final points = PolylineDecoder.decode(step.polyline);
        if (points.isNotEmpty) {
          polylines.add(
            Polyline(
              polylineId: PolylineId('step_$i'),
              points: points,
              color: _getTravelModeColor(step.travelMode, step.vehicleType),
              width: _getTravelModeWidth(step.travelMode),
              patterns: _getTravelModePattern(step.travelMode),
            ),
          );
        }
      }
    }

    if (polylines.isEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: PolylineDecoder.decode(route.polyline),
          color: Colors.blue,
          width: 5,
        ),
      );
    }

    return polylines;
  }

  Color _getTravelModeColor(TravelMode mode, [String? vehicleType]) {
    switch (mode) {
      case TravelMode.walking:
        return Colors.green;
      case TravelMode.transit:
        return _getTransitColor(vehicleType);
      case TravelMode.driving:
        return Colors.orange;   
    }
  }

  Color _getTransitColor(String? vehicleType) {
    if (vehicleType == null) return Colors.blue;
    
    switch (vehicleType.toUpperCase()) {
      case 'SUBWAY':
      case 'METRO':
      case 'UNDERGROUND':
        return Colors.red;
      case 'BUS':
        return Colors.blue;
      case 'TRAM':
      case 'LIGHT_RAIL':
        return Colors.purple;
      case 'TRAIN':
      case 'RAIL':
        return Colors.orange;
      case 'FERRY':
        return Colors.cyan;
      default:
        return Colors.blue;
    }
  }

  int _getTravelModeWidth(TravelMode mode) {
    switch (mode) {
      case TravelMode.walking:
        return 4;
      case TravelMode.transit:
        return 6;
      case TravelMode.driving:
        return 5;
    }
  }

  List<PatternItem> _getTravelModePattern(TravelMode mode) {
    switch (mode) {
      case TravelMode.walking:
        return [PatternItem.dot, PatternItem.gap(10)];
      case TravelMode.transit:
        return [];
      case TravelMode.driving:
        return [];
    }
  }

  double _getMarkerHue(String? vehicleType) {
    if (vehicleType == null) return BitmapDescriptor.hueBlue;
    
    switch (vehicleType.toUpperCase()) {
      case 'SUBWAY':
      case 'METRO':
      case 'UNDERGROUND':
        return BitmapDescriptor.hueRed;
      case 'BUS':
        return BitmapDescriptor.hueBlue;
      case 'TRAM':
      case 'LIGHT_RAIL':
        return BitmapDescriptor.hueViolet;
      case 'TRAIN':
      case 'RAIL':
        return BitmapDescriptor.hueOrange;
      case 'FERRY':
        return BitmapDescriptor.hueCyan;
      default:
        return BitmapDescriptor.hueBlue;
    }
  }

  void _clearRoute() {
    setState(() {
      _polylines.clear();
      _markers.clear();
    });
  }

  void _goToCurrentLocation(AsyncValue locationState) async {
    if (_controller == null) return;

    final hasLocation = locationState.hasValue && 
        locationState.value != null && 
        !(locationState.value!.latitude == 39.9334 && locationState.value!.longitude == 32.8597);

    if (hasLocation) {
      final location = locationState.value!;
      await _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(location.latitude, location.longitude),
          16.0,
        ),
      );
    } else {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      if (!serviceEnabled || permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (!serviceEnabled) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location services are disabled. Please enable location services in device settings.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location permission denied.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission permanently denied. Please grant permission from app settings.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
          }
          return;
        }
      }

      await ref.read(currentLocationProvider.notifier).getCurrentLocation();
      
      final updatedLocationState = ref.read(currentLocationProvider);
      final hasUpdatedLocation = updatedLocationState.hasValue && 
          updatedLocationState.value != null && 
          !(updatedLocationState.value!.latitude == 39.9334 && updatedLocationState.value!.longitude == 32.8597);
          
      if (hasUpdatedLocation) {
        final location = updatedLocationState.value!;
        await _controller!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(location.latitude, location.longitude),
            16.0,
          ),
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location not available. Please ensure location services are enabled.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  void _fitBounds(route) {
    if (_controller == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        route.startLocation.latitude < route.endLocation.latitude
            ? route.startLocation.latitude
            : route.endLocation.latitude,
        route.startLocation.longitude < route.endLocation.longitude
            ? route.startLocation.longitude
            : route.endLocation.longitude,
      ),
      northeast: LatLng(
        route.startLocation.latitude > route.endLocation.latitude
            ? route.startLocation.latitude
            : route.endLocation.latitude,
        route.startLocation.longitude > route.endLocation.longitude
            ? route.startLocation.longitude
            : route.endLocation.longitude,
      ),
    );

    _controller!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0),
    );
  }
}