import 'package:flutter/material.dart';
import '../../domain/entities/route.dart';
import '../../domain/entities/route_step.dart';

class RouteBottomSheet extends StatefulWidget {
  final List<RouteEntity> routes;
  final int selectedRouteIndex;
  final Function(int) onRouteSelected;

  const RouteBottomSheet({
    super.key,
    required this.routes,
    this.selectedRouteIndex = 0,
    required this.onRouteSelected,
  });

  @override
  State<RouteBottomSheet> createState() => _RouteBottomSheetState();
}

class _RouteBottomSheetState extends State<RouteBottomSheet> {
  late int _selectedRouteIndex;

  @override
  void initState() {
    super.initState();
    _selectedRouteIndex = widget.selectedRouteIndex;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
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
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: _buildHeader(),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: _buildRouteOptions(),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildRouteSteps(widget.routes[_selectedRouteIndex]),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final selectedRoute = widget.routes[_selectedRouteIndex];
    return Row(
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
      ],
    );
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

  Widget _buildRouteOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        const SizedBox(height: 12),
        SizedBox(
          height: 170,
          child: ListView.builder(
            itemCount: widget.routes.length,
            itemBuilder: (context, index) {
              final route = widget.routes[index];
              final isSelected = index == _selectedRouteIndex;
              final transitLines = _getTransitLines(route);
              final routeType = _getRouteType(route, index);
              
              return GestureDetector(
            onTap: () {
              setState(() {
                _selectedRouteIndex = index;
              });
              widget.onRouteSelected(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[50] : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.blue[300]! : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[600] : Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              routeType['title'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: isSelected ? Colors.blue[700] : Colors.grey[800],
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time, size: 12, color: Colors.green[600]),
                                const SizedBox(width: 4),
                                Text(
                                  route.duration,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.straighten, size: 11, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              route.distance,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        if (transitLines.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.directions_bus, size: 12, color: Colors.blue[600]),
                              const SizedBox(width: 6),
                              ...transitLines.take(3).map((line) => 
                                Container(
                                  margin: const EdgeInsets.only(right: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[600],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    line,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ).toList(),
                              if (transitLines.length > 3)
                                Text(
                                  '+${transitLines.length - 3}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                ],
              ),
            ),
          );
            },
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getRouteType(RouteEntity route, int index) {
    final lines = _getTransitLines(route);
    
    switch (index) {
      case 0:
        return {'title': 'Fastest', 'icon': Icons.speed};
      case 1:
        return lines.length <= 1 
          ? {'title': 'Less Transfer', 'icon': Icons.timeline}
          : {'title': 'Alternative', 'icon': Icons.alt_route};
      default:
        return {'title': 'Alternative', 'icon': Icons.alt_route};
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

  String _getArrivalTime(String duration) {
    try {
      final now = DateTime.now();
      int totalMinutes = 0;
      
      if (duration.contains('sa')) {
        final hourMatch = RegExp(r'(\d+)\s*sa').firstMatch(duration);
        if (hourMatch != null) {
          totalMinutes += int.parse(hourMatch.group(1)!) * 60;
        }
      }
      
      final minuteMatch = RegExp(r'(\d+)\s*dk').firstMatch(duration);
      if (minuteMatch != null) {
        totalMinutes += int.parse(minuteMatch.group(1)!);
      }
      
      final arrivalTime = now.add(Duration(minutes: totalMinutes));
      return '${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  Widget _buildRouteSteps(RouteEntity route) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list, size: 18, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              'Route Steps',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...route.steps.map((step) => _buildStepItem(step)).toList(),
      ],
    );
  }

  Widget _buildStepItem(RouteStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                  if (step.departureStop != null && step.arrivalStop != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
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