import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../services/location_service.dart';

class MiniHeader extends StatefulWidget {
  final Function(String)? onSearch;
  final VoidCallback? onFilter;
  final VoidCallback? onLocation;
  final String? currentLocation;
  
  const MiniHeader({
    super.key,
    this.onSearch,
    this.onFilter,
    this.onLocation,
    this.currentLocation,
  });

  @override
  State<MiniHeader> createState() => _MiniHeaderState();
}

class _MiniHeaderState extends State<MiniHeader> {
  final TextEditingController _searchController = TextEditingController();
  String? _detectedLocation;
  bool _isLoadingLocation = false;
  String? _platformInfo;

  @override
  void initState() {
    super.initState();
    _detectLocation();
    _setPlatformInfo();
  }

  @override
  void dispose() {
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
    });

    try {
      final location = await LocationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _detectedLocation = location;
          _isLoadingLocation = false;
        });
        
        // Show a snackbar to indicate mode on desktop
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
        setState(() {
          _detectedLocation = 'Location Error';
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

  @override
  Widget build(BuildContext context) {
    final displayLocation = _detectedLocation ?? widget.currentLocation;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                color: Colors.grey[600],
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
                                  ? 'Tap to detect' 
                                  : displayLocation + (_platformInfo ?? ''),
                                style: TextStyle(
                                  color: displayLocation != null
                                      ? Colors.grey[700]
                                      : Colors.blue,
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
                    color: Colors.grey[600],
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
                onTap: widget.onFilter,
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
    );
  }
}