import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../home/facility.dart';
import 'displaymap.dart';
import '../../services/location_service.dart';
import '../../services/api/home/homeapi.dart';
import '../../utils/encryption.dart';
import '../../components/main_layout.dart';

class MapPage extends StatefulWidget {
  final FacilityItem? initialFacility;

  const MapPage({super.key, this.initialFacility});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<FacilityItem> facilities = [];
  Position? _currentPosition;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _initializeFacilities();
  }

  void _initializeFacilities() async {
    if (widget.initialFacility != null) {
      setState(() {
        facilities = [widget.initialFacility!];
        _isLoading = false;
        _hasError = false;
      });
      _updateFacilityDistances();
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final facilitiesData = await HomeApi.getFacilities();
      
      // Create facilities list with proper callbacks and calculate distances
      final facilitiesList = facilitiesData.asMap().entries.map((entry) {
        final data = entry.value;
        
        // Parse coordinates safely
        double lat = 0.0;
        double lng = 0.0;
        try {
          final raw = data['location'];
          final locationData = raw is String ? json.decode(raw) : raw;
          if (locationData != null && locationData['coordinates'] != null) {
            lat = (locationData['coordinates'][1] as num).toDouble();
            lng = (locationData['coordinates'][0] as num).toDouble();
          }
        } catch (_) {}
        
        // Parse services from API response
        List<String> services = [];
        if (data['services'] is String) {
          try {
            services = (json.decode(data['services']) as List<dynamic>).cast<String>();
          } catch (_) {}
        } else if (data['services'] is List) {
          services = (data['services'] as List<dynamic>).cast<String>();
        }
        
        return FacilityItem(
          name: data['name'] as String,
          location: data['address'] as String? ?? 'Unknown Address',
          distance: 'Calculating...', // Will be updated after location is available
          phoneNumber: _formatEncryptedField(data['phone'] as String?),
          facilityType: data['type'] as String,
          profileImage: 'assets/images/logo.png',
          email: _formatEncryptedField(data['email'] as String?),
          services: services,
          openingHours: data['openingHours'] as String?,
          hospitalType: data['hospitalType'] as String?,
          pharmacyType: data['pharmacyType'] as String?,
          viewsTotal: data['viewsTotal'] != null ? int.tryParse(data['viewsTotal'].toString()) : 0,
          onTap: () {
            // Handle facility tap
          },
          // Store coordinates for distance calculation
          latitude: lat,
          longitude: lng,
        );
      }).toList();
      
      setState(() {
        facilities = facilitiesList;
        _isLoading = false;
        _hasError = false;
      });
      
      // Calculate distances after state is updated
      _updateFacilityDistances();
      
    } catch (e) {
      debugPrint('Error loading facilities from API: $e');
      setState(() {
        facilities = [];
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  String _formatEncryptedField(String? encryptedValue) {
    return EncryptionUtils.formatEncryptedField(encryptedValue);
  }

  void _updateFacilityDistances() {
    if (_currentPosition == null) return;
    
    setState(() {
      facilities = facilities.map((facility) {
        final distance = _calculateDistance(
          facility.latitude,
          facility.longitude,
        );
        return facility.copyWith(distance: distance);
      }).toList();
    });
    
    _sortFacilitiesByDistance();
  }

  void _getCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        setState(() {
          _currentPosition = position;
        });
        _updateFacilityDistances();
      } else {
        _useDefaultLocation();
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      _useDefaultLocation();
    }
  }

  void _useDefaultLocation() {
    // Use default location (New York City)
    setState(() {
      _currentPosition = Position(
        latitude: 40.7128,
        longitude: -74.0060,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    });
    _updateFacilityDistances();
  }

  String _calculateDistance(double facilityLat, double facilityLng) {
    if (_currentPosition == null) {
      return 'Calculating...';
    }
    
    final currentPos = _currentPosition!;
    const double earthRadius = 6371; // km
    
    final double dLat = _toRadians(facilityLat - currentPos.latitude);
    final double dLon = _toRadians(facilityLng - currentPos.longitude);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(currentPos.latitude)) * 
        math.cos(_toRadians(facilityLat)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.asin(math.sqrt(a));
    final double distance = earthRadius * c;
    
    return '${distance.toStringAsFixed(1)} km';
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  void _sortFacilitiesByDistance() {
    if (_currentPosition == null) return;
    
    final List<FacilityItem> sortedFacilities = List.from(facilities);
    
    sortedFacilities.sort((a, b) {
      final distanceA = double.tryParse(a.distance.replaceAll(' km', '').replaceAll('Calculating...', '999')) ?? 999;
      final distanceB = double.tryParse(b.distance.replaceAll(' km', '').replaceAll('Calculating...', '999')) ?? 999;
      return distanceA.compareTo(distanceB);
    });
    
    setState(() {
      facilities = sortedFacilities;
    });
  }

  void _retryLoadFacilities() {
    _initializeFacilities();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return MainLayout(
        title: 'Map',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load facilities'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _retryLoadFacilities,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return MainLayout(
      title: 'Map',
      child: DisplayMap(
        facilities: facilities,
        currentPosition: _currentPosition,
        initialTarget: widget.initialFacility,
        onSearch: (query) {
          debugPrint('Search: $query');
        },
      ),
    );
  }
}