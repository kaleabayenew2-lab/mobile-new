import 'package:flutter/material.dart';
import '../../components/main_layout.dart';
import 'mini_header.dart';
import 'promotion.dart';
import 'facility.dart';
import 'detailfacility.dart';
import '../../services/location_service.dart';
import '../../services/api/home/homeapi.dart';
import '../../utils/encryption.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final facilitiesData = await HomeApi.getFacilities();
      
      // Create facilities list with proper callbacks and calculate distances
      final facilitiesList = facilitiesData.asMap().entries.where((entry) {
        final data = entry.value;
        // Parse coordinates from API response
        final locationData = data['location'] is String 
            ? json.decode(data['location']) 
            : data['location'];
        final coordinates = locationData['coordinates'] as List<dynamic>?;
        
        // Filter out facilities without valid coordinates
        return coordinates != null && coordinates.length >= 2 && 
               coordinates[0] != null && coordinates[1] != null;
      }).map((entry) {
        final index = entry.key;
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
            showFacilityDetail(context, facilities[index]);
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
      // Error loading facilities from API
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

  void _retryLoadFacilities() {
    _initializeFacilities();
  }

  
  void _getCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        setState(() {
          _currentPosition = position;
        });
        // Update distances when location is obtained
        _updateFacilityDistances();
      } else {
        // Position is null, use default location
        _useDefaultLocation();
      }
    } catch (e) {
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
    // Update distances with default location
    _updateFacilityDistances();
  }

  String _calculateDistance(double facilityLat, double facilityLng) {
    if (_currentPosition == null) {
      return 'N/A';
    }
    
    try {
      const double earthRadius = 6371; // km
      
      final double dLat = _toRadians(facilityLat - _currentPosition!.latitude);
      final double dLon = _toRadians(facilityLng - _currentPosition!.longitude);
      
      final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
          math.cos(_toRadians(_currentPosition!.latitude)) * math.cos(_toRadians(facilityLat)) *
          math.sin(dLon / 2) * math.sin(dLon / 2);
      
      final double c = 2 * math.asin(math.sqrt(a));
      final double distance = earthRadius * c;
      
      return '${distance.toStringAsFixed(1)} km';
    } catch (e) {
      return 'N/A';
    }
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  void _sortFacilitiesByDistance() {
    if (_currentPosition == null) return;
    
    List<FacilityItem> sortedFacilities = List.from(facilities);
    
    sortedFacilities.sort((a, b) {
      // Extract distance values and compare
      final distanceA = double.tryParse(a.distance.replaceAll(' km', '').replaceAll('Calculating...', '999')) ?? 999;
      final distanceB = double.tryParse(b.distance.replaceAll(' km', '').replaceAll('Calculating...', '999')) ?? 999;
      return distanceA.compareTo(distanceB);
    });
    
    setState(() {
      facilities = sortedFacilities;
    });
  }

  @override
  Widget build(BuildContext context) {

    final promotionSlides = [
      PromotionSlide(
        imageUrl: 'assets/images/logo.png',
        title: 'Find Best Doctors',
        subtitle: 'Connect with top medical professionals in your area',
        buttonText: 'Search Now',
        onButtonTap: () {
          // Search doctors functionality
        },
      ),
      PromotionSlide(
        imageUrl: 'assets/images/logo.png',
        title: '24/7 Emergency Care',
        subtitle: 'Get immediate medical assistance whenever you need it',
        buttonText: 'Learn More',
        onButtonTap: () {
          // Emergency care functionality
        },
      ),
      PromotionSlide(
        imageUrl: 'assets/images/logo.png',
        title: 'Book Appointments',
        subtitle: 'Schedule your medical visits with just a few taps',
        buttonText: 'Book Now',
        onButtonTap: () {
          // Book appointment functionality
        },
      ),
    ];

    return MainLayout(
      title: 'Home',
      child: Column(
        children: [
          MiniHeader(
            onSearch: (query) {
              // Handle search functionality
            },
            onFilter: () {
              // Handle filter functionality
            },
            onLocation: () {
              // Handle location functionality
            },
            currentLocation: _currentPosition != null 
                ? 'Current Location'
                : 'Location Unavailable',
          ),
          const SizedBox(height: 16),
          Promotion(
            slides: promotionSlides,
            height: 180,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
          ),
          const SizedBox(height: 20),
          Facility(
            facilities: facilities,
            maxItems: 5,
            isLoading: _isLoading,
            hasError: _hasError,
            onRetry: _retryLoadFacilities,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
