import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:thirikkale_driver/config/api_config.dart';
import 'package:thirikkale_driver/features/home/models/ride_request_model.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  StompClient? _stompClient;
  String? _currentDriverId;
  bool _isConnected = false;
  String? _accessToken;
  bool _isConnecting = false;

  // Stream controllers for different events
  final StreamController<RideRequest> _rideRequestController =
      StreamController<RideRequest>.broadcast();
  final StreamController<Map<String, dynamic>> _rideUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  // Getters for streams
  Stream<RideRequest> get rideRequestStream => _rideRequestController.stream;
  Stream<Map<String, dynamic>> get rideUpdateStream =>
      _rideUpdateController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  bool get isConnected => _isConnected;

  Future<void> connect(String driverId, String accessToken) async {
    if (_isConnecting) {
      print('🔄 Connection already in progress for driver: $driverId');
      return;
    }

    if (_isConnected && _currentDriverId == driverId) {
      print('🔗 Already connected for driver: $driverId');
      return;
    }

    _isConnecting = true;
    await disconnect();
    _currentDriverId = driverId;

    print('🔗 Connecting WebSocket for driver: $driverId');

    _accessToken = accessToken;

    final wsUrl = 'http://10.249.61.103:8082/ride-service/ws/ride-tracking';

    final wsUrlWithAuth = '$wsUrl?access_token=$accessToken';

    try {
      _stompClient = StompClient(
        config: StompConfig(
          url: wsUrlWithAuth,
          onConnect: (StompFrame frame) {
            print('✅ WebSocket connected successfully');
            _isConnected = true;
            _isConnecting = false;
            _connectionController.add(true);
            _subscribeToChannels(driverId);
          },
          onWebSocketError: (dynamic error) {
            print('❌ WebSocket error: $error');
            _isConnected = false;
            _isConnecting = false;
            _connectionController.add(false);

            // ✅ Add retry logic
            _scheduleReconnect(driverId, accessToken);
          },
          onStompError: (StompFrame frame) {
            print('❌ STOMP error: ${frame.body}');
            _isConnected = false;
            _isConnecting = false;
            _connectionController.add(false);
          },
          onDisconnect: (StompFrame frame) {
            print('🔌 WebSocket disconnected');
            _isConnected = false;
            _isConnecting = false;
            _connectionController.add(false);
          },
          webSocketConnectHeaders: {
            'Authorization': 'Bearer $accessToken',
            'User-ID': driverId,
          },
          useSockJS: true,
          connectionTimeout: const Duration(seconds: 10),
        ),
      );

      _stompClient!.activate();
    } catch (e) {
      print('❌ Error creating WebSocket connection: $e');
      _isConnected = false;
      _isConnecting = false;
      _connectionController.add(false);
    }
  }

  void _subscribeToChannels(String driverId) {
    if (_stompClient == null || !_isConnected) return;

    // Subscribe to ride request for this driver
    _stompClient!.subscribe(
      destination: '/user/$driverId/queue/ride-requests',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final data = jsonDecode(frame.body!);
            final rideRequest = RideRequest.fromBackendJson(data);
            print('📨 Received ride request: ${rideRequest.rideId}');
            _rideRequestController.add(rideRequest);
          } catch (e) {
            print('❌ Error parsing ride request: $e');
          }
        }
      },
    );

    // Subscribe to ride updates for this driver
    _stompClient!.subscribe(
      destination: '/user/$driverId/queue/ride-updates',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final data = jsonDecode(frame.body!);
            print('📨 Received ride update: $data');
            _rideUpdateController.add(data);
          } catch (e) {
            print('❌ Error parsing ride update: $e');
          }
        }
      },
    );

    // Subscribe to pub/sub ride requests
    _stompClient!.subscribe(
      destination: '/user/$driverId/queue/pubsub-ride-requests',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final data = jsonDecode(frame.body!);
            final rideRequest = RideRequest.fromBackendJson(data);
            print('📨 Received pub/sub ride request: ${rideRequest.rideId}');
            _rideRequestController.add(rideRequest);
          } catch (e) {
            print('❌ Error parsing pub/sub ride request: $e');
          }
        }
      },
    );

    print('🔔 Subscribed to WebSocket channels for driver: $driverId');
  }

  // Subscribe driver to geographical channels
  void subscribeToGeographicalChannels(
    String driverId,
    double latitude,
    double longitude,
  ) {
    if (_stompClient == null || !_isConnected) return;

    _stompClient!.send(
      destination: '/app/pubsub/driver/subscribe',
      body: jsonEncode({
        'driverId': driverId,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    print(
      '📍 Subscribed driver to geographical channels at: $latitude, $longitude',
    );
  }

  // Update driver location
  void updateDriverLocation(
    String driverId,
    double latitude,
    double longitude,
    bool isAvailable,
  ) {
    if (_stompClient == null || !_isConnected) return;

    _stompClient!.send(
      destination: '/app/pubsub/driver/location',
      body: jsonEncode({
        'driverId': driverId,
        'latitude': latitude,
        'longitude': longitude,
        'isAvailable': isAvailable,
      }),
    );
  }

  // Accept ride request
  void acceptRideRequest(String requestId, String driverId, String riderId) {
    if (_stompClient == null || !_isConnected) return;

    _stompClient!.send(
      destination: '/app/pubsub/ride/accept',
      body: jsonEncode({
        'requestId': requestId,
        'driverId': driverId,
        'riderId': riderId,
      }),
    );

    print('✅ Sent ride acceptance for request: $requestId');
  }

  // Decline ride request
  void declineRideRequest(String requestId, String driverId, String reason) {
    if (_stompClient == null || !_isConnected) return;

    _stompClient!.send(
      destination: '/app/pubsub/ride/reject',
      body: jsonEncode({
        'requestId': requestId,
        'driverId': driverId,
        'reason': reason,
      }),
    );

    print('❌ Sent ride rejection for request: $requestId');
  }

  // Send heartbeat
  void sendHeartbeat(String driverId) {
    if (_stompClient == null || !_isConnected) return;

    _stompClient!.send(
      destination: '/app/driver/heartbeat',
      body: jsonEncode({
        'driverId': driverId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }),
    );
  }

  // Unsubscribe from geographical channels
  void unsubscribeFromGeographicalChannels(String driverId) {
    if (_stompClient == null || !_isConnected) return;

    _stompClient!.send(
      destination: '/app/pubsub/driver/unsubscribe',
      body: jsonEncode({'driverId': driverId}),
    );

    print('🔇 Unsubscribed driver from geographical channels');
  }

  //  Add retry mechanism
  Timer? _reconnectTimer;

  void _scheduleReconnect(String driverId, String accessToken) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected) {
        print('🔄 Attempting to reconnect WebSocket...');
        connect(driverId, accessToken);
      }
    });
  }

  Future<void> disconnect() async {
    print('🔌 Disconnecting WebSocket...');

    // ✅ Cancel reconnection attempts
    _reconnectTimer?.cancel();
    _isConnecting = false;

    if (_currentDriverId != null) {
      unsubscribeFromGeographicalChannels(_currentDriverId!);
    }

    if (_stompClient != null) {
      _stompClient!.deactivate();
      _stompClient = null;
    }

    _isConnected = false;
    _currentDriverId = null;
    _connectionController.add(false);
    print('🔌 WebSocket disconnected completely');
  }

  void dispose() {
    disconnect();
    _rideRequestController.close();
    _rideUpdateController.close();
    _connectionController.close();
  }
}
