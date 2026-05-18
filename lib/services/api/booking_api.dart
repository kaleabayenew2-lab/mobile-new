import '../api_service.dart';

class BookingApi {
  static Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData, {String? token}) async {
    final headers = {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    return await ApiService.post('/bookings', bookingData, extraHeaders: headers);
  }

  static Future<Map<String, dynamic>> getBookings({String? email, int? facilityId, String? token}) async {
    final headers = {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    String url = '/bookings';
    if (email != null) {
      url = '/bookings?email=${Uri.encodeQueryComponent(email)}';
    } else if (facilityId != null) {
      url = '/bookings?facilityId=$facilityId';
    }
    return await ApiService.get(url, extraHeaders: headers);
  }

  static Future<Map<String, dynamic>> updateBookingStatus(int bookingId, String status, {String? token}) async {
    final headers = {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    return await ApiService.put('/bookings/$bookingId/status', {'status': status}, extraHeaders: headers);
  }
}
