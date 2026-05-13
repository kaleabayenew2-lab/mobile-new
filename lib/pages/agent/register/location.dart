// lib/pages/agent/location.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationSection extends StatefulWidget {
  final Function(double?, double?) onLocationChanged;
  final VoidCallback onValidate;

  const LocationSection({
    super.key,
    required this.onLocationChanged,
    required this.onValidate,
  });

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _latitudeController.addListener(_notifyParent);
    _longitudeController.addListener(_notifyParent);
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _notifyParent() {
    double? latitude = _latitudeController.text.isNotEmpty 
        ? double.tryParse(_latitudeController.text) 
        : null;
    double? longitude = _longitudeController.text.isNotEmpty 
        ? double.tryParse(_longitudeController.text) 
        : null;
    widget.onLocationChanged(latitude, longitude);
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. Please enable them.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Check for permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permissions are denied.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied. Please enable them in settings.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          _latitudeController.text = position.latitude.toStringAsFixed(6);
          _longitudeController.text = position.longitude.toStringAsFixed(6);
        });
        _notifyParent();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Current location captured successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  // Open map to select location
  Future<void> _openMap() async {
    // This is a placeholder for map integration
    // You can integrate with google_maps_flutter or other map packages
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Map integration coming soon. Please enter coordinates manually.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Validation methods
  String? _validateLatitude(String? value) {
    if (value == null || value.isEmpty) {
      return 'Latitude is required';
    }
    final double? lat = double.tryParse(value);
    if (lat == null) {
      return 'Please enter a valid latitude';
    }
    if (lat < -90 || lat > 90) {
      return 'Latitude must be between -90 and 90';
    }
    return null;
  }

  String? _validateLongitude(String? value) {
    if (value == null || value.isEmpty) {
      return 'Longitude is required';
    }
    final double? lng = double.tryParse(value);
    if (lng == null) {
      return 'Please enter a valid longitude';
    }
    if (lng < -180 || lng > 180) {
      return 'Longitude must be between -180 and 180';
    }
    return null;
  }

  // Form validation
  bool validateForm() {
    return _validateLatitude(_latitudeController.text) == null &&
           _validateLongitude(_longitudeController.text) == null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.red[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Location Coordinates',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              // Current location button
              ElevatedButton.icon(
                onPressed: _isGettingLocation ? null : _getCurrentLocation,
                icon: _isGettingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.my_location, size: 16),
                label: Text(
                  _isGettingLocation ? 'Getting...' : 'Current Location',
                  style: const TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Latitude and Longitude input fields
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _latitudeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                    hintText: 'e.g., 9.0247',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.map, size: 20),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  validator: _validateLatitude,
                  onChanged: (_) => _notifyParent(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _longitudeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Longitude',
                    hintText: 'e.g., 38.7468',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.map, size: 20),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  validator: _validateLongitude,
                  onChanged: (_) => _notifyParent(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Map preview placeholder
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Stack(
              children: [
                // Map placeholder
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, color: Colors.grey[400], size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'Map Preview',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Coordinates will show here',
                        style: TextStyle(color: Colors.grey[400], fontSize: 10),
                      ),
                    ],
                  ),
                ),
                // Open map button
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: _openMap,
                    icon: Icon(Icons.open_in_new, color: Colors.blue[600], size: 20),
                    tooltip: 'Open Map',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Info text
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue[600], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Enter your facility coordinates or use "Current Location" button to auto-fill',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue[800],
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
}