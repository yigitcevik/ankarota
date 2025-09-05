import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import '../../domain/entities/location.dart' as entities;
import '../providers/location_provider.dart';
import '../../core/config.dart';

class MapSelectionPage extends ConsumerStatefulWidget {
  final String title;

  const MapSelectionPage({
    super.key,
    required this.title,
  });

  @override
  ConsumerState<MapSelectionPage> createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends ConsumerState<MapSelectionPage> {
  GoogleMapController? _controller;
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoadingAddress = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentLocationProvider.notifier).getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(currentLocationProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () {
            if (mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: _confirmSelection,
              child: const Text(
                'Select',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                locationState.value?.latitude ?? AppConfig.defaultLatitude,
                locationState.value?.longitude ?? AppConfig.defaultLongitude,
              ),
              zoom: 15.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            onCameraMove: (CameraPosition position) {
              _selectedLocation = position.target;
            },
            onCameraIdle: () {
              if (_selectedLocation != null) {
                setState(() {});
                _getAddressFromCoordinates(_selectedLocation!);
              }
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            trafficEnabled: false,
            buildingsEnabled: true,
          ),

          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 35),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: Image.asset(
                      'assets/pin.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Colors.blue[600],
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Location',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (_isLoadingAddress)
                              Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Loading address...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                _selectedAddress.isEmpty 
                                    ? 'Move map to select location'
                                    : _selectedAddress,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _selectedLocation != null ? _confirmSelection : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Select This Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 200,
            right: 20,
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation,
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              elevation: 4,
              mini: true,
              child: const Icon(Icons.my_location, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _getAddressFromCoordinates(LatLng coordinates) async {
    _debounceTimer?.cancel();
    
    setState(() {
      _selectedAddress = '';
      _isLoadingAddress = true;
    });
    
    _debounceTimer = Timer(const Duration(milliseconds: 800), () async {
      try {
        final List<Placemark> placemarks = await placemarkFromCoordinates(
          coordinates.latitude,
          coordinates.longitude,
        );

        if (placemarks.isNotEmpty && mounted) {
          final placemark = placemarks.first;
          
          final addressParts = <String>[];
          
          String? streetAddress;
          if (placemark.street != null && placemark.street!.isNotEmpty) {
            streetAddress = placemark.street!;
            if (placemark.subThoroughfare != null && placemark.subThoroughfare!.isNotEmpty) {
              streetAddress += ' ${placemark.subThoroughfare!}';
            }
          } else if (placemark.subThoroughfare != null && placemark.subThoroughfare!.isNotEmpty) {
            streetAddress = placemark.subThoroughfare!;
          }
          
          if (streetAddress != null) {
            addressParts.add(streetAddress);
          }
          
          String? neighborhood;
          if (placemark.thoroughfare != null && placemark.thoroughfare!.isNotEmpty) {
            neighborhood = placemark.thoroughfare!;
          } else if (placemark.locality != null && placemark.locality!.isNotEmpty) {
            neighborhood = placemark.locality!;
          }
          
          if (neighborhood != null && !addressParts.contains(neighborhood)) {
            addressParts.add(neighborhood);
          }
          
          if (placemark.subAdministrativeArea != null && 
              placemark.subAdministrativeArea!.isNotEmpty &&
              !addressParts.contains(placemark.subAdministrativeArea!)) {
            addressParts.add(placemark.subAdministrativeArea!);
          }
          
          if (placemark.administrativeArea != null && 
              placemark.administrativeArea!.isNotEmpty &&
              !addressParts.contains(placemark.administrativeArea!)) {
            addressParts.add(placemark.administrativeArea!);
          }

          setState(() {
            _selectedAddress = addressParts.join(', ');
            _isLoadingAddress = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _selectedAddress = 'Lat: ${coordinates.latitude.toStringAsFixed(6)}, Lng: ${coordinates.longitude.toStringAsFixed(6)}';
            _isLoadingAddress = false;
          });
        }
      }
    });
  }

  void _goToCurrentLocation() async {
    if (_controller == null) return;

    await ref.read(currentLocationProvider.notifier).getCurrentLocation();
    final locationState = ref.read(currentLocationProvider);

    if (locationState.hasValue && locationState.value != null) {
      final location = locationState.value!;
      final isRealLocation = !(location.latitude == 39.9334 && location.longitude == 32.8597);

      if (isRealLocation) {
        await _controller!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(location.latitude, location.longitude),
            16.0,
          ),
        );
      } else {
        _showSnackBar('Location permission required. Please enable location services in settings.');
      }
    }
  }

  void _confirmSelection() {
    if (_selectedLocation != null && mounted && Navigator.canPop(context)) {
      Navigator.pop(context, {
        'address': _selectedAddress.isEmpty ? 'Selected Location' : _selectedAddress,
        'location': entities.Location(
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
        ),
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

