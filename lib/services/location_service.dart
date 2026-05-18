import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'connection.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Platform detection
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  static bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  // Check if location services are enabled on device
  static Future<bool> isLocationServiceEnabled() async {
    if (isDesktop) return true;
    return await Geolocator.isLocationServiceEnabled();
  }

  // Request location permission and handle all cases
  static Future<bool> requestLocationPermission() async {
    if (isDesktop) return true;
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<bool> _handleLocationPermission() async {
    // Skip permission checks on desktop
    if (isDesktop) {
      debugPrint('📍 Desktop mode: Using mock location');
      return true;
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled. Please enable services');
        return false;
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return false;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          debugPrint('Location permissions are permanently denied, we cannot request permissions.');
        }
        return false;
      }
      return true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Error checking location permissions: $error');
      }
      return false;
    }
  }

  // Static method for easy access (matches your MiniHeader usage)
  static Future<String?> getCurrentLocation() async {
    return LocationService().getCurrentLocationInstance();
  }

  // Instance method
  Future<String?> getCurrentLocationInstance() async {
    try {
      // Check if location services are enabled first
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return null;
      }

      // Check connection status first
      final connectionService = ConnectionService();
      final isOnline = await connectionService.checkConnection();
      
      if (!isOnline) {
        return 'Location Unavailable (Offline)';
      }

      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) return null;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      List<Placemark>? placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      final locationParts = <String>[];

      if (place.locality?.isNotEmpty == true) {
        locationParts.add(place.locality!);
      }
      if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
        locationParts.add(place.administrativeArea!);
      }
      if (place.country != null && place.country!.isNotEmpty) {
        locationParts.add(place.country!);
      }

      return locationParts.isNotEmpty ? locationParts.join(', ') : 'Unknown Location';
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Error getting location: $error');
      }
      return null;
    }
  }

  // Static method to get Position object
  static Future<Position?> getCurrentPosition() async {
    return LocationService().getCurrentPositionInstance();
  }

  // Instance method to get Position object
  Future<Position?> getCurrentPositionInstance() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return null;
      }

      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Error getting position: $error');
      }
      return null;
    }
  }

  // Mock Position for desktop development
}
