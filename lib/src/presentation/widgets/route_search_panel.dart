import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../../domain/entities/location.dart';
import '../providers/route_provider.dart';
import '../providers/location_provider.dart';
import '../../core/config.dart';
import '../pages/address_search_page.dart';

class RouteSearchPanel extends ConsumerStatefulWidget {
  const RouteSearchPanel({super.key});

  @override
  ConsumerState<RouteSearchPanel> createState() => _RouteSearchPanelState();
}

class _RouteSearchPanelState extends ConsumerState<RouteSearchPanel>
    with TickerProviderStateMixin {
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  bool _isSearching = false;
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  
  Location? _originLocation;
  Location? _destinationLocation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final routeState = ref.watch(routeProvider);
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSimpleHeader(),
          
          AnimatedBuilder(
            animation: _heightAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  heightFactor: _heightAnimation.value,
                  child: child,
                ),
              );
            },
            child: _buildExpandedContent(routeState),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleHeader() {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
        if (_isExpanded) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.directions,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isExpanded ? 'Plan Your Route' : 'Nereye gideceksin?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (!_isExpanded) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Tap to plan route',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.expand_more,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(AsyncValue routeState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 16),
          
          _buildSimpleSearchField(
            controller: _originController,
            hint: 'From where?',
            icon: Icons.radio_button_checked,
            iconColor: Colors.green,
            isOrigin: true,
          ),
          
          const SizedBox(height: 8),
          
          Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                onPressed: _swapLocations,
                icon: Icon(
                  Icons.swap_vert,
                  size: 16,
                  color: Colors.grey[600],
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          _buildSimpleSearchField(
            controller: _destinationController,
            hint: 'Where to?',
            icon: Icons.location_on,
            iconColor: Colors.red,
            isOrigin: false,
          ),
          
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: routeState.isLoading || _isSearching ? null : _searchRoute,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: routeState.isLoading || _isSearching
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Find Route',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleSearchField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
    required bool isOrigin,
  }) {
    return InkWell(
      onTap: () => _openAddressSearch(isOrigin),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  controller.text.isEmpty ? hint : controller.text,
                  style: TextStyle(
                    color: controller.text.isEmpty ? Colors.grey[500] : Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _searchRoute() async {
    if (_originController.text.isEmpty || _destinationController.text.isEmpty) {
      _showSnackBar('Please enter start and end points');
      return;
    }

    setState(() => _isSearching = true);

    try {
      final origin = _originLocation ?? const Location(latitude: 39.9334, longitude: 32.8597);
      final destination = _destinationLocation ?? const Location(latitude: 39.9208, longitude: 32.8541);
      
      await ref.read(routeProvider.notifier).getRoute(
        origin: origin,
        destination: destination,
      );
      
    } catch (e) {
      _showSnackBar('Route not found: $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _swapLocations() {
    setState(() {
      final originText = _originController.text;
      _originController.text = _destinationController.text;
      _destinationController.text = originText;
      
      final originLocation = _originLocation;
      _originLocation = _destinationLocation;
      _destinationLocation = originLocation;
    });
    
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.swap_vert, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Start and destination points swapped'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _openAddressSearch(bool isOrigin) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddressSearchPage(
          title: isOrigin ? 'Nereden' : 'Nereye',
          hint: isOrigin ? 'Choose starting point' : 'Choose destination',
          isOrigin: isOrigin,
        ),
      ),
    );

    if (result != null) {
      final String address = result['address'];
      final Location location = result['location'];

      if (isOrigin) {
        _originController.text = address;
        _originLocation = location;
      } else {
        _destinationController.text = address;
        _destinationLocation = location;
      }

      setState(() {});
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}