import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:thirikkale_driver/config/api_config.dart';
import 'package:thirikkale_driver/features/scheduled_rides/models/card_models.dart';
import 'package:thirikkale_driver/features/scheduled_rides/models/scheduled_ride.dart';

class ScheduledRidesService {
  Future<List<ScheduledRide>> getNearbyRides({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      final url = ApiConfig.getNearbyScheduledRides(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      print('🔍 Fetching nearby rides from: $url');
      
      final resp = await http
          .get(Uri.parse(url))
          .timeout(ApiConfig.connectTimeout);
          
      print('📥 Response status: ${resp.statusCode}');
      
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final List data = jsonDecode(resp.body) as List;
        print('✅ Found ${data.length} nearby rides');
        return data.map((e) => ScheduledRide.fromJson(e)).toList();
      }
      throw Exception('Failed to load nearby rides (${resp.statusCode})');
    } catch (e) {
      print('❌ Error fetching nearby rides: $e');
      rethrow;
    }
  }

  // Get accepted rides for a specific driver (no location limit)
  Future<List<ScheduledRide>> getDriverAcceptedRides(String driverId) async {
    try {
      final url = ApiConfig.getDriverAcceptedRides(driverId);
      print('🔍 Fetching accepted rides for driver $driverId from: $url');
      
      final resp = await http
          .get(Uri.parse(url))
          .timeout(ApiConfig.connectTimeout);
          
      print('📥 Response status: ${resp.statusCode}');
      
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final List data = jsonDecode(resp.body) as List;
        print('✅ Found ${data.length} accepted rides for driver');
        return data.map((e) => ScheduledRide.fromJson(e)).toList();
      }
      throw Exception('Failed to load accepted rides (${resp.statusCode})');
    } catch (e) {
      print('❌ Error fetching accepted rides: $e');
      rethrow;
    }
  }

  Future<List<ScheduledRide>> routeMatch({
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropoffLatitude,
    required double dropoffLongitude,
    required double pickupRadiusKm,
    required double dropoffRadiusKm,
  }) async {
    try {
      final url = ApiConfig.routeMatch();
      print('🔍 Route match request to: $url');
      
      final resp = await http
          .post(
            Uri.parse(url),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode({
              'pickupLatitude': pickupLatitude,
              'pickupLongitude': pickupLongitude,
              'dropoffLatitude': dropoffLatitude,
              'dropoffLongitude': dropoffLongitude,
              'pickupRadiusKm': pickupRadiusKm,
              'dropoffRadiusKm': dropoffRadiusKm,
            }),
          )
          .timeout(ApiConfig.connectTimeout);
          
      print('📥 Response status: ${resp.statusCode}');
      
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final List data = jsonDecode(resp.body) as List;
        print('✅ Found ${data.length} matching routes');
        return data.map((e) => ScheduledRide.fromJson(e)).toList();
      }
      throw Exception('Failed to route match (${resp.statusCode})');
    } catch (e) {
      print('❌ Error in route match: $e');
      rethrow;
    }
  }

  Future<List<ScheduledRide>> getNearbyDropoffRides({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      final url = ApiConfig.getNearbyDropoffRides(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      print('🔍 Fetching nearby dropoff rides from: $url');
      
      final resp = await http.get(Uri.parse(url)).timeout(ApiConfig.connectTimeout);
      print('📥 Response status: ${resp.statusCode}');
      
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final List data = jsonDecode(resp.body) as List;
        print('✅ Found ${data.length} nearby dropoff rides');
        return data.map((e) => ScheduledRide.fromJson(e)).toList();
      }
      throw Exception('Failed to load nearby dropoff rides (${resp.statusCode})');
    } catch (e) {
      print('❌ Error fetching nearby dropoff rides: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> assignDriver({
    required String rideId,
    required String driverId,
  }) async {
    try {
      final url = ApiConfig.assignDriverToScheduledRide(
        rideId: rideId,
        driverId: driverId,
      );
      print('🌐 Assigning driver - POST: $url');
      
      final resp = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 45));
      
      print('📡 Assign driver response status: ${resp.statusCode}');
      print('📡 Assign driver response body: ${resp.body}');
      
      final Map<String, dynamic> body =
          resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      return {
        'statusCode': resp.statusCode,
        'data': body,
        'success': resp.statusCode >= 200 && resp.statusCode < 300,
      };
    } catch (e) {
      print('❌ Error in assignDriver service: $e');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
        'success': false,
      };
    }
  }

  Future<Map<String, dynamic>> removeDriver({
    required String rideId,
  }) async {
    final url = ApiConfig.removeDriverFromScheduledRide(rideId);
    final resp = await http.delete(Uri.parse(url));
    final Map<String, dynamic> body =
        resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
    return {
      'statusCode': resp.statusCode,
      'data': body,
      'success': resp.statusCode >= 200 && resp.statusCode < 300,
    };
  }

  Future<Map<String, dynamic>> updateRideStatus({
    required String rideId,
    required String status,
  }) async {
    try {
      final url = ApiConfig.updateScheduledRideStatus(rideId);
      print('🌐 Updating ride status - PUT: $url');
      print('📝 Status: $status');
      
      final resp = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      ).timeout(const Duration(seconds: 45));
      
      print('📡 Update status response: ${resp.statusCode}');
      print('📡 Response body: ${resp.body}');
      
      final Map<String, dynamic> body =
          resp.body.isNotEmpty ? jsonDecode(resp.body) : {};
      return {
        'statusCode': resp.statusCode,
        'data': body,
        'success': resp.statusCode >= 200 && resp.statusCode < 300,
      };
    } catch (e) {
      print('❌ Error updating ride status: $e');
      return {
        'statusCode': 500,
        'data': {'error': e.toString()},
        'success': false,
      };
    }
  }

  Future<DriverCardModel> getDriverCard(String driverId) async {
    final url = ApiConfig.getDriverCard(driverId);
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return DriverCardModel.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to load driver card');
  }

  Future<RiderCardModel> getRiderCard(String riderId) async {
    final url = ApiConfig.getRiderCard(riderId);
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return RiderCardModel.fromJson(jsonDecode(resp.body));
    }
    throw Exception('Failed to load rider card');
  }
}
