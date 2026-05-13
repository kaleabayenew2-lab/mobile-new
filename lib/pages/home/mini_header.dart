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
  bool _isLoadingLocation = false;
  String? _platformInfo;
  bool _showLocationPopup = false;
  Timer? _debounceTimer;
  
  // Filter states
  String _selectedDistance = 'All';
  String _selectedStatus = 'All';
  String _selectedEmergency = 'All';
  String _selectedService = 'All';

  @override
  void initState() {
    super.initState();
    _detectLocation();
    _setPlatformInfo();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _setPlatformInfo() {
    if (LocationService.isDesktop && kDebugMode) {
      _platformInfo = ' (Test Mode)';
    }
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
          });
        }
        return;
      }

      // Try to get actual location
      final location = await LocationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _detectedLocation = location;
          _isLoadingLocation = false;
          _showLocationPopup = false;
        });
        
        if (LocationService.isDesktop && kDebugMode && location != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📍 Using test location: $location'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Check if error is due to location services being off
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          setState(() {
            _detectedLocation = null;
            _isLoadingLocation = false;
            _showLocationPopup = true;
          });
        } else {
          setState(() {
            _detectedLocation = 'Location Error';
            _isLoadingLocation = false;
          });
        }
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

  void _resetFilters() {
    setState(() {
      _selectedDistance = 'All';
      _selectedStatus = 'All';
      _selectedEmergency = 'All';
      _selectedService = 'All';
    });
  }

  void _showFilterPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration: BoxDecoration(
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
                    
                    // Distance Filter
                    _buildFilterSection(
                      'Distance',
                      ['All', 'Within 1km', 'Within 5km', 'Within 10km'],
                      _selectedDistance,
                      (value) {
                        setState(() => _selectedDistance = value);
                      },
                    ),
                    
                    // Status Filter
                    _buildFilterSection(
                      'Open/Close Status',
                      ['All', 'Open Now', '24/7', 'Closed'],
                      _selectedStatus,
                      (value) {
                        setState(() => _selectedStatus = value);
                      },
                    ),
                    
                    // Emergency Filter
                    _buildFilterSection(
                      'Emergency Services',
                      ['All', 'Emergency Available', 'No Emergency'],
                      _selectedEmergency,
                      (value) {
                        setState(() => _selectedEmergency = value);
                      },
                    ),
                    
                    // Services Filter
                    _buildFilterSection(
                      'Services',
                      ['All', 'General', 'Specialized', 'Emergency'],
                      _selectedService,
                      (value) {
                        setState(() => _selectedService = value);
                      },
                    ),
                    
                    // Action Buttons
                    const SizedBox(height: 20),
                    
                    // Reset and Apply buttons row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          // Reset Button
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                // Reset all filters
                                setState(() {
                                  _selectedDistance = 'All';
                                  _selectedStatus = 'All';
                                  _selectedEmergency = 'All';
                                  _selectedService = 'All';
                                });
                                
                                // Apply reset filters immediately
                                final filterString = 'Distance: All, Status: All, Emergency: All, Service: All';
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
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
                                // Apply filters and notify parent
                                final filterString = 'Distance: $_selectedDistance, Status: $_selectedStatus, Emergency: $_selectedEmergency, Service: $_selectedService';
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
    final displayLocation = _detectedLocation ?? widget.currentLocation;
    
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
              // Location row
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: _showLocationPopup ? Colors.red : Colors.grey[600],
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: GestureDetector(
                      onTap: _refreshLocation,
                      child: _isLoadingLocation
                          ? Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey[600]!,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Detecting...',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    displayLocation == null 
                                      ? (_showLocationPopup ? 'Location OFF - Tap to fix' : 'Tap to detect')
                                      : displayLocation + (_platformInfo ?? ''),
                                    style: TextStyle(
                                      color: displayLocation != null
                                          ? Colors.grey[700]
                                          : (_showLocationPopup ? Colors.red : Colors.blue),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (!_isLoadingLocation)
                    GestureDetector(
                      onTap: _refreshLocation,
                      child: Icon(
                        Icons.refresh,
                        color: _showLocationPopup ? Colors.red : Colors.grey[600],
                        size: 18,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Search and filter row
              Row(
                children: [
                  // Search bar
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
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
                            fontSize: 12,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[600],
                            size: 18,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Filter button
                  GestureDetector(
                    onTap: _showFilterPopup,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.filter_list,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
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