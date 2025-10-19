import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thirikkale_driver/config/api_config.dart';
import 'package:thirikkale_driver/core/services/web_socket_service.dart';

class AvailabilityService {
  // Inject the WebSocketService to handle real-time subscriptions
  final WebSocketService _webSocketService = WebSocketService();

  // Set driver availability (online/offline)
  Future<Map<String, dynamic>> setDriverAvailability({
    required String driverId,
    required double latitude,
    required double longitude,
    required bool isAvailable,
    required String accessToken,
  }) async {
    try {
      print('🔄 Setting driver availability to $isAvailable...');

      // First, update the driver's location with the target availability state
      await _updateDriverLocation(
        driverId: driverId,
        latitude: latitude,
        longitude: longitude,
        isAvailable: isAvailable,
        accessToken: accessToken,
      );

      // Then, make the formal call to set the availability
      final url =
          '${ApiConfig.rideServiceBaseUrl}/drivers/$driverId/availability?available=$isAvailable';

      final headers = ApiConfig.getJWTHeaders(accessToken);
      headers['User-ID'] = driverId;

      final response = await http
          .put(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));

      print('📥 Availability Response Status: ${response.statusCode}');
      print('📥 Availability Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // --- THIS IS THE CRUCIAL REAL-TIME LOGIC ---
        if (isAvailable) {
          // If the driver is going ONLINE, subscribe to the geo channels
          print('🟢 Driver went online - Subscribing to geographical channels.');
          _webSocketService.subscribeToGeographicalChannels(
            driverId,
            latitude,
            longitude,
          );
        } else {
          // If the driver is going OFFLINE, unsubscribe
          print('🔴 Driver went offline - Unsubscribing from geographical channels.');
          _webSocketService.unsubscribeFromGeographicalChannels(driverId);
        }
        // --- END OF REAL-TIME LOGIC ---

        if (response.body.isEmpty) {
          return {
            'success': true,
            'data': {'isAvailable': isAvailable}
          };
        }
        return {'success': true, 'data': jsonDecode(response.body)};
      }

      return {'success': false, 'error': 'Failed to set availability'};
    } catch (e) {
      print('❌ Error setting driver availability: $e');
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
          .get(Uri.parse(url), headers: headers)
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

    print('📍 Updating location before setting availability: $url');

    final response = await http
        .post(Uri.parse(url), headers: headers, body: body)
        .timeout(const Duration(seconds: 10));

    print('📍 Location update response: ${response.statusCode}');
  }
}

