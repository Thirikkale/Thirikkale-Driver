import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';

class MapService {
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

  /// Create a polyline between two points
  static Polyline createRoutePolyline(LatLng start, LatLng end) {
    return Polyline(
      polylineId: const PolylineId('route'),
      points: [start, end],
      color: AppColors.primaryBlue,
      width: 4,
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
    );
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
