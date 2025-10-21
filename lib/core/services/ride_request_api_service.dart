import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:thirikkale_driver/config/api_config.dart';
import 'package:thirikkale_driver/features/home/models/ride_request_model.dart';

class RideRequestApiService {
  static const Duration _pollInterval = Duration(seconds: 5);
  Timer? _pollTimer;
  StreamController<List<RideRequest>>? _rideRequestController;

  Stream<List<RideRequest>>? get rideRequestStream =>
      _rideRequestController?.stream;

  // Start listening for ride requests for a specific driver
  Future<void> startListeningForRideRequests(
    String driverId,
    String accessToken,
  ) async {
    print('🔊 Starting to listen for ride requests for driver: $driverId');

    // Stop any existing listener first
    stopListeningForRideRequests();

    _rideRequestController = StreamController<List<RideRequest>>.broadcast();

    // Start polling for ride requests
    _pollTimer = Timer.periodic(_pollInterval, (timer) async {
      try {
        final rideRequests = await _fetchPendingRideRequests(
          driverId,
          accessToken,
        );
        _rideRequestController?.add(rideRequests);
      } catch (e) {
        print('❌ Error fetching ride requests: $e');
        _rideRequestController?.addError(e);
      }
    });

    // Also fetch immediately
    try {
      final rideRequests = await _fetchPendingRideRequests(
        driverId,
        accessToken,
      );
      _rideRequestController?.add(rideRequests);
    } catch (e) {
      print('❌ Error fetching initial ride requests: $e');
    }
  }

  // Stop listening for ride requests
  void stopListeningForRideRequests() {
    print('🔇 Stopping ride request listener');
    _pollTimer?.cancel();
    _pollTimer = null;
    _rideRequestController?.close();
    _rideRequestController = null;
  }

  // Check if currently listening
  bool get isListening => _pollTimer?.isActive == true;

  // Fetch pending ride requests from backend
  Future<List<RideRequest>> _fetchPendingRideRequests(
    String driverId,
    String accessToken,
  ) async {
    try {
      final url =
          '${ApiConfig.rideServiceBaseUrl}/rides/pending-for-driver/$driverId';

      print('🔍 Fetching ride requests from: $url');

      final headers = ApiConfig.getJWTHeaders(accessToken);
      headers['User-ID'] = driverId;

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 10));

      print('📨 Ride requests response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('📄 Found ${data.length} pending ride requests');
        return data.map((json) => RideRequest.fromBackendJson(json)).toList();
      } else if (response.statusCode == 404) {
        // No pending requests
        print('📄 No pending ride requests found');
        return [];
      } else if (response.statusCode == 401) {
        print('❌ Authentication failed for ride requests');
        throw Exception('Authentication failed');
      } else {
        print('📄 Ride requests response body: ${response.body}');
        throw Exception(
          'Failed to fetch ride requests: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error in _fetchPendingRideRequests: $e');
      rethrow; // Re-throw to handle in the calling method
    }
  }

  // Accept a ride request
  Future<Map<String, dynamic>> acceptRideRequest(
    String rideId,
    String driverId,
    String accessToken,
  ) async {
    try {
      print('✅ Accepting ride request: $rideId for driver: $driverId');

      final url = ApiConfig.acceptRide(rideId);

      final headers = ApiConfig.getJWTHeaders(accessToken);
      headers['User-ID'] = driverId;

      final body = {
        'driverId': driverId,
        'acceptedAt': DateTime.now().toIso8601String(),
      };

      final response = await http
          .post(Uri.parse(url), headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));

      print('📨 Accept ride response status: ${response.statusCode}');
      print('📄 Accept ride response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Ride accepted successfully',
        };
      } else if (response.statusCode == 409) {
        // Ride already accepted by another driver
        return {
          'success': false,
          'error': 'This ride has already been accepted by another driver',
          'code': 'RIDE_ALREADY_ACCEPTED',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Ride not found or no longer available',
          'code': 'RIDE_NOT_FOUND',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to accept ride',
          'code': 'UNKNOWN_ERROR',
        };
      }
    } catch (e) {
      print('❌ Error accepting ride request: $e');
      return {
        'success': false,
        'error': 'Network error. Please check your connection.',
        'code': 'NETWORK_ERROR',
      };
    }
  }

  // Cancel a ride request
  Future<Map<String, dynamic>> cancelRideRequest(
    String rideId,
    String driverId,
    String accessToken,
    String? reason,
  ) async {
    try {
      print('❌ Canceling ride request: $rideId for driver: $driverId');

      final url = '${ApiConfig.rideServiceBaseUrl}/rides/$rideId/cancel';

      final headers = ApiConfig.getJWTHeaders(accessToken);
      headers['User-ID'] = driverId;

      final body = {
        'driverId': driverId,
        'reason': reason ?? 'Driver cancelled',
        'cancelledBy': 'DRIVER',
      };

      final response = await http
          .post(
            Uri.parse(url),
            headers: ApiConfig.getJWTHeaders(accessToken),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      print('📨 Cancel ride response status: ${response.statusCode}');
      print('📄 Cancel ride response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to cancel ride',
        };
      }
    } catch (e) {
      print('❌ Error canceling ride request: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> driverArrived(
    String rideId,
    String accessToken,
  ) async {
    try {
      print('🚐 Driver has arrived for ride: $rideId');
      final url = ApiConfig.driverArrived(rideId);
      final headers = ApiConfig.getJWTHeaders(accessToken);

      final response = await http
          .post(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));

      print('🚐 Driver arrived response status: ${response.statusCode}');
      print('🚐 Driver arrived response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to mark as arrived'};
      }
    } catch (e) {
      print('❌ Error marking as arrived: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Notify backend that ride has started
  Future<Map<String, dynamic>> startRide(
    String rideId,
    String accessToken,
  ) async {
    try {
      print('▶️ Starting ride: $rideId');
      final url = ApiConfig.startRide(rideId);
      final headers = ApiConfig.getJWTHeaders(accessToken);

      final response = await http
          .post(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));

      print('▶️ Start ride response status: ${response.statusCode}');
      print('▶️ Start ride response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to start ride'};
      }
    } catch (e) {
      print('❌ Error starting ride: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Notify backend that ride is complete
  Future<Map<String, dynamic>> completeRide(
    String rideId,
    String accessToken,
    double actualFare, // You'll need to pass the final fare
  ) async {
    try {
      print('🏁 Completing ride: $rideId');
      final url = ApiConfig.completeRide(rideId);
      final headers = ApiConfig.getJWTHeaders(accessToken);

      // The backend endpoint expects a RideUpdateDto
      final body = jsonEncode({
        'rideId': rideId,
        'actualFare': actualFare,
        // You can add rating/feedback here later if needed
        // 'rating': 5,
        // 'feedback': 'Great rider!'
      });

      final response = await http
          .post(Uri.parse(url), headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      print('🏁 Complete ride response status: ${response.statusCode}');
      print('🏁 Complete ride response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to complete ride'};
      }
    } catch (e) {
      print('❌ Error completing ride: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  void dispose() {
    stopListeningForRideRequests();
  }
}
