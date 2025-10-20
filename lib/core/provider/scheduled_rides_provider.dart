import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/provider/location_provider.dart';
import 'package:thirikkale_driver/core/services/scheduled_rides_service.dart';
import 'package:thirikkale_driver/features/scheduled_rides/models/scheduled_ride.dart';

class ScheduledRidesProvider extends ChangeNotifier {
  final ScheduledRidesService _service = ScheduledRidesService();

  // Tabs: 0=Accepted, 1=Nearby, 2=Route
  int _currentTab = 0;
  int get currentTab => _currentTab;
  void setTab(int index) {
    if (_currentTab != index) {
      _currentTab = index;
      notifyListeners();
    }
  }

  // Accepted rides list
  final List<ScheduledRide> _accepted = [];
  List<ScheduledRide> get accepted => List.unmodifiable(_accepted);
  bool _loadingAccepted = false;
  String? _acceptedError;
  bool get loadingAccepted => _loadingAccepted;
  String? get acceptedError => _acceptedError;

  // Nearby rides
  bool _loadingNearby = false;
  String? _nearbyError;
  final List<ScheduledRide> _nearby = [];
  bool get loadingNearby => _loadingNearby;
  String? get nearbyError => _nearbyError;
  List<ScheduledRide> get nearby => List.unmodifiable(_nearby);

  // Route match results
  bool _loadingRoute = false;
  String? _routeError;
  final List<ScheduledRide> _routeMatches = [];
  bool get loadingRoute => _loadingRoute;
  String? get routeError => _routeError;
  List<ScheduledRide> get routeMatches => List.unmodifiable(_routeMatches);

  // Fetch nearby using current location
  Future<void> fetchNearby(LocationProvider locationProvider, {double radiusKm = 10}) async {
    if (locationProvider.currentLatitude == null || locationProvider.currentLongitude == null) {
      _nearbyError = 'Current location unavailable';
      notifyListeners();
      return;
    }
    _loadingNearby = true;
    _nearbyError = null;
    notifyListeners();
    try {
      final rides = await _service.getNearbyRides(
        latitude: locationProvider.currentLatitude!,
        longitude: locationProvider.currentLongitude!,
        radiusKm: radiusKm,
      );
      _nearby
        ..clear()
        ..addAll(rides);
    } catch (e) {
      _nearbyError = e.toString();
    } finally {
      _loadingNearby = false;
      notifyListeners();
    }
  }

  // Fetch accepted rides by filtering nearby list for current driverId
  Future<void> fetchAccepted(LocationProvider locationProvider, String driverId, {double radiusKm = 25}) async {
    _loadingAccepted = true;
    _acceptedError = null;
    notifyListeners();
    try {
      // Try to reuse nearby if already loaded, otherwise fetch
      if (_nearby.isEmpty) {
        await fetchNearby(locationProvider, radiusKm: radiusKm);
      }
      final filtered = _nearby.where((r) => r.driverId == driverId).toList();
      _accepted
        ..clear()
        ..addAll(filtered);
    } catch (e) {
      _acceptedError = e.toString();
    } finally {
      _loadingAccepted = false;
      notifyListeners();
    }
  }

  // Route match
  Future<void> searchRoute({
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
    double pickupRadiusKm = 10,
    double dropoffRadiusKm = 10,
  }) async {
    _loadingRoute = true;
    _routeError = null;
    notifyListeners();
    try {
      final rides = await _service.routeMatch(
        pickupLatitude: pickupLat,
        pickupLongitude: pickupLng,
        dropoffLatitude: dropLat,
        dropoffLongitude: dropLng,
        pickupRadiusKm: pickupRadiusKm,
        dropoffRadiusKm: dropoffRadiusKm,
      );
      _routeMatches
        ..clear()
        ..addAll(rides);
    } catch (e) {
      _routeError = e.toString();
    } finally {
      _loadingRoute = false;
      notifyListeners();
    }
  }

  // Assign driver to ride
  Future<bool> assignDriver({required ScheduledRide ride, required String driverId}) async {
    try {
      print('🚗 Attempting to assign driver $driverId to ride ${ride.id}');
      final res = await _service.assignDriver(rideId: ride.id, driverId: driverId);
      print('📦 Assign driver response: $res');
      
      // If success, update accepted list (simplified)
      final ok = res['success'] == true;
      if (ok) {
        print('✅ Successfully assigned driver to ride');
        // Update local lists - create a copy with driverId set
        final updatedRide = ScheduledRide(
          id: ride.id,
          riderId: ride.riderId,
          driverId: driverId, // Set the driver ID
          pickupLatitude: ride.pickupLatitude,
          pickupLongitude: ride.pickupLongitude,
          pickupAddress: ride.pickupAddress,
          dropoffLatitude: ride.dropoffLatitude,
          dropoffLongitude: ride.dropoffLongitude,
          dropoffAddress: ride.dropoffAddress,
          scheduledTime: ride.scheduledTime,
          status: ride.status,
          passengers: ride.passengers,
          vehicleType: ride.vehicleType,
          rideType: ride.rideType,
          isSharedRide: ride.isSharedRide,
          maxFare: ride.maxFare,
          distanceKm: ride.distanceKm,
          isWomenOnly: ride.isWomenOnly,
        );
        
        _accepted.removeWhere((r) => r.id == ride.id);
        _accepted.add(updatedRide);
        _nearby.removeWhere((r) => r.id == ride.id);
        _routeMatches.removeWhere((r) => r.id == ride.id);
        notifyListeners();
      } else {
        print('❌ Failed to assign driver - response indicates failure');
      }
      return ok;
    } catch (e, stackTrace) {
      print('❌ Error assigning driver: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  // Remove driver
  Future<bool> removeDriver({required String rideId}) async {
    final res = await _service.removeDriver(rideId: rideId);
    final ok = res['success'] == true;
    if (ok) {
      _accepted.removeWhere((r) => r.id == rideId);
      notifyListeners();
    }
    return ok;
  }
}
