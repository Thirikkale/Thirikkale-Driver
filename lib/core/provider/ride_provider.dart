import 'dart:async';

import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/services/ride_request_api_service.dart';
import 'package:thirikkale_driver/features/home/models/ride_request_model.dart';

enum RideStatus {
  idle,
  requestReceived,
  accepted,
  enRouteToPickup,
  arrivedAtPickup,
  rideStarted,
  completed,
}

class RideProvider extends ChangeNotifier {
  final RideRequestApiService _rideRequestApiService = RideRequestApiService();

  RideRequest? _currentRideRequest;
  RideStatus _rideStatus = RideStatus.idle;
  List<RideRequest> _pendingRideRequests = [];
  StreamSubscription<List<RideRequest>>? _rideRequestSubscription;

  // Getters
  RideRequest? get currentRideRequest => _currentRideRequest;
  RideStatus get rideStatus => _rideStatus;
  List<RideRequest> get pendingRideRequests => _pendingRideRequests;
  bool get hasActiveRide => _currentRideRequest != null;
  bool get isRideAccepted =>
      _rideStatus == RideStatus.accepted ||
      _rideStatus == RideStatus.enRouteToPickup ||
      _rideStatus == RideStatus.arrivedAtPickup ||
      _rideStatus == RideStatus.rideStarted;

  // Start listening for ride requests
  Future<void> startListeningForRideRequests(
    String driverId,
    String accessToken,
  ) async {
    print('🔊 RideProvider: Starting to listen for ride requests');

    try {
      await _rideRequestApiService.startListeningForRideRequests(
        driverId,
        accessToken,
      );

      _rideRequestSubscription = _rideRequestApiService.rideRequestStream
          ?.listen(
            (rideRequests) {
              print(
                '📨 RideProvider: Received ${rideRequests.length} ride requests',
              );
              _pendingRideRequests = rideRequests;

              // Show the first pending request if we don't have an active ride
              if (rideRequests.isNotEmpty && !hasActiveRide) {
                _handleNewRideRequest(rideRequests.first);
              }

              notifyListeners();
            },
            onError: (error) {
              print('❌ RideProvider: Error in ride request stream: $error');
            },
          );
    } catch (e) {
      print('❌ RideProvider: Error starting ride request listener: $e');
    }
  }

  // Stop listening for ride requests
  void stopListeningForRideRequests() {
    print('🔇 RideProvider: Stopping ride request listener');
    _rideRequestSubscription?.cancel();
    _rideRequestSubscription = null;
    _rideRequestApiService.stopListeningForRideRequests();
    _pendingRideRequests.clear();
    notifyListeners();
  }

  // Handle new ride request
  void _handleNewRideRequest(RideRequest rideRequest) {
    if (_rideStatus == RideStatus.idle) {
      _currentRideRequest = rideRequest;
      _rideStatus = RideStatus.requestReceived;
      print(
        '🚗 RideProvider: New ride request received: ${rideRequest.rideId}',
      );
      notifyListeners();
    }
  }

  // Manually set a ride request (for testing or direct assignment)
  void setRideRequest(RideRequest rideRequest) {
    _currentRideRequest = rideRequest;
    _rideStatus = RideStatus.requestReceived;
    notifyListeners();
  }

  // Accept ride request
  Future<bool> acceptRide(String driverId, String accessToken) async {
    if (_currentRideRequest == null) return false;

    try {
      print('✅ RideProvider: Accepting ride ${_currentRideRequest!.rideId}');

      final result = await _rideRequestApiService.acceptRideRequest(
        _currentRideRequest!.rideId,
        driverId,
        accessToken,
      );

      if (result['success'] == true) {
        _rideStatus = RideStatus.accepted;
        // Remove this request from pending list
        _pendingRideRequests.removeWhere(
          (r) => r.rideId == _currentRideRequest!.rideId,
        );
        notifyListeners();
        return true;
      } else {
        print('❌ RideProvider: Failed to accept ride: ${result['error']}');
        return false;
      }
    } catch (e) {
      print('❌ RideProvider: Error accepting ride: $e');
      return false;
    }
  }

  // Cancel ride request (updated method name and endpoint)
  Future<void> cancelRide([
    String? reason,
    String? driverId,
    String? accessToken,
  ]) async {
    if (_currentRideRequest != null &&
        driverId != null &&
        accessToken != null) {
      try {
        print('❌ RideProvider: Canceling ride ${_currentRideRequest!.rideId}');

        await _rideRequestApiService.cancelRideRequest(
          _currentRideRequest!.rideId,
          driverId,
          accessToken,
          reason,
        );
      } catch (e) {
        print('❌ RideProvider: Error canceling ride: $e');
      }
    }

    _currentRideRequest = null;
    _rideStatus = RideStatus.idle;
    notifyListeners();
  }

  // Keep the old method for backward compatibility
  Future<void> declineRide([
    String? reason,
    String? driverId,
    String? accessToken,
  ]) async {
    await cancelRide(reason, driverId, accessToken);
  }

  void startNavigation() {
    _rideStatus = RideStatus.enRouteToPickup;
    notifyListeners();
  }

  void arriveAtPickup() {
    _rideStatus = RideStatus.arrivedAtPickup;
    notifyListeners();
  }

  void startRide() {
    _rideStatus = RideStatus.rideStarted;
    notifyListeners();
  }

  void completeRide() {
    _currentRideRequest = null;
    _rideStatus = RideStatus.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    stopListeningForRideRequests();
    _rideRequestApiService.dispose();
    super.dispose();
  }
}
