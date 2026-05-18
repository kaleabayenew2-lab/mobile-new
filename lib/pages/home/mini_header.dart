import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';
import '../../services/location_service.dart';

class MiniHeader extends StatefulWidget {
  final Function(String)? onSearch;
  final VoidCallback? onFilter;
  final VoidCallback? onLocation;
  final String? currentLocation;
  final Function(String)? onFilterChanged;
  
  const MiniHeader({
    super.key,
    this.onSearch,
    this.onFilter,
    this.onLocation,
    this.currentLocation,
    this.onFilterChanged,
  });

  @override
  State<MiniHeader> createState() => _MiniHeaderState();
}

class _MiniHeaderState extends State<MiniHeader> {
  final TextEditingController _searchController = TextEditingController();
  String? _detectedLocation;
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _showLocationPopup = false;
  Timer? _debounceTimer;
  
  // Filter states
  String _selectedDistance = 'All';
  String _selectedStatus = 'All';
  String _selectedEmergency = 'All';
  String _selectedService = 'All';
  String _selectedFacilityType = 'All';
  String _selectedHospitalType = 'All';
  String _selectedPharmacyType = 'All';

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    if (_isLoadingLocation) return;
    
    setState(() {
      _isLoadingLocation = true;
      _showLocationPopup = false;
    });

