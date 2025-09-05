import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/location.dart';
import '../providers/location_provider.dart';
import '../../core/config.dart';
import 'map_selection_page.dart';

class AddressSearchPage extends ConsumerStatefulWidget {
  final String title;
  final String hint;
  final bool isOrigin;

  const AddressSearchPage({
    super.key,
    required this.title,
    required this.hint,
    required this.isOrigin,
  });

  @override
  ConsumerState<AddressSearchPage> createState() => _AddressSearchPageState();
}

class _AddressSearchPageState extends ConsumerState<AddressSearchPage> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocus = FocusNode();
  final Dio _dio = Dio();
  List<Prediction> predictions = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: searchController,
                focusNode: searchFocus,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              predictions.clear();
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                _buildQuickActionButton(
                  icon: Icons.gps_fixed,
                  iconColor: Colors.blue,
                  title: 'Current Location',
                  subtitle: 'Use GPS location',
                  onTap: _useCurrentLocation,
                ),
                const SizedBox(height: 8),
                _buildQuickActionButton(
                  icon: Icons.map,
                  iconColor: Colors.green,
                  title: 'Select from Map',
                  subtitle: 'Pick point from map',
                  onTap: _selectFromMap,
                ),
              ],
            ),
          ),
          
          Container(
            height: 8,
            color: Colors.grey[100],
          ),
          
          Expanded(
            child: Container(
              color: Colors.white,
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : predictions.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: predictions.length,
                          itemBuilder: (context, index) {
                            final prediction = predictions[index];
                            return _buildPredictionTile(prediction);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionTile(Prediction prediction) {
    return InkWell(
      onTap: () => _selectPrediction(prediction),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.location_on,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prediction.structuredFormatting?.mainText ?? prediction.description ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    prediction.structuredFormatting?.secondaryText ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Start address search',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start typing in the search box above\nor use quick options',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (searchController.text == query && query.isNotEmpty) {
        _searchPlaces(query);
      } else if (query.isEmpty) {
        setState(() {
          predictions.clear();
          isLoading = false;
        });
      }
    });
  }

  void _searchPlaces(String query) async {
    try {
      
      final response = await _searchWithGooglePlacesAPI(query);
      
      setState(() {
        predictions = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        predictions = [];
        isLoading = false;
      });
      _showSnackBar('Search error: $e');
    }
  }

  Future<List<Prediction>> _searchWithGooglePlacesAPI(String query) async {
    final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}'
        '&key=${AppConfig.googleMapsApiKey}'
        '&language=tr'
        '&components=country:tr'
        '&location=39.9334,32.8597'
        '&radius=50000'
        '&types=establishment|geocode';
    
    
    final response = await _dio.get(url);
    
    if (response.statusCode == 200) {
      final data = response.data;
      
      if (data['status'] == 'OK') {
        final predictions = <Prediction>[];
        
        for (final item in data['predictions']) {
          predictions.add(Prediction(
            description: item['description'],
            placeId: item['place_id'],
            structuredFormatting: StructuredFormatting(
              mainText: item['structured_formatting']?['main_text'] ?? '',
              secondaryText: item['structured_formatting']?['secondary_text'] ?? '',
            ),
          ));
        }
        
        return predictions;
      } else {
        throw Exception('API Error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
      }
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  void _useCurrentLocation() async {
    try {
      await ref.read(currentLocationProvider.notifier).getCurrentLocation();
      final locationState = ref.read(currentLocationProvider);
      
      if (locationState.hasValue && locationState.value != null) {
        final location = locationState.value!;
        final isRealLocation = !(location.latitude == 39.9334 && location.longitude == 32.8597);
        
        if (isRealLocation && mounted) {
          Navigator.pop(context, {
            'address': 'Current Location',
            'location': location,
          });
        } else {
          if (mounted) _showSnackBar('Location permission required. Please enable location services in settings.');
        }
      }
    } catch (e) {
      _showSnackBar('Location not available: $e');
    }
  }

  void _selectFromMap() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => MapSelectionPage(
          title: widget.title,
        ),
      ),
    );

    if (result != null && result['location'] != null) {
      if (mounted) Navigator.pop(context, result);
    }
  }

  void _selectPrediction(Prediction prediction) async {
    if (prediction.placeId?.isEmpty ?? true) return;
      
    try {
      final location = await _getPlaceDetails(prediction.placeId!);
      if (mounted) {
        Navigator.pop(context, {
          'address': prediction.description ?? 'Selected Location',
          'location': location,
        });
      }
    } catch (e) {
      _showSnackBar('Location details not available: $e');
    }
  }

  Future<Location> _getPlaceDetails(String placeId) async {
    final url = 'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&key=${AppConfig.googleMapsApiKey}'
        '&fields=geometry';
    
    
    final response = await _dio.get(url);
    
    if (response.statusCode == 200) {
      final data = response.data;
      
      if (data['status'] == 'OK') {
        final geometry = data['result']['geometry'];
        final locationData = geometry['location'];
        
        return Location(
          latitude: locationData['lat'].toDouble(),
          longitude: locationData['lng'].toDouble(),
        );
      } else {
        throw Exception('Place Details API Error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
      }
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocus.dispose();
    super.dispose();
  }
}