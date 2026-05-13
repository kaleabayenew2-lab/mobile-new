import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class HomeApi {
  // API endpoints
  static const String _baseUrl = 'http://127.0.0.1:5000';
  static const String _facilitiesEndpoint = '$_baseUrl/api/facilities';
  static const String _promotionsEndpoint = '$_baseUrl/api/promotions';
  static const String _searchEndpoint = '$_baseUrl/api/search';

  // Get all facilities
  static Future<List<Map<String, dynamic>>> getFacilities() async {
    try {
      final response = await http.get(
        Uri.parse(_facilitiesEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> facilitiesData = data['facilities'];
          return facilitiesData.cast<Map<String, dynamic>>();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch facilities');
        }
      } else {
        throw Exception('Failed to load facilities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch facilities: $e');
    }
  }

  // Get promotions
  static Future<List<Map<String, dynamic>>> getPromotions() async {
    try {
      final response = await http.get(
        Uri.parse(_promotionsEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> promotionsData = data['promotions'] ?? [];
          return promotionsData.cast<Map<String, dynamic>>();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch promotions');
        }
      } else {
        throw Exception('Failed to load promotions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch promotions: $e');
    }
  }

  // Search facilities
  static Future<List<Map<String, dynamic>>> searchFacilities(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_searchEndpoint?q=${Uri.encodeComponent(query)}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> facilitiesData = data['facilities'] ?? [];
          return facilitiesData.cast<Map<String, dynamic>>();
        } else {
          throw Exception(data['message'] ?? 'Failed to search facilities');
        }
      } else {
        throw Exception('Failed to search facilities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search facilities: $e');
    }
  }

  // Get facilities by type
  static Future<List<Map<String, dynamic>>> getFacilitiesByType(String type) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final allFacilities = await getFacilities();
      return allFacilities.where((facility) => 
        facility['type'] == type
      ).toList();
    } catch (e) {
      throw Exception('Failed to fetch facilities by type: $e');
    }
  }

  // Get facility details
  static Future<Map<String, dynamic>> getFacilityDetails(int id) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final allFacilities = await getFacilities();
      final facility = allFacilities.firstWhere(
        (facility) => facility['id'] == id,
        orElse: () => throw Exception('Facility not found'),
      );
      
      return facility;
    } catch (e) {
      throw Exception('Failed to fetch facility details: $e');
    }
  }

  // Get nearby facilities
  static Future<List<Map<String, dynamic>>> getNearbyFacilities(
    double latitude, 
    double longitude, 
    double radiusKm
  ) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final allFacilities = await getFacilities();
      
      // Mock distance calculation - replace with actual geolocation logic
      return allFacilities.where((facility) {
        final distance = _calculateDistance(
          latitude, 
          longitude, 
          facility['coordinates'][0], 
          facility['coordinates'][1]
        );
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch nearby facilities: $e');
    }
  }

  // Helper method to calculate distance between two points
  static double _calculateDistance(
    double lat1, 
    double lon1, 
    double lat2, 
    double lon2
  ) {
    // Haversine formula - simplified for demo
    const double earthRadius = 6371; // km
    
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    
    final double a = (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.toRadians().cos() * lat2.toRadians().cos() *
        (dLon / 2).sin() * (dLon / 2).sin();
    
    final double c = 2 * a.sqrt().asin();
    
    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}

// Extension methods for math operations
extension DoubleExtension on double {
  double toRadians() => this * (math.pi / 180);
  double sin() => math.sin(this);
  double cos() => math.cos(this);
  double asin() => math.asin(this);
  double sqrt() => math.sqrt(this);
}