    try {
      // Check if location services are enabled on device
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      
      if (!serviceEnabled && LocationService.isMobile) {
        // Location is OFF on device - show popup
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
            _showLocationPopup = true;
            _detectedLocation = null;
            _currentPosition = null;
          });
        }
        return;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
          if (mounted) {
            setState(() {
              _isLoadingLocation = false;
              _showLocationPopup = true;
              _detectedLocation = null;
              _currentPosition = null;
            });
          }
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
            _showLocationPopup = true;
            _detectedLocation = null;
            _currentPosition = null;
          });
        }
        return;
      }

      // Try to get actual location position and name
      final position = await LocationService.getCurrentPosition();
      String? locationName;
      if (position != null) {
        try {
          final loc = await LocationService.getCurrentLocation();
          locationName = loc;
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _currentPosition = position ?? Position(
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
          _detectedLocation = locationName ?? 'New York, USA';
          _isLoadingLocation = false;
          _showLocationPopup = false;
        });
        
        if (LocationService.isDesktop && kDebugMode && _detectedLocation != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📍 Using test location: $_detectedLocation'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
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
          _detectedLocation = 'New York, USA';
          _isLoadingLocation = false;
        });
      }
      if (kDebugMode) {
        print('Error detecting location: $e');
      }
    }
  }

  Future<void> _refreshLocation() async {
    await _detectLocation();
    widget.onLocation?.call();
  }

  Future<void> _openLocationSettings() async {
    // Close popup
    setState(() {
      _showLocationPopup = false;
    });
    
    // Open system location settings
    if (Platform.isAndroid) {
      await openAppSettings();
    } else if (Platform.isIOS) {
      await openAppSettings();
    } else {
      // For web or desktop, just show info
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enable location services in your system settings'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
    
    // Wait for user to return from settings, then retry
    Future.delayed(const Duration(milliseconds: 500), () {
      _detectLocation();
    });
  }

  void _cancelPopup() {
    setState(() {
      _showLocationPopup = false;
    });
  }

  bool get _hasActiveFilters {
    return _selectedDistance != 'All' ||
      _selectedStatus != 'All' ||
      _selectedEmergency != 'All' ||
      _selectedService != 'All' ||
      _selectedFacilityType != 'All' ||
      _selectedHospitalType != 'All' ||
      _selectedPharmacyType != 'All';
  }

  String get _activeFilterSummary {
    final values = <String>[];
    if (_selectedDistance != 'All') {
      values.add(_selectedDistance);
    }
    if (_selectedStatus != 'All') {
      values.add(_selectedStatus);
    }
    if (_selectedEmergency != 'All') {
      values.add(_selectedEmergency);
    }
    if (_selectedService != 'All') {
      values.add(_selectedService);
    }
    if (_selectedFacilityType != 'All') {
      values.add(_selectedFacilityType);
    }
    if (_selectedHospitalType != 'All') {
      values.add('Hospital: $_selectedHospitalType');
    }
    if (_selectedPharmacyType != 'All') {
      values.add('Pharmacy: $_selectedPharmacyType');
    }
    return values.isEmpty ? 'All filters' : values.join(' • ');
  }

  void _resetFilters() {
    setState(() {
      _selectedDistance = 'All';
      _selectedStatus = 'All';
      _selectedEmergency = 'All';
      _selectedService = 'All';
      _selectedFacilityType = 'All';
      _selectedHospitalType = 'All';
      _selectedPharmacyType = 'All';
    });
  }

  void _showFilterPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filter Options',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    
                    // Facility Type Filter
                    _buildFilterSection(
                      'Facility Type',
                      ['All', 'Hospital', 'Pharmacy'],
                      _selectedFacilityType,
                      (value) {
                        setModalState(() {
                          _selectedFacilityType = value;
                          if (value == 'Hospital') {
                            _selectedPharmacyType = 'All';
                          } else if (value == 'Pharmacy') {
                            _selectedHospitalType = 'All';
                          }
                        });
                      },
                    ),

                    // Hospital Type Filter
                    if (_selectedFacilityType == 'All' || _selectedFacilityType == 'Hospital')
                      _buildFilterSection(
                        'Hospital Type',
                        ['All', 'General', 'Referral', 'Specialized', 'Primary', 'Private'],
                        _selectedHospitalType,
                        (value) {
                          setModalState(() {
                            _selectedHospitalType = value;
                          });
                        },
                      ),

                    // Pharmacy Type Filter
                    if (_selectedFacilityType == 'All' || _selectedFacilityType == 'Pharmacy')
                      _buildFilterSection(
                        'Pharmacy Type',
                        ['All', 'Retail', 'Wholesale', '24/7', 'Community'],
                        _selectedPharmacyType,
                        (value) {
                          setModalState(() {
                            _selectedPharmacyType = value;
                          });
                        },
                      ),

                    // Distance Filter
                    _buildFilterSection(
                      'Distance',
                      ['All', 'Within 1km', 'Within 5km', 'Within 10km'],
                      _selectedDistance,
                      (value) {
                        setModalState(() {
                          _selectedDistance = value;
                        });
                      },
                    ),
                    
                    // Status Filter
                    _buildFilterSection(
                      'Open/Close Status',
                      ['All', 'Open Now', '24/7', 'Closed'],
                      _selectedStatus,
                      (value) {
                        setModalState(() {
                          _selectedStatus = value;
                        });
                      },
                    ),
                    
                    // Emergency Filter
                    _buildFilterSection(
                      'Emergency Services',
                      ['All', 'Emergency Available', 'No Emergency'],
                      _selectedEmergency,
                      (value) {
                        setModalState(() {
                          _selectedEmergency = value;
                        });
                      },
                    ),
                    
                    // Services Filter
                    _buildFilterSection(
                      'Specialized Service Offered',
                      ['All', 'Emergency', 'Pediatrics', 'Cardiology', 'General Consultation', 'Dental', 'Pharmacy Service'],
                      _selectedService,
                      (value) {
                        setModalState(() {
                          _selectedService = value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Action Buttons Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          // Reset Button
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedDistance = 'All';
                                  _selectedStatus = 'All';
                                  _selectedEmergency = 'All';
                                  _selectedService = 'All';
                                  _selectedFacilityType = 'All';
                                  _selectedHospitalType = 'All';
                                  _selectedPharmacyType = 'All';
                                });
                                const filterString = 'Distance: All, Status: All, Emergency: All, Service: All, FacilityType: All, HospitalType: All, PharmacyType: All';
                                if (widget.onFilterChanged != null) {
                                  widget.onFilterChanged!(filterString);
                                }
                                widget.onFilter?.call();
                                Navigator.of(context).pop();
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: BorderSide(color: Colors.red.shade300),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.refresh, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Reset All',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Apply Button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final filterString = 'Distance: $_selectedDistance, Status: $_selectedStatus, Emergency: $_selectedEmergency, Service: $_selectedService, FacilityType: $_selectedFacilityType, HospitalType: $_selectedHospitalType, PharmacyType: $_selectedPharmacyType';
                                if (widget.onFilterChanged != null) {
                                  widget.onFilterChanged!(filterString);
                                }
                                widget.onFilter?.call();
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Apply Filters',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection(String title, List<String> options, String selectedValue, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = option == selectedValue;
              return GestureDetector(
                onTap: () => onChanged(option),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayLocation = _isLoadingLocation
        ? 'Detecting location...'
        : (_detectedLocation ?? widget.currentLocation ?? 'Location unavailable');
    
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              // Location Details Container (Single beautiful method as requested by user)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50.withOpacity(0.8), Colors.purple.shade50.withOpacity(0.5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade100, width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.location_on_rounded, size: 20, color: Colors.blue.shade700),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Location',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isLoadingLocation 
                                ? 'Detecting current location...' 
                                : displayLocation,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.my_location_rounded, color: Colors.blue.shade700, size: 20),
                      onPressed: _refreshLocation,
                      tooltip: 'Refresh Location',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Search bar with integrated filter action
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    // Cancel previous timer
                    _debounceTimer?.cancel();
                    
                    // Set new timer for debounced search
                    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                      if (widget.onSearch != null && mounted) {
                        widget.onSearch!(value);
                      }
                    });
                  },
                  onSubmitted: widget.onSearch,
                  decoration: InputDecoration(
                    hintText: 'Search doctors, clinics...',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    suffixIcon: InkWell(
                      onTap: _showFilterPopup,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _hasActiveFilters ? Colors.blue.shade800 : Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.filter_list,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Active filter summary
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _hasActiveFilters
                    ? Container(
                        key: const ValueKey('filterSummary'),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.tune,
                              size: 18,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _activeFilterSummary,
                                style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _resetFilters();
                                if (widget.onFilterChanged != null) {
                                  widget.onFilterChanged!('Distance: All, Status: All, Emergency: All, Service: All');
                                }
                              },
                              child: Text(
                                'Clear',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        key: const ValueKey('filterHint'),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tap Filter to narrow results by distance, status, emergency services or specialties.',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
        
        // LOCATION POPUP OVERLAY
        if (_showLocationPopup)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  width: MediaQuery.of(context).size.width * 0.85,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_off_outlined,
                          size: 56,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Location Services are OFF",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E2F3C),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          "We need your location to find nearby doctors and facilities. Please enable location in settings.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _cancelPopup,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.grey.shade700,
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text("Cancel"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _openLocationSettings,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                ),
                                child: const Text("Go to Settings"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}