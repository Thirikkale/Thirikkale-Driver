import 'dart:async';

import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/provider/auth_provider.dart';
import 'package:thirikkale_driver/core/services/ride_request_api_service.dart';
import 'package:thirikkale_driver/core/services/web_socket_service.dart';
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
  final WebSocketService _webSocketService = WebSocketService();

  AuthProvider? _authProvider;

  Stream<RideRequest> get rideRequestStream =>
      _webSocketService.rideRequestStream;

  RideRequest? _currentRideRequest;
  RideStatus _rideStatus = RideStatus.idle;
  List<RideRequest> _pendingRideRequests = [];
  StreamSubscription<RideRequest>? _rideRequestSubscription;
  StreamSubscription<Map<String, dynamic>>? _rideUpdateSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  bool _isConnected = false;

  void update(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  // Getters
  RideRequest? get currentRideRequest => _currentRideRequest;
  RideStatus get rideStatus => _rideStatus;
  List<RideRequest> get pendingRideRequests => _pendingRideRequests;
  bool get hasActiveRide => _currentRideRequest != null;
  bool get isConnected => _isConnected;
  bool get isRideAccepted =>
      _rideStatus == RideStatus.accepted ||
      _rideStatus == RideStatus.enRouteToPickup ||
      _rideStatus == RideStatus.arrivedAtPickup ||
      _rideStatus == RideStatus.rideStarted;

  bool _isAcceptingRide = false;
  bool get isAcceptingRide => _isAcceptingRide;

  String? _lastAcceptanceError;
  String? get lastAcceptanceError => _lastAcceptanceError;

  // // Start listening for ride requests
  // Future<void> startListeningForRideRequests(
  //   String driverId,
  //   String accessToken,
  // ) async {
  //   print('🔊 RideProvider: Starting to listen for ride requests');

  //   try {
  //     await _rideRequestApiService.startListeningForRideRequests(
  //       driverId,
  //       accessToken,
  //     );

  //     _rideRequestSubscription = _rideRequestApiService.rideRequestStream
  //         ?.listen(
  //           (rideRequests) {
  //             print(
  //               '📨 RideProvider: Received ${rideRequests.length} ride requests',
  //             );
  //             _pendingRideRequests = rideRequests;

  //             // Show the first pending request if we don't have an active ride
  //             if (rideRequests.isNotEmpty && !hasActiveRide) {
  //               _handleNewRideRequest(rideRequests.first);
  //             }

  //             notifyListeners();
  //           },
  //           onError: (error) {
  //             print('❌ RideProvider: Error in ride request stream: $error');
  //           },
  //         );
  //   } catch (e) {
  //     print('❌ RideProvider: Error starting ride request listener: $e');
  //   }
  // }

  // Start listening for ride requests via WebSocket
  Future<void> startListeningForRideRequests(
    String driverId,
    String accessToken,
  ) async {
    print('🔊 RideProvider: Starting WebSocket ride request listener');

    // Connect WebSocket
    await _webSocketService.connect(driverId, accessToken);

    // ✅ Set up stream listener
    _webSocketService.rideRequestStream.listen(
      (rideRequest) {
        print(
          '🔔🔔🔔 RIDE PROVIDER: Received ride request: ${rideRequest.rideId}',
        );
        _currentRideRequest = rideRequest;
        _rideStatus = RideStatus.requestReceived;
        notifyListeners();
      },
      onError: (error) {
        print('❌❌❌ RIDE PROVIDER: Stream error: $error');
      },
    );
  }

  // Subscribe to geographical channels for ride requests
  void subscribeToLocation(String driverId, double latitude, double longitude) {
    _webSocketService.subscribeToGeographicalChannels(
      driverId,
      latitude,
      longitude,
    );
  }

  // Update driver location for pub/sub
  void updateDriverLocation(
    String driverId,
    double latitude,
    double longitude,
    bool isAvailable,
  ) {
    _webSocketService.updateDriverLocation(
      driverId,
      latitude,
      longitude,
      isAvailable,
    );
  }

  // Stop listening for ride requests
  void stopListeningForRideRequests() {
    print('🔇 RideProvider: Stopping ride request listener');
    _rideRequestSubscription?.cancel();
    _rideUpdateSubscription?.cancel();
    _connectionSubscription?.cancel();
    _rideRequestSubscription = null;
    _rideUpdateSubscription = null;
    _connectionSubscription = null;
    _pendingRideRequests.clear();
    _webSocketService.disconnect();
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
    } else {
      // Add to pending if we have an active ride
      _pendingRideRequests.add(rideRequest);
      notifyListeners();
    }
  }

  // Handle ride updates
  void _handleRideUpdate(Map<String, dynamic> update) {
    final status = update['status'];
    final requestId = update['requestId'];

    if (requestId == _currentRideRequest?.rideId) {
      switch (status) {
        case 'ACCEPTED':
          _rideStatus = RideStatus.accepted;
          break;
        case 'CANCELLED':
          _currentRideRequest = null;
          _rideStatus = RideStatus.idle;
          break;
        // Add other status handlers as needed
      }
      notifyListeners();
    }
  }

  void clearAcceptanceError() {
    _lastAcceptanceError = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> acceptRideWithDetails(
    String driverId,
    String accessToken,
  ) async {
    if (_currentRideRequest == null) {
      return {
        'success': false,
        'error': 'No ride request available',
        'code': 'NO_REQUEST',
      };
    }

    if (_isAcceptingRide) {
      return {
        'success': false,
        'error': 'Already processing a ride acceptance',
        'code': 'ALREADY_PROCESSING',
      };
    }

    _isAcceptingRide = true;
    _lastAcceptanceError = null;
    notifyListeners();

    try {
      print(
        '✅ RideProvider: Accepting ride via API: ${_currentRideRequest!.rideId}',
      );

      // Send acceptance via WebSocket for immediate feedback
      _webSocketService.acceptRideRequest(
        _currentRideRequest!.rideId,
        driverId,
        _currentRideRequest!.riderId,
      );

      // Call the HTTP API for confirmation
      final result = await _rideRequestApiService.acceptRideRequest(
        _currentRideRequest!.rideId,
        driverId,
        accessToken,
      );

      _isAcceptingRide = false;

      if (result['success'] == true) {
        _rideStatus = RideStatus.accepted;
        // Remove this request from pending list
        _pendingRideRequests.removeWhere(
          (r) => r.rideId == _currentRideRequest!.rideId,
        );
        notifyListeners();

        return {
          'success': true,
          'message': 'Ride accepted successfully!',
          'data': result['data'],
        };
      } else {
        // Handle different error cases
        final errorCode = result['code'];
        _lastAcceptanceError = result['error'];

        if (errorCode == 'RIDE_ALREADY_ACCEPTED') {
          // Clear the current ride request as it's no longer available
          _currentRideRequest = null;
          _rideStatus = RideStatus.idle;
        }

        notifyListeners();
        return result;
      }
    } catch (e) {
      print('❌ RideProvider: Error accepting ride: $e');
      _isAcceptingRide = false;
      _lastAcceptanceError = 'An unexpected error occurred';
      notifyListeners();

      return {
        'success': false,
        'error': 'An unexpected error occurred',
        'code': 'EXCEPTION',
      };
    }
  }

  // Keep the old method for backward compatibility
  Future<bool> acceptRide(String driverId, String accessToken) async {
    final result = await acceptRideWithDetails(driverId, accessToken);
    return result['success'] == true;
  }

  // Decline ride request via WebSocket
  Future<void> cancelRide([
    String? reason,
    String? driverId,
    String? accessToken,
  ]) async {
    if (_currentRideRequest != null && driverId != null) {
      try {
        print(
          '❌ RideProvider: Declining ride via WebSocket: ${_currentRideRequest!.rideId}',
        );

        // Send rejection via WebSocket
        _webSocketService.declineRideRequest(
          _currentRideRequest!.rideId,
          driverId,
          reason ?? 'Driver declined',
        );

        // Also call HTTP API as backup
        if (accessToken != null) {
          await _rideRequestApiService.cancelRideRequest(
            _currentRideRequest!.rideId,
            driverId,
            accessToken,
            reason,
          );
        }
      } catch (e) {
        print('❌ RideProvider: Error declining ride: $e');
      }
    }

    _currentRideRequest = null;
    _rideStatus = RideStatus.idle;
    notifyListeners();
  }

  // Send heartbeat
  void sendHeartbeat(String driverId) {
    _webSocketService.sendHeartbeat(driverId);
  }

  // Manually set a ride request (for testing or direct assignment)
  void setRideRequest(RideRequest rideRequest) {
    _currentRideRequest = rideRequest;
    _rideStatus = RideStatus.requestReceived;
    notifyListeners();
  }

  // // Accept ride request
  // Future<bool> acceptRide(String driverId, String accessToken) async {
  //   if (_currentRideRequest == null) return false;

  //   try {
  //     print('✅ RideProvider: Accepting ride ${_currentRideRequest!.rideId}');

  //     final result = await _rideRequestApiService.acceptRideRequest(
  //       _currentRideRequest!.rideId,
  //       driverId,
  //       accessToken,
  //     );

  //     if (result['success'] == true) {
  //       _rideStatus = RideStatus.accepted;
  //       // Remove this request from pending list
  //       _pendingRideRequests.removeWhere(
  //         (r) => r.rideId == _currentRideRequest!.rideId,
  //       );
  //       notifyListeners();
  //       return true;
  //     } else {
  //       print('❌ RideProvider: Failed to accept ride: ${result['error']}');
  //       return false;
  //     }
  //   } catch (e) {
  //     print('❌ RideProvider: Error accepting ride: $e');
  //     return false;
  //   }
  // }

  // // Cancel ride request (updated method name and endpoint)
  // Future<void> cancelRide([
  //   String? reason,
  //   String? driverId,
  //   String? accessToken,
  // ]) async {
  //   if (_currentRideRequest != null &&
  //       driverId != null &&
  //       accessToken != null) {
  //     try {
  //       print('❌ RideProvider: Canceling ride ${_currentRideRequest!.rideId}');

  //       await _rideRequestApiService.cancelRideRequest(
  //         _currentRideRequest!.rideId,
  //         driverId,
  //         accessToken,
  //         reason,
  //       );
  //     } catch (e) {
  //       print('❌ RideProvider: Error canceling ride: $e');
  //     }
  //   }

  //   _currentRideRequest = null;
  //   _rideStatus = RideStatus.idle;
  //   notifyListeners();
  // }

  // // Keep the old method for backward compatibility
  // Future<void> declineRide([
  //   String? reason,
  //   String? driverId,
  //   String? accessToken,
  // ]) async {
  //   await cancelRide(reason, driverId, accessToken);
  // }

  void startNavigation() {
    _rideStatus = RideStatus.enRouteToPickup;
    notifyListeners();
  }

  Future<void> arriveAtPickup(String driverId, String accessToken) async {
    if (_currentRideRequest == null) return;

    final accessToken =
        await _authProvider?.getCurrentToken(); // Fetch fresh token
    if (accessToken == null) {
      print("❌ Cannot mark arrived: Missing access token.");
      _lastAcceptanceError = 'Authentication error. Please login again.';
      notifyListeners();
      return;
    }

    try {
      final result = await _rideRequestApiService.driverArrived(
        _currentRideRequest!.rideId,
        accessToken,
      );

      if (result['success'] == true) {
        _rideStatus = RideStatus.arrivedAtPickup;
        print("✅ Driver marked as arrived on backend");
        notifyListeners();
      } else {
        print("❌ Failed to mark as arrived: ${result['error']}");
        // Optionally show an error to the driver
      }
    } catch (e) {
      print("❌ API call failed for arriveAtPickup: $e");
    }
  }

  // This method now calls the backend
  Future<void> startRide(String driverId, String accessToken) async {
    if (_currentRideRequest == null) return;

    final accessToken =
        await _authProvider?.getCurrentToken(); // Fetch fresh token
    if (accessToken == null) {
      print("❌ Cannot start ride: Missing access token.");
      _lastAcceptanceError = 'Authentication error. Please login again.';
      notifyListeners();
      return;
    }

    try {
      final result = await _rideRequestApiService.startRide(
        _currentRideRequest!.rideId,
        accessToken,
      );

      if (result['success'] == true) {
        _rideStatus = RideStatus.rideStarted;
        print("▶️ Ride started on backend");
        notifyListeners();
      } else {
        print("❌ Failed to start ride: ${result['error']}");
      }
    } catch (e) {
      print("❌ API call failed for startRide: $e");
    }
  }

  // This method now calls the backend
  Future<void> completeRide(String driverId, String accessToken) async {
    if (_currentRideRequest == null) return;

    final accessToken =
        await _authProvider?.getCurrentToken(); // Fetch fresh token
    if (accessToken == null) {
      print("❌ Cannot complete ride: Missing access token.");
      _lastAcceptanceError = 'Authentication error. Please login again.';
      notifyListeners();
      return;
    }

    try {
      // Use the fare from the ride request as the "actual fare"
      // In a real app, you might recalculate this based on actual distance/time
      final actualFare = _currentRideRequest!.fareAmount;

      final result = await _rideRequestApiService.completeRide(
        _currentRideRequest!.rideId,
        accessToken,
        actualFare,
      );

      if (result['success'] == true) {
        _currentRideRequest = null;
        _rideStatus = RideStatus.idle;
        print("🏁 Ride completed on backend");
        notifyListeners();
      } else {
        print("❌ Failed to complete ride: ${result['error']}");
      }
    } catch (e) {
      print("❌ API call failed for completeRide: $e");
    }
  }

  @override
  void dispose() {
    stopListeningForRideRequests();
    _rideRequestApiService.dispose();
    _webSocketService.dispose();
    super.dispose();
  }
}
