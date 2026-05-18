import 'package:flutter/material.dart';
import '../../components/main_layout.dart';
import 'mini_header.dart';
import 'promotion.dart';
import 'facility.dart';
import 'detailfacility.dart';
import '../emergency/emergency.dart';
import '../booking/booking.dart';
import '../history/history.dart';
import '../favorites/favorites.dart';
import '../profile/profile.dart';
import '../setting/setting.dart';
import '../agent/agent.dart';
import '../about/about.dart';
import '../privacy/privacy.dart';
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
  List<FacilityItem> displayFacilities = [];
  Position? _currentPosition;
  bool _isLoading = false;
  bool _hasError = false;
  String _searchQuery = '';
  String _filterString = '';

  List<PromotionSlide> promotionSlides = [];
  bool _isLoadingPromotions = false;

  @override
  void initState() {
    super.initState();
    displayFacilities = []; // Initialize display facilities
    _getCurrentLocation();
    _initializeFacilities();
    _loadPromotions();
  }

  Future<void> _loadPromotions() async {
    if (!mounted) return;
    setState(() {
      _isLoadingPromotions = true;
    });
    try {
      final data = await HomeApi.getPromotions();
      final List<PromotionSlide> loadedSlides = [];
      for (final item in data) {
        loadedSlides.add(PromotionSlide(
          imageUrl: item['imageUrl'] ?? 'assets/images/logo.png',
          title: item['title'] ?? 'Promotion',
          subtitle: item['subtitle'] ?? '',
          buttonText: item['buttonText'] ?? 'Learn More',
          onButtonTap: () {
            if (item['linkUrl'] != null && item['linkUrl'].toString().isNotEmpty && mounted) {
              final link = item['linkUrl'].toString().trim();
              Widget? targetPage;
              if (link == '/emergency') {
                targetPage = const EmergencyPage();
              } else if (link == '/booking') {
                targetPage = const BookingPage();
              } else if (link == '/history') {
                targetPage = const HistoryPage();
              } else if (link == '/favorites') {
                targetPage = const FavoritesPage();
              } else if (link == '/profile') {
                targetPage = const ProfilePage();
              } else if (link == '/setting') {
                targetPage = const SettingPage();
              } else if (link == '/agent') {
                targetPage = const AgentPage();
              } else if (link == '/about') {
                targetPage = const AboutPage();
              } else if (link == '/privacy') {
                targetPage = const PrivacyPage();
              }
              
              if (targetPage != null) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => targetPage!),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Promo: ${item['title']}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          },
        ));
      }
      if (mounted) {
        setState(() {
          promotionSlides = loadedSlides;
          _isLoadingPromotions = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching promotions: $e. Retrying in 10 seconds...');
      if (mounted) {
        // Schedule auto retry every 10 seconds on failure
        Future.delayed(const Duration(seconds: 10), () {
          if (mounted) {
            _loadPromotions();
          }
        });
      }
    }
  }

  Future<void> _initializeFacilities() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final facilitiesData = await HomeApi.getFacilities();
      
      final facilitiesList = <FacilityItem>[];

      for (int index = 0; index < facilitiesData.length; index++) {
        final data = facilitiesData[index];

        // Safely parse coordinates — don't skip if missing
        double lat = 0.0;
        double lng = 0.0;
        try {
          final raw = data['location'];
          final locationData = raw is String ? json.decode(raw) : raw;
          if (locationData != null && locationData['coordinates'] is List) {
            final coords = locationData['coordinates'] as List<dynamic>;
            if (coords.length >= 2) {
              lng = (coords[0] as num).toDouble();
              lat = (coords[1] as num).toDouble();
            }
          }
        } catch (_) {}

        // Safely parse services
        List<String> services = [];
        try {
          if (data['services'] is String && (data['services'] as String).isNotEmpty) {
            final decoded = json.decode(data['services']);
            if (decoded is List) services = decoded.cast<String>();
          } else if (data['services'] is List) {
            services = (data['services'] as List<dynamic>).cast<String>();
          }
        } catch (_) {}

        // Safely parse strings
        final name = (data['name'] ?? 'Unknown').toString();
        final address = (data['address'] ?? 'Unknown Address').toString();
        final type = (data['type'] ?? 'facility').toString();
        final phone = _formatEncryptedField(data['phone']?.toString());
        final email = _formatEncryptedField(data['email']?.toString());
        final profileImage = (data['profileImage'] != null && data['profileImage'].toString().isNotEmpty)
            ? data['profileImage'].toString()
            : null;
        
        // Parse gallery images
        List<String> galleryImages = [];
        try {
          if (data['galleryImages'] is String && (data['galleryImages'] as String).isNotEmpty) {
            final decoded = json.decode(data['galleryImages']);
            if (decoded is List) {
              galleryImages = decoded.cast<String>();
            } else if ((data['galleryImages'] as String).contains(',')) {
              galleryImages = (data['galleryImages'] as String)
                  .split(',')
                  .map((image) => image.trim())
                  .where((image) => image.isNotEmpty)
                  .toList();
            }
          } else if (data['galleryImages'] is List && (data['galleryImages'] as List).isNotEmpty) {
            galleryImages = (data['galleryImages'] as List).cast<String>();
          }
        } catch (_) {}

        facilitiesList.add(FacilityItem(
          id: data['id'] != null ? int.tryParse(data['id'].toString()) : null,
          isFavorite: false,
          name: name,
          location: address,
          distance: 'Calculating...',
          phoneNumber: phone,
          facilityType: type,
          profileImage: profileImage,
          email: email,
          services: services,
          openingHours: data['openingHours']?.toString(),
          hospitalType: data['hospitalType']?.toString(),
          pharmacyType: data['pharmacyType']?.toString(),
          galleryImages: galleryImages.isNotEmpty ? galleryImages : null,
          latitude: lat,
          longitude: lng,
          viewsTotal: data['viewsTotal'] != null ? int.tryParse(data['viewsTotal'].toString()) : 0,
          onTap: () {
            showFacilityDetail(context, facilitiesList[index]);
          },
        ));
      }
      
      setState(() {
        facilities = facilitiesList;
        displayFacilities = List.from(facilitiesList);
        _isLoading = false;
        _hasError = false;
      });
      
      // Calculate distances after state is updated
      _updateFacilityDistances();
      
    } catch (e) {
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
    
    // Initialize displayFacilities with all facilities for search
    displayFacilities = List.from(facilities);
  }

  Future<void> _retryLoadFacilities() async {
    await _initializeFacilities();
  }

  void _searchFacilities(String query) {

    setState(() {
      _searchQuery = query.toLowerCase().trim();
    });
    
    _updateDisplayFacilities();
  }

  void _updateDisplayFacilities() {
    setState(() {
      // Start with all facilities
      List<FacilityItem> result = List.from(facilities);
      
      // Apply search filter first
      if (_searchQuery.isNotEmpty) {
        result = result.where((facility) {
          final facilityName = facility.name.toLowerCase();
          final nameMatch = facilityName.contains(_searchQuery) || 
                           facilityName.startsWith(_searchQuery);
          final phoneMatch = facility.phoneNumber.toLowerCase().contains(_searchQuery);
          final locationMatch = facility.location.toLowerCase().contains(_searchQuery);
          final typeMatch = facility.facilityType.toLowerCase().contains(_searchQuery);
          final hospitalTypeMatch = facility.hospitalType?.toLowerCase().contains(_searchQuery) ?? false;
          final pharmacyTypeMatch = facility.pharmacyType?.toLowerCase().contains(_searchQuery) ?? false;
          final servicesMatch = facility.services?.any((service) => 
            service.toLowerCase().contains(_searchQuery)) ?? false;
          
          return nameMatch || phoneMatch || locationMatch || typeMatch || 
                 hospitalTypeMatch || pharmacyTypeMatch || servicesMatch;
        }).toList();
      }
      
      // Then apply filters
      if (_filterString.isNotEmpty && _filterString != 'Distance: All, Status: All, Emergency: All, Service: All, FacilityType: All, HospitalType: All, PharmacyType: All') {
        final filters = _filterString.split(', ');
        String distanceFilter = 'All';
        String statusFilter = 'All';
        String emergencyFilter = 'All';
        String serviceFilter = 'All';
        String facilityTypeFilter = 'All';
        String hospitalTypeFilter = 'All';
        String pharmacyTypeFilter = 'All';

        for (final filter in filters) {
          final parts = filter.split(': ');
          if (parts.length == 2) {
            final key = parts[0].trim();
            final value = parts[1].trim();
            
            if (key == 'Distance') {
              distanceFilter = value;
            } else if (key == 'Status') {
              statusFilter = value;
            } else if (key == 'Emergency') {
              emergencyFilter = value;
            } else if (key == 'Service') {
              serviceFilter = value;
            } else if (key == 'FacilityType') {
              facilityTypeFilter = value;
            } else if (key == 'HospitalType') {
              hospitalTypeFilter = value;
            } else if (key == 'PharmacyType') {
              pharmacyTypeFilter = value;
            }
          }
        }

        result = result.where((facility) {
          // Distance filter
          bool distanceMatch = distanceFilter == 'All';
          if (distanceFilter != 'All' && facility.distance != 'N/A') {
            try {
              double distance = double.parse(facility.distance.replaceAll(RegExp(r'[^0-9.]'), ''));
              if (facility.distance.endsWith(' m')) {
                distance = distance / 1000.0;
              }
              switch (distanceFilter) {
                case 'Within 1km':
                  distanceMatch = distance <= 1.0;
                  break;
                case 'Within 5km':
                  distanceMatch = distance <= 5.0;
                  break;
                case 'Within 10km':
                  distanceMatch = distance <= 10.0;
                  break;
                default:
                  distanceMatch = true;
              }
            } catch (e) {
              distanceMatch = true;
            }
          }

          // Status filter
          bool statusMatch = statusFilter == 'All';
          if (statusFilter != 'All' && facility.openingHours != null) {
            final hours = facility.openingHours!.toLowerCase();
            if (statusFilter == 'Open Now') {
              statusMatch = hours.contains('24/7') || hours.contains('open');
            } else if (statusFilter == '24/7') {
              statusMatch = hours.contains('24/7');
            } else if (statusFilter == 'Closed') {
              statusMatch = !hours.contains('24/7') && !hours.contains('open');
            }
          }

          // Emergency filter
          bool emergencyMatch = emergencyFilter == 'All';
          if (emergencyFilter != 'All' && facility.services != null) {
            final hasEmergency = facility.services!.any((service) => 
              service.toLowerCase().contains('emergency'));
            
            if (emergencyFilter == 'Emergency Available') {
              emergencyMatch = hasEmergency;
            } else if (emergencyFilter == 'No Emergency') {
              emergencyMatch = !hasEmergency;
            }
          }

          // Service filter
          bool serviceMatch = serviceFilter == 'All';
          if (serviceFilter != 'All' && facility.services != null && facility.services!.isNotEmpty) {
            serviceMatch = facility.services!.any((service) => 
              service.toLowerCase().contains(serviceFilter.toLowerCase()));
          }

          // Facility Type filter
          bool facilityTypeMatch = facilityTypeFilter == 'All';
          if (facilityTypeFilter != 'All') {
            facilityTypeMatch = facility.facilityType.toLowerCase() == facilityTypeFilter.toLowerCase();
          }

          // Hospital Type filter
          bool hospitalTypeMatch = hospitalTypeFilter == 'All';
          if (hospitalTypeFilter != 'All' && facility.hospitalType != null) {
            hospitalTypeMatch = facility.hospitalType!.toLowerCase().contains(hospitalTypeFilter.toLowerCase());
          }

          // Pharmacy Type filter
          bool pharmacyTypeMatch = pharmacyTypeFilter == 'All';
          if (pharmacyTypeFilter != 'All' && facility.pharmacyType != null) {
            pharmacyTypeMatch = facility.pharmacyType!.toLowerCase().contains(pharmacyTypeFilter.toLowerCase());
          }

          return distanceMatch && statusMatch && emergencyMatch && serviceMatch && facilityTypeMatch && hospitalTypeMatch && pharmacyTypeMatch;
        }).toList();
      }
      
      displayFacilities = result;
    });
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
      
      if (distance < 1.0) {
        final int meters = (distance * 1000).toInt();
        return '$meters m';
      }
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
      double getDist(String d) {
        if (d == 'N/A' || d == 'Calculating...') return 999.0;
        double val = double.tryParse(d.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 999.0;
        return d.endsWith(' m') ? val / 1000.0 : val;
      }
      final distanceA = getDist(a.distance);
      final distanceB = getDist(b.distance);
      return distanceA.compareTo(distanceB);
    });
    
    setState(() {
      facilities = sortedFacilities;
    });
  }

  @override
  Widget build(BuildContext context) {

    final defaultPromotions = [
      PromotionSlide(
        imageUrl: 'assets/images/logo.png',
        title: 'Find Best Doctors',
        subtitle: 'Connect with top medical professionals in your area',
        buttonText: 'Search Now',
        onButtonTap: () {},
      ),
      PromotionSlide(
        imageUrl: 'assets/images/logo.png',
        title: '24/7 Emergency Care',
        subtitle: 'Get immediate medical assistance whenever you need it',
        buttonText: 'Learn More',
        onButtonTap: () {},
      ),
      PromotionSlide(
        imageUrl: 'assets/images/logo.png',
        title: 'Book Appointments',
        subtitle: 'Schedule your medical visits with just a few taps',
        buttonText: 'Book Now',
        onButtonTap: () {},
      ),
    ];

    final displaySlides = promotionSlides.isNotEmpty ? promotionSlides : defaultPromotions;

    return MainLayout(
      title: 'Home',
      child: Column(
        children: [
          MiniHeader(
            onSearch: _searchFacilities,
            onFilter: () {
              // Handle filter functionality
            },
            onLocation: () {
              // Handle location functionality
            },
            onFilterChanged: (filterString) {
              setState(() {
                _filterString = filterString;
              });
              _updateDisplayFacilities();
            },
            currentLocation: 'Detecting location...',
          ),
          const SizedBox(height: 16),
          Promotion(
            slides: displaySlides,
            height: 180,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
          ),
          const SizedBox(height: 20),
          Facility(
            facilities: displayFacilities,
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
