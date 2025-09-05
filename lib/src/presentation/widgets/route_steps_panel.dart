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
  double _initialHeight = 200;
  double _expandedHeight = 600;

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

  double _dragStartY = 0;
  
  void _handleDragStart(DragStartDetails details) {
    _dragStartY = details.globalPosition.dy;
  }
  
  void _handleDragUpdate(DragUpdateDetails details) {
  }
  
  void _handleDragEnd(DragEndDetails details) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dragDistance = _dragStartY - details.globalPosition.dy;
    final dragThreshold = 50.0;
    
    if (dragDistance > dragThreshold && !_isExpanded) {
      _toggleExpansion();
    } else if (dragDistance < -dragThreshold && _isExpanded) {
      _toggleExpansion();
    }
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
                onPanStart: _handleDragStart,
                onPanUpdate: _handleDragUpdate,
                onPanEnd: _handleDragEnd,
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
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.route,
                                    color: Colors.blue[600],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Best Route',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      Text(
                                        '${widget.routes.length} alternatif bulundu',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildRouteMetrics(selectedRoute),
                                const SizedBox(width: 8),
                                AnimatedRotation(
                                  turns: _isExpanded ? 0.5 : 0.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      Icons.expand_more,
                                      color: Colors.grey[600],
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (!_isExpanded) ...[
                              const SizedBox(height: 8),
                              _buildSelectedRoutePreview(selectedRoute),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isExpanded) ...[
                const Divider(height: 1),
                Expanded(
                  flex: 2,
                  child: _buildRouteOptions(),
                ),
                const Divider(height: 1),
              ],
              Expanded(
                flex: 3,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.compare_arrows, size: 18, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  'Route Alternatives',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                Text(
                  'Choose the best one',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.routes.length,
              itemBuilder: (context, index) {
                final route = widget.routes[index];
                final isSelected = index == widget.selectedRouteIndex;
                final transitLines = _getTransitLines(route);
                final routeType = _getRouteType(route, index);
                
                return GestureDetector(
                  onTap: () => widget.onRouteSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[50] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.blue[300]! : Colors.grey[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ] : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isSelected 
                                ? [Colors.blue[400]!, Colors.blue[600]!]
                                : [Colors.grey[300]!, Colors.grey[500]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                routeType['icon'],
                                color: Colors.white,
                                size: 18,
                              ),
                              Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    routeType['title'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isSelected ? Colors.blue[700] : Colors.grey[800],
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.access_time, size: 12, color: Colors.green[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          route.duration,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.straighten, size: 12, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Text(
                                    route.distance,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (transitLines.isNotEmpty) ...[
                                    Icon(Icons.directions_bus, size: 12, color: Colors.orange[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${transitLines.length} lines',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (transitLines.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: transitLines.take(3).map((line) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.blue[100] : Colors.orange[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected ? Colors.blue[200]! : Colors.orange[200]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        line,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.blue[700] : Colors.orange[700],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getRouteType(RouteEntity route, int index) {
    final transitLines = _getTransitLines(route);
    
    if (index == 0) {
      return {
        'title': 'Fastest',
        'icon': Icons.speed,
      };
    } else if (transitLines.length <= 1) {
      return {
        'title': 'Less Transfer',
        'icon': Icons.timeline,
      };
    } else {
      return {
        'title': 'Alternative',
        'icon': Icons.alt_route,
      };
    }
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

  Widget _buildRouteMetrics(RouteEntity route) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, size: 14, color: Colors.green[600]),
            const SizedBox(width: 4),
            Text(
              route.duration,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.green[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.straighten, size: 12, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              route.distance,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectedRoutePreview(RouteEntity route) {
    final transitLines = _getTransitLines(route);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[25],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Selected Route Summary',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.blue[700],
                ),
              ),
              const Spacer(),
              Text(
                'Tap to see alternatives',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          if (transitLines.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.directions_bus, size: 14, color: Colors.orange[600]),
                const SizedBox(width: 6),
                Text(
                  'Hatlar: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    children: transitLines.take(4).map((line) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange[200]!, width: 1),
                        ),
                        child: Text(
                          line,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (transitLines.length > 4)
                  Text(
                    '+${transitLines.length - 4}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
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