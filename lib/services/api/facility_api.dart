import '../api_service.dart';

class FacilityApi {
  static Future<Map<String, dynamic>> recordView(
    int facilityId, {
    String? viewerIdentifier,
    String? viewerType,
    String? token,
  }) async {
    final headers = {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final body = {
      if (viewerIdentifier != null) 'viewerIdentifier': viewerIdentifier,
      if (viewerType != null) 'viewerType': viewerType,
    };
    return await ApiService.post('/views/$facilityId', body, extraHeaders: headers);
  }
}
