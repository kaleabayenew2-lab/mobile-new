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
  const MapPage({super.key});

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

  void _initializeFacilities() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    try {
      final facilitiesData = await HomeApi.getFacilities();
      
      // Create facilities list with proper callbacks and calculate distances
      final facilitiesList = facilitiesData.asMap().entries.map((entry) {
        final data = entry.value;
        
        // Parse coordinates from API response
        final locationData = data['location'] is String 
            ? json.decode(data['location']) 
            : data['location'];
        final coordinates = locationData['coordinates'] as List<dynamic>;
        
        // Parse services from API response
        List<String> services = [];
        if (data['services'] is String) {
          services = (json.decode(data['services']) as List<dynamic>)
              .cast<String>();
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
          onTap: () {
            // Handle facility tap
          },
          // Store coordinates for distance calculation
          latitude: coordinates[1] as double,
          longitude: coordinates[0] as double,
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

  void _getCurrentLocation() {
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
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
        onSearch: (query) {
          debugPrint('Search: $query');
        },
      ),
    );
  }
}
