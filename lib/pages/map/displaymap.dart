import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../home/facility.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
// Conditional TTS: full on mobile, stub on desktop/web
import '../../services/tts_service.dart'
    if (dart.library.io) '../../services/tts_service_mobile.dart';

class DisplayMap extends StatefulWidget {
  final List<FacilityItem> facilities;
  final String? searchQuery;
  final Function(String)? onSearch;
  final Position? currentPosition;
  final FacilityItem? initialTarget;

  const DisplayMap({
    super.key,
    required this.facilities,
    this.searchQuery,
    this.onSearch,
    this.currentPosition,
    this.initialTarget,
  });

  @override
  State<DisplayMap> createState() => _DisplayMapState();
}

class _DisplayMapState extends State<DisplayMap> {
  late MapController _mapController;
  final List<Marker> _markers = [];
  List<latlong.LatLng> _routePoints = [];
  
  bool _isNavigating = false;
  List<String> _navigationSteps = [];
  int _currentStepIndex = 0;
  final TtsService _tts = TtsService.instance;
  bool _isVoiceMuted = true; // Sound OFF by default

  // Live tracking
  StreamSubscription<Position>? _positionStream;
  Position? _livePosition;    // updated continuously while navigating
  static const double _stepThresholdMeters = 30.0; // auto-advance within 30 m

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _tts.init();
    _livePosition = widget.currentPosition;
    _updateMarkers();
    _fetchRoute();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(DisplayMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPosition != widget.currentPosition || 
        oldWidget.facilities != widget.facilities ||
        oldWidget.initialTarget != widget.initialTarget) {
      _updateMarkers();
      _fetchRoute();
    }
  }

  Future<void> _fetchRoute() async {
    if (widget.currentPosition == null || widget.initialTarget == null) return;
    
    final startLat = widget.currentPosition!.latitude;
    final startLng = widget.currentPosition!.longitude;
    final endLat = widget.initialTarget!.latitude;
    final endLng = widget.initialTarget!.longitude;
    
    final url = 'http://router.project-osrm.org/route/v1/driving/$startLng,$startLat;$endLng,$endLat?geometries=geojson&steps=true';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final geometry = data['routes'][0]['geometry'];
          final coordinates = geometry['coordinates'] as List<dynamic>;
          
          if (mounted) {
            setState(() {
              _routePoints = coordinates.map((coord) {
                return latlong.LatLng(coord[1] as double, coord[0] as double);
              }).toList();
              
              if (data['routes'][0]['legs'] != null && data['routes'][0]['legs'].isNotEmpty) {
                final steps = data['routes'][0]['legs'][0]['steps'] as List<dynamic>;
                _navigationSteps = steps.map((step) => _generateInstruction(step)).toList();
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
    }
  }

  String _generateInstruction(dynamic step) {
    final maneuver = step['maneuver'];
    final type = maneuver['type'] as String?;
    final modifier = maneuver['modifier'] as String?;
    final name = step['name'] as String?;
    
    String instruction = '';
    if (type == 'depart') {
      instruction = 'Head ${modifier?.replaceAll('-', ' ') ?? 'straight'}';
    } else if (type == 'arrive') {
      instruction = 'You have arrived at your destination.';
    } else {
      String action = type == 'turn' ? 'Turn' : 'Continue';
      if (modifier != null) {
        action += ' ${modifier.replaceAll('-', ' ')}';
      }
      instruction = action;
    }
    
    if (name != null && name.isNotEmpty) {
      instruction += ' onto $name.';
    } else {
      instruction += '.';
    }
    return instruction;
  }

  void _startNavigation() {
    if (_routePoints.isEmpty || _navigationSteps.isEmpty) return;
    setState(() {
      _isNavigating = true;
      _currentStepIndex = 0;
    });

    // Zoom into live position
    final pos = _livePosition ?? widget.currentPosition;
    if (pos != null) {
      _mapController.move(
        latlong.LatLng(pos.latitude, pos.longitude),
        17.0,
      );
    }

    _speakCurrentStep();
    _startLiveTracking();
  }

  void _startLiveTracking() {
    _positionStream?.cancel();
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // update every 5 metres
    );
    _positionStream = Geolocator.getPositionStream(locationSettings: settings)
        .listen((Position pos) {
      if (!mounted) return;
      setState(() {
        _livePosition = pos;
      });

      // Move map to follow user
      _mapController.move(
        latlong.LatLng(pos.latitude, pos.longitude),
        17.0,
      );

      // Auto-advance step when close enough to next route waypoint
      _checkAutoAdvanceStep(pos);
    });
  }

  void _stopLiveTracking() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  void _checkAutoAdvanceStep(Position pos) {
    if (!_isNavigating || _currentStepIndex >= _navigationSteps.length - 1) return;
    if (_routePoints.isEmpty) return;

    // Find the waypoint corresponding to the next step
    // Approximate: divide route points evenly among steps
    final segmentSize = _routePoints.length ~/ _navigationSteps.length;
    final nextWaypointIndex = math.min(
      (_currentStepIndex + 1) * segmentSize,
      _routePoints.length - 1,
    );
    final nextWaypoint = _routePoints[nextWaypointIndex];

    final distanceToNext = Geolocator.distanceBetween(
      pos.latitude, pos.longitude,
      nextWaypoint.latitude, nextWaypoint.longitude,
    );

    if (distanceToNext <= _stepThresholdMeters) {
      setState(() {
        _currentStepIndex++;
      });
      _speakCurrentStep();
    }
  }

  Future<void> _speakCurrentStep() async {
    if (_isVoiceMuted || _navigationSteps.isEmpty || _currentStepIndex >= _navigationSteps.length) return;
    await _tts.speak(_navigationSteps[_currentStepIndex]);
  }

  void _toggleVoice() {
    setState(() {
      _isVoiceMuted = !_isVoiceMuted;
    });
    if (!_isVoiceMuted) {
      // Turned ON — immediately speak the current step if navigating
      if (_isNavigating) {
        _speakCurrentStep();
      }
    } else {
      _tts.stop();
    }
  }

  Color _markerColor(String facilityType) {
    return facilityType.toLowerCase().contains('pharmacy')
        ? Colors.red.shade700
        : Colors.blue.shade700;
  }

  void _updateMarkers() {
    final pos = _livePosition ?? widget.currentPosition;
    setState(() {
      _markers.clear();
      
      if (pos != null) {
        _markers.add(
          Marker(
            point: latlong.LatLng(pos.latitude, pos.longitude),
            width: 44,
            height: 44,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 20),
            ),
          ),
        );
      }
      for (final facility in widget.facilities) {
        final color = _markerColor(facility.facilityType);
        final icon = facility.facilityType.toLowerCase().contains('pharmacy')
            ? Icons.local_pharmacy
            : Icons.local_hospital;
        _markers.add(
          Marker(
            point: latlong.LatLng(facility.latitude, facility.longitude),
            width: 44,
            height: 56,
            child: _MapPinMarker(
              color: color,
              icon: icon,
              onTap: () => _showFacilityDetails(facility),
            ),
          ),
        );
      }
    });
  }

  List<Marker> _buildRouteMarkers() {
    if (_routePoints.isEmpty) return _markers;
    return [
      Marker(
        point: _routePoints.first,
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.my_location, color: Colors.white, size: 16),
        ),
      ),
      Marker(
        point: _routePoints.last,
        width: 44,
        height: 56,
        child: _MapPinMarker(
          color: widget.initialTarget != null
              ? _markerColor(widget.initialTarget!.facilityType)
              : Colors.blue.shade700,
          icon: widget.initialTarget != null &&
                  widget.initialTarget!.facilityType.toLowerCase().contains('pharmacy')
              ? Icons.local_pharmacy
              : Icons.local_hospital,
          onTap: () {
            if (widget.initialTarget != null) {
              _showFacilityDetails(widget.initialTarget!);
            }
          },
        ),
      ),
    ];
  }

  void _showFacilityDetails(FacilityItem facility) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              facility.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(facility.location),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(facility.phoneNumber),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _zoomIn() {
    final zoom = _mapController.camera.zoom + 1;
    _mapController.move(_mapController.camera.center, zoom);
  }

  void _zoomOut() {
    final zoom = (_mapController.camera.zoom - 1).clamp(2.0, 18.0);
    _mapController.move(_mapController.camera.center, zoom);
  }

  void _toggleFullScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Map Fullscreen'),
            backgroundColor: Colors.blue,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _mapController.camera.center,
                  initialZoom: _mapController.camera.zoom,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.find_med.app',
                  ),
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          if (widget.currentPosition != null)
                            Polyline(
                              points: [
                                latlong.LatLng(widget.currentPosition!.latitude, widget.currentPosition!.longitude),
                                _routePoints.first,
                              ],
                              strokeWidth: 3.0,
                              color: Colors.grey,
                              isDotted: true,
                            ),
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 4.0,
                            color: Colors.blueAccent,
                          ),
                          if (widget.initialTarget != null)
                            Polyline(
                              points: [
                                _routePoints.last,
                                latlong.LatLng(widget.initialTarget!.latitude, widget.initialTarget!.longitude),
                              ],
                              strokeWidth: 3.0,
                              color: Colors.grey,
                              isDotted: true,
                            ),
                        ],
                      ),
                  MarkerLayer(
                    markers: _routePoints.isNotEmpty ? _buildRouteMarkers() : _markers,
                  ),
                ],
              ),
              Positioned(
                right: 16,
                top: 16,
                child: Column(
                  children: [
                    FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.blue,
                      onPressed: _zoomIn,
                      child: const Icon(Icons.zoom_in),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.blue,
                      onPressed: _zoomOut,
                      child: const Icon(Icons.zoom_out),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.red,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.fullscreen_exit),
                    ),
                  ],
                ),
              ),
              if (_routePoints.isNotEmpty)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      FloatingActionButton(
                        heroTag: "voiceBtn",
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        onPressed: _toggleVoice,
                        child: Icon(_isVoiceMuted ? Icons.volume_off : Icons.volume_up),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isNavigating ? () {
                            setState(() {
                              if (_currentStepIndex < _navigationSteps.length - 1) {
                                _currentStepIndex++;
                                _speakCurrentStep();
                              } else {
                                _isNavigating = false;
                                _stopLiveTracking();
                              }
                            });
                          } : _startNavigation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            _isNavigating ? 'Next Step' : 'Start',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_isNavigating && _navigationSteps.isNotEmpty && _currentStepIndex < _navigationSteps.length)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 80,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade800,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ]
                    ),
                    child: Text(
                      _navigationSteps[_currentStepIndex],
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    latlong.LatLng initialPosition;
    
    if (widget.initialTarget != null) {
      initialPosition = latlong.LatLng(
        widget.initialTarget!.latitude,
        widget.initialTarget!.longitude,
      );
    } else if (widget.currentPosition != null) {
      final currentPos = widget.currentPosition!;
      initialPosition = latlong.LatLng(
        currentPos.latitude,
        currentPos.longitude,
      );
    } else {
      if (widget.facilities.isNotEmpty) {
        initialPosition = latlong.LatLng(
          widget.facilities[0].latitude,
          widget.facilities[0].longitude,
        );
      } else {
        initialPosition = const latlong.LatLng(9.0, 40.0);
      }
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: initialPosition,
                    initialZoom: 12.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.find_med.app',
                    ),
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          if (widget.currentPosition != null)
                            Polyline(
                              points: [
                                latlong.LatLng(widget.currentPosition!.latitude, widget.currentPosition!.longitude),
                                _routePoints.first,
                              ],
                              strokeWidth: 3.0,
                              color: Colors.grey,
                              isDotted: true,
                            ),
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 4.0,
                            color: Colors.blueAccent,
                          ),
                          if (widget.initialTarget != null)
                            Polyline(
                              points: [
                                _routePoints.last,
                                latlong.LatLng(widget.initialTarget!.latitude, widget.initialTarget!.longitude),
                              ],
                              strokeWidth: 3.0,
                              color: Colors.grey,
                              isDotted: true,
                            ),
                        ],
                      ),
                    MarkerLayer(
                      markers: _routePoints.isNotEmpty ? _buildRouteMarkers() : _markers,
                    ),
                  ],
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.blue,
                        onPressed: _zoomIn,
                        child: const Icon(Icons.zoom_in),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.blue,
                        onPressed: _zoomOut,
                        child: const Icon(Icons.zoom_out),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.blue,
                        onPressed: () async {
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          try {
                            Position position = await Geolocator.getCurrentPosition();
                            _mapController.move(
                              latlong.LatLng(position.latitude, position.longitude),
                              14.0,
                            );
                          } catch (e) {
                            if (mounted) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        child: const Icon(Icons.my_location),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.blue,
                        onPressed: _toggleFullScreen,
                        child: const Icon(Icons.fullscreen),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Use zoom buttons',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                if (_routePoints.isNotEmpty)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 80, // Keep right padding to not overlap with zoom text box
                    child: Row(
                      children: [
                        FloatingActionButton(
                          heroTag: "voiceBtn",
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                          onPressed: _toggleVoice,
                          child: Icon(_isVoiceMuted ? Icons.volume_off : Icons.volume_up),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isNavigating ? () {
                              setState(() {
                                if (_currentStepIndex < _navigationSteps.length - 1) {
                                  _currentStepIndex++;
                                  _speakCurrentStep();
                                } else {
                                  _isNavigating = false;
                                }
                              });
                            } : _startNavigation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              _isNavigating ? 'Next Step' : 'Start',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_isNavigating && _navigationSteps.isNotEmpty && _currentStepIndex < _navigationSteps.length)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 80,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade800,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ]
                      ),
                      child: Text(
                        _navigationSteps[_currentStepIndex],
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                widget.onSearch?.call(value);
              },
              decoration: InputDecoration(
                hintText: 'Search facilities...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          SizedBox(
            height: 400, // or MediaQuery.of(context).size.height * 0.5
            child: widget.facilities.isEmpty
                ? const Center(child: Text('No facilities found'))
                : ListView.builder(
                    itemCount: widget.facilities.length,
                    itemBuilder: (context, index) {
                      final facility = widget.facilities[index];
                      return GestureDetector(
                        onTap: () {
                          _showFacilityDetails(facility);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    facility.facilityType == 'hospital'
                                        ? Icons.local_hospital
                                        : Icons.medical_services,
                                    color: Colors.blue,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        facility.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              facility.location,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            facility.distance,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
}

/// A teardrop-shaped map pin marker widget.
class _MapPinMarker extends StatelessWidget {
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _MapPinMarker({
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 56,
        child: CustomPaint(
          painter: _MapPinPainter(color: color),
          child: Align(
            alignment: const Alignment(0, -0.35),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

/// Paints a teardrop/location-pin shape.
class _MapPinPainter extends CustomPainter {
  final Color color;
  const _MapPinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final w = size.width;
    final h = size.height;
    final r = w / 2; // radius of the circle top
    // The circle center sits at (w/2, r)
    final cx = w / 2;
    final cy = r;

    // Build teardrop path: circle on top + point at bottom
    final path = Path();
    // Start at the bottom tip
    path.moveTo(cx, h);
    // Left side curve up to the circle
    path.quadraticBezierTo(cx - r * 0.15, h * 0.65, cx - r, cy);
    // Arc across the top (circle portion)
    path.arcToPoint(
      Offset(cx + r, cy),
      radius: Radius.circular(r),
      clockwise: false,
    );
    // Right side curve down to tip
    path.quadraticBezierTo(cx + r * 0.15, h * 0.65, cx, h);
    path.close();

    // Draw shadow slightly offset
    canvas.save();
    canvas.translate(0, 2);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Draw the pin
    canvas.drawPath(path, paint);

    // White inner circle highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r * 0.7, highlightPaint);

    // White border ring
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final borderPath = Path();
    borderPath.moveTo(cx, h);
    borderPath.quadraticBezierTo(cx - r * 0.15, h * 0.65, cx - r, cy);
    borderPath.arcToPoint(
      Offset(cx + r, cy),
      radius: Radius.circular(r),
      clockwise: false,
    );
    borderPath.quadraticBezierTo(cx + r * 0.15, h * 0.65, cx, h);
    borderPath.close();
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(_MapPinPainter old) => old.color != color;
}