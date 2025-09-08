import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thirikkale_driver/config/api_config.dart';

class DriverAvailabilityService {
  // Set driver availability (online/offline)
  Future<Map<String, dynamic>> setDriverAvailability({
  required String driverId,
  required double latitude,
  required double longitude,
  required bool isAvailable,
  required String vehicleType,
  required String accessToken,
}) async {
  try {
    print('🔄 Setting driver availability...');

    // FIRST: Update location to ensure record exists
    await _updateDriverLocation(
      driverId: driverId,
      latitude: latitude,
      longitude: longitude,
      isAvailable: isAvailable,
      accessToken: accessToken,
    );

    // THEN: Set availability 
    final url = '${ApiConfig.rideServiceBaseUrl}/drivers/$driverId/availability?available=$isAvailable';

    final headers = ApiConfig.getJWTHeaders(accessToken);
    headers['User-ID'] = driverId;

    final response = await http
        .put(Uri.parse(url), headers: headers)
        .timeout(const Duration(seconds: 10));

    print('📥 Response Status: ${response.statusCode}');
    print('📥 Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {
          'success': true,
          'data': {
            'driverId': driverId,
            'isAvailable': isAvailable,
            'latitude': latitude,
            'longitude': longitude,
          }
        };
      }
      return {'success': true, 'data': jsonDecode(response.body)};
    }

    return {'success': false, 'error': 'Failed to set availability'};
  } catch (e) {
    print('❌ Error: $e');
    return {'success': false, 'error': 'Network error: $e'};
  }
}

  // Get current driver availability status
  Future<Map<String, dynamic>> getDriverAvailability({
    required String driverId,
    required String accessToken,
  }) async {
    try {
      final url =
          '${ApiConfig.rideServiceBaseUrl}/drivers/$driverId/availability';

      print('🔍 Getting driver availability from: $url');

      final headers = ApiConfig.getJWTHeaders(accessToken);
      headers['User-ID'] = driverId;

      final response = await http
          .get(Uri.parse(url), headers: ApiConfig.getJWTHeaders(accessToken))
          .timeout(const Duration(seconds: 10));

      print('📥 Get availability response status: ${response.statusCode}');
      print('📥 Get availability response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {'success': true, 'data': responseData};
      } else {
        return {'success': false, 'error': 'Failed to get driver availability'};
      }
    } catch (e) {
      print('❌ Error getting driver availability: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Helper method to update location first
Future<void> _updateDriverLocation({
  required String driverId,
  required double latitude,
  required double longitude,
  required bool isAvailable,
  required String accessToken,
}) async {
  final url = '${ApiConfig.rideServiceBaseUrl}/drivers/$driverId/location';
  
  final headers = ApiConfig.getJWTHeaders(accessToken);
  headers['User-ID'] = driverId;

  final body = jsonEncode({
    'latitude': latitude,
    'longitude': longitude,
    'isAvailable': isAvailable,
  });

  print('📍 Updating location first: $url');

  final response = await http
      .post(Uri.parse(url), headers: headers, body: body)
      .timeout(const Duration(seconds: 10));

  print('📍 Location update response: ${response.statusCode}');
}
}
