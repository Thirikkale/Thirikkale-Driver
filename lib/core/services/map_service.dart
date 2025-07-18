import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:thirikkale_driver/config/env_config.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';

class MapService {
  static const String _directionsBaseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';

  /// Create a marker for current location
  static Marker createCurrentLocationMarker(LatLng position) {
    return Marker(
      markerId: const MarkerId('current_location'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'Your Location'),
    );
  }

  /// Create a marker for destination
  static Marker createDestinationMarker(LatLng position, String title) {
    return Marker(
      markerId: const MarkerId('destination'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: title),
    );
  }

  /// Create a polyline between two points using Google Directions API
  static Future<Polyline?> createRoutePolyline(LatLng start, LatLng end) async {
    try {
      final directions = await getDirections(start, end);
      if (directions != null && directions['routes'].isNotEmpty) {
        final route = directions['routes'][0];
        final polylinePoints = route['overview_polyline']['points'];

        final List<LatLng> decodedPoints = _decodePolyline(polylinePoints);

        return Polyline(
          polylineId: const PolylineId('route'),
          points: decodedPoints,
          color: AppColors.primaryBlue,
          width: 4,
          patterns: [], // Solid line instead of dashed
        );
      }
    } catch (e) {
      print('Error creating route polyline: $e');
      // Fallback to simple straight line
      return Polyline(
        polylineId: const PolylineId('route'),
        points: [start, end],
        color: AppColors.primaryBlue,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      );
    }
    return null;
  }

  /// Get directions from Google Directions API
  static Future<Map<String, dynamic>?> getDirections(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      final apiKey = EnvConfig.googleMapsApiKey;
      if (apiKey.isEmpty) {
        throw Exception('Google Maps API key not configured');
      }

      final url = Uri.parse(_directionsBaseUrl).replace(
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'key': apiKey,
          'mode': 'driving',
          'traffic_model': 'best_guess',
          'departure_time': 'now',
        },
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['status'] == 'OK') {
          return json;
        } else {
          throw Exception('Directions API error: ${json['status']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting directions: $e');
      return null;
    }
  }

  /// Decode polyline points from Google's encoded format
  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  /// Get route information (distance, duration)
  static Map<String, dynamic>? getRouteInfo(Map<String, dynamic> directions) {
    if (directions['routes'].isEmpty) return null;

    final route = directions['routes'][0];
    final leg = route['legs'][0];

    return {
      'distance': leg['distance']['text'],
      'duration': leg['duration']['text'],
      'distance_value': leg['distance']['value'], // in meters
      'duration_value': leg['duration']['value'], // in seconds
    };
  }

  /// Calculate bounds for two locations
  static LatLngBounds calculateBounds(LatLng location1, LatLng location2) {
    return LatLngBounds(
      southwest: LatLng(
        location1.latitude < location2.latitude
            ? location1.latitude
            : location2.latitude,
        location1.longitude < location2.longitude
            ? location1.longitude
            : location2.longitude,
      ),
      northeast: LatLng(
        location1.latitude > location2.latitude
            ? location1.latitude
            : location2.latitude,
        location1.longitude > location2.longitude
            ? location1.longitude
            : location2.longitude,
      ),
    );
  }

  /// Animate camera to position
  static Future<void> animateToPosition(
    GoogleMapController controller,
    LatLng position, {
    double zoom = 14,
  }) async {
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: zoom),
      ),
    );
  }

  /// Animate camera to show bounds
  static Future<void> animateToBounds(
    GoogleMapController controller,
    LatLngBounds bounds, {
    double padding = 100,
  }) async {
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, padding),
    );
  }
}
