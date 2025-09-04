import 'package:flutter/material.dart';
import '../../domain/entities/route.dart';
import '../../domain/entities/route_step.dart';

class RouteStepsPanel extends StatefulWidget {
  final List<RouteEntity> routes;
  final int selectedRouteIndex;
  final Function(int) onRouteSelected;

  const RouteStepsPanel({
    super.key,
    required this.routes,
    this.selectedRouteIndex = 0,
    required this.onRouteSelected,
  });

  @override
  State<RouteStepsPanel> createState() => _RouteStepsPanelState();
}

class _RouteStepsPanelState extends State<RouteStepsPanel> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  bool _isExpanded = false;
  double _initialHeight = 120;
  double _expandedHeight = 400;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightAnimation = Tween<double>(
      begin: _initialHeight,
      end: _expandedHeight,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedRoute = widget.routes[widget.selectedRouteIndex];
    
    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        return Container(
          height: _heightAnimation.value,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: _toggleExpansion,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.directions_transit,
                              color: Colors.blue[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Route Options (${widget.routes.length})',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${selectedRoute.duration} • ${selectedRoute.distance}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            Icon(
                              _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isExpanded) ...[
                const Divider(height: 1),
                _buildRouteOptions(),
                const Divider(height: 1),
              ],
              Expanded(
                child: _buildRouteSteps(selectedRoute),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRouteOptions() {
    return Container(
      height: 140,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: widget.routes.length,
        itemBuilder: (context, index) {
          final route = widget.routes[index];
          final isSelected = index == widget.selectedRouteIndex;
          final transitLines = _getTransitLines(route);
          
          return GestureDetector(
            onTap: () => widget.onRouteSelected(index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[50] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[400],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Route ${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.blue[700] : Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${route.duration} • ${route.distance}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (transitLines.isNotEmpty) ...[
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: transitLines.map((line) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue[100] : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  line,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected ? Colors.blue[800] : Colors.grey[700],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ] else ...[
                          Text(
                            _getRouteSummary(route),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Colors.blue,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> _getTransitLines(RouteEntity route) {
    final lines = <String>[];
    final seenLines = <String>{};
    
    for (final step in route.steps) {
      if (step.travelMode == TravelMode.transit && step.busNumber != null) {
        final line = step.busNumber!;
        if (!seenLines.contains(line)) {
          lines.add(line);
          seenLines.add(line);
        }
      }
    }
    
    return lines;
  }

  String _getRouteSummary(RouteEntity route) {
    final modes = <TravelMode>{};
    for (final step in route.steps) {
      modes.add(step.travelMode);
    }
    
    final modeTexts = modes.map((mode) {
      switch (mode) {
        case TravelMode.walking:
          return 'Walk';
        case TravelMode.transit:
          return 'Transit';
        case TravelMode.driving:
          return 'Drive';
      }
    }).toList();
    
    return modeTexts.join(' + ');
  }

  Widget _buildRouteSteps(RouteEntity route) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: route.steps.length,
      itemBuilder: (context, index) {
        final step = route.steps[index];
        return _buildStepItem(step);
      },
    );
  }

  Widget _buildStepItem(RouteStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getStepColor(step.travelMode),
              borderRadius: BorderRadius.circular(18),
            ),
            child: step.travelMode == TravelMode.transit && step.busNumber != null
                ? Center(
                    child: Text(
                      step.busNumber!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Icon(
                    _getStepIcon(step.travelMode),
                    color: Colors.white,
                    size: 18,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.instruction,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (step.travelMode == TravelMode.transit) ...[
                  if (step.transitDetails != null)
                    Text(
                      step.transitDetails!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (step.departureStop != null && step.arrivalStop != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          Icon(
                            Icons.radio_button_checked,
                            size: 12,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              step.departureStop!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (step.departureStop != null && step.arrivalStop != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          Icon(
                            Icons.radio_button_checked,
                            size: 12,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              step.arrivalStop!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${step.duration} • ${step.distance}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStepIcon(TravelMode mode) {
    switch (mode) {
      case TravelMode.walking:
        return Icons.directions_walk;
      case TravelMode.transit:
        return Icons.directions_bus;
      case TravelMode.driving:
        return Icons.directions_car;
    }
  }

  Color _getStepColor(TravelMode mode) {
    switch (mode) {
      case TravelMode.walking:
        return Colors.green;
      case TravelMode.transit:
        return Colors.blue;
      case TravelMode.driving:
        return Colors.orange;
    }
  }
}