import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../home/facility.dart';
import 'package:geolocator/geolocator.dart';

class DisplayMap extends StatefulWidget {
  final List<FacilityItem> facilities;
  final String? searchQuery;
  final Function(String)? onSearch;
  final Position? currentPosition;

  const DisplayMap({
    super.key,
    required this.facilities,
    this.searchQuery,
    this.onSearch,
    this.currentPosition,
  });

  @override
  State<DisplayMap> createState() => _DisplayMapState();
}

class _DisplayMapState extends State<DisplayMap> {
  late MapController _mapController;
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _updateMarkers();
  }

  @override
  void didUpdateWidget(DisplayMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPosition != widget.currentPosition || 
        oldWidget.facilities != widget.facilities) {
      _updateMarkers();
    }
  }

  void _updateMarkers() {
    setState(() {
      _markers.clear();
      
      if (widget.currentPosition != null) {
        final currentPos = widget.currentPosition!;
        _markers.add(
          Marker(
            point: latlong.LatLng(
              currentPos.latitude,
              currentPos.longitude,
            ),
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
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        );
      }
      
      for (final facility in widget.facilities) {
        _markers.add(
          Marker(
            point: latlong.LatLng(facility.latitude, facility.longitude),
            width: 80,
            height: 80,
            child: GestureDetector(
              onTap: () {
                _showFacilityDetails(facility);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        );
      }
    });
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
                  MarkerLayer(
                    markers: _markers,
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    latlong.LatLng initialPosition;
    
    if (widget.currentPosition != null) {
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
                    MarkerLayer(
                      markers: _markers,
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
          Expanded(
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