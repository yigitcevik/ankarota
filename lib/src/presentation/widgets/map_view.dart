import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/config.dart';
import '../providers/location_provider.dart';
import '../providers/route_provider.dart';
import '../../core/utils/polyline_decoder.dart';

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
      // Enable traffic layer for debugging
      trafficEnabled: false,
      // Enable building layer
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
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: PolylineDecoder.decode(route.polyline),
          color: Colors.blue,
          width: 5,
        ),
      };

      _markers = {
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
    });

    _fitBounds(route);
  }

  void _clearRoute() {
    setState(() {
      _polylines.clear();
      _markers.clear();
    });
  }

  void _goToCurrentLocation(AsyncValue locationState) async {
    if (_controller == null) return;

    // Check if we have a real location (not the default one)
    final hasRealLocation = locationState.hasValue && 
        locationState.value != null && 
        !(locationState.value!.latitude == 39.9334 && locationState.value!.longitude == 32.8597);

    if (hasRealLocation) {
      final location = locationState.value!;
      await _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(location.latitude, location.longitude),
          16.0,
        ),
      );
    } else {
      // Check location permission and services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      if (!serviceEnabled || permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        // Request location permission - this will trigger Android's native dialog
        if (!serviceEnabled) {
          // Location services are disabled
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Konum servisleri kapalı. Lütfen cihaz ayarlarından konum servislerini açın.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        if (permission == LocationPermission.denied) {
          // Request permission - this shows Android's native permission dialog
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Konum izni reddedildi.'),
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
                content: Text('Konum izni kalıcı olarak reddedildi. Lütfen uygulama ayarlarından izin verin.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
          }
          return;
        }
      }

      // Try to get location after permission is granted
      await ref.read(currentLocationProvider.notifier).getCurrentLocation();
      
      // Check if we now have a real location
      final updatedLocationState = ref.read(currentLocationProvider);
      final hasUpdatedRealLocation = updatedLocationState.hasValue && 
          updatedLocationState.value != null && 
          !(updatedLocationState.value!.latitude == 39.9334 && updatedLocationState.value!.longitude == 32.8597);
          
      if (hasUpdatedRealLocation) {
        final location = updatedLocationState.value!;
        await _controller!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(location.latitude, location.longitude),
            16.0,
          ),
        );
      } else {
        // Show error message if still couldn't get real location
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Konum alınamadı. Lütfen konum servislerinin açık olduğundan emin olun.'),
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