import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../api_service.dart';

class FavoritesApi {
  static Future<Map<String, dynamic>> getFavoritesByEmail(String email, {String? token}) async {
    final headers = {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final query = Uri.encodeQueryComponent(email);
    return await ApiService.get('/facility-status/user-by-email?email=$query', extraHeaders: headers);
  }

  static Future<Map<String, dynamic>> addFavorite(String email, int facilityId, {String? token}) async {
    final headers = {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    return await ApiService.post('/facility-status', {
      'email': email,
      'facilityId': facilityId,
    }, extraHeaders: headers);
  }

  static Future<Map<String, dynamic>> removeFavorite(String email, int facilityId, {String? token}) async {
    final headers = {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    return await ApiService.post('/facility-status/remove', {
      'email': email,
      'facilityId': facilityId,
    }, extraHeaders: headers);
  }
}
