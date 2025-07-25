import 'package:flutter/material.dart';
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
  RideRequest? _currentRideRequest;
  RideStatus _rideStatus = RideStatus.idle;

  RideRequest? get currentRideRequest => _currentRideRequest;
  RideStatus get rideStatus => _rideStatus;

  bool get hasActiveRide => _currentRideRequest != null;
  bool get isRideAccepted =>
      _rideStatus == RideStatus.accepted ||
      _rideStatus == RideStatus.enRouteToPickup ||
      _rideStatus == RideStatus.arrivedAtPickup ||
      _rideStatus == RideStatus.rideStarted;

  void setRideRequest(RideRequest rideRequest) {
    _currentRideRequest = rideRequest;
    _rideStatus = RideStatus.requestReceived;
    notifyListeners();
  }

  void acceptRide() {
    if (_currentRideRequest != null) {
      _rideStatus = RideStatus.accepted;
      notifyListeners();
    }
  }

  void declineRide() {
    _currentRideRequest = null;
    _rideStatus = RideStatus.idle;
    notifyListeners();
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
}
