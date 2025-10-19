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
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

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
    _accessToken = accessToken;

    print('🔗 Connecting WebSocket for driver: $driverId');

    // ✅ Keep HTTP protocol for SockJS (library converts to ws:// internally)
    final wsUrl = '${ApiConfig.webSocketUrl}/ride-service/ws/ride-tracking';

    print('🌐 WebSocket URL: $wsUrl');

    try {
      _stompClient = StompClient(
        config: StompConfig(
          url: wsUrl, // ✅ Use HTTP URL with SockJS
          
          onConnect: (StompFrame frame) {
            print('✅ WebSocket connected successfully');
            _isConnected = true;
            _isConnecting = false;
            _reconnectAttempts = 0;
            _connectionController.add(true);
            _subscribeToChannels(driverId);
          },
          
          onWebSocketError: (dynamic error) {
            print('❌ WebSocket error: $error');
            _isConnected = false;
            _isConnecting = false;
            _connectionController.add(false);

            if (_reconnectAttempts < _maxReconnectAttempts) {
              _scheduleReconnect(driverId, accessToken);
            } else {
              print('❌ Max reconnection attempts reached');
            }
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
          
          // ✅ Authentication headers
          webSocketConnectHeaders: {
            'Authorization': 'Bearer $accessToken',
          },
          
          stompConnectHeaders: {
            'Authorization': 'Bearer $accessToken',
            'driver-id': driverId,
          },
          
          // ✅ MUST use SockJS for Spring Boot WebSocket
          useSockJS: true,
          
          // Connection settings
          connectionTimeout: const Duration(seconds: 30),
          heartbeatIncoming: const Duration(seconds: 10),
          heartbeatOutgoing: const Duration(seconds: 10),
          
          beforeConnect: () async {
            print('🔄 Preparing to connect WebSocket...');
          },
        ),
      );

      _stompClient!.activate();
    } catch (e) {
      print('❌ Error creating WebSocket connection: $e');
      _isConnected = false;
      _isConnecting = false;
      _connectionController.add(false);
      
      if (_reconnectAttempts < _maxReconnectAttempts) {
        _scheduleReconnect(driverId, accessToken);
      }
    }
  }

  void _subscribeToChannels(String driverId) {
    if (_stompClient == null || !_isConnected) {
      print('⚠️ Cannot subscribe - not connected');
      return;
    }

    try {
      // Subscribe to ride requests for this driver
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

      // Subscribe to ride updates
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
    } catch (e) {
      print('❌ Error subscribing to channels: $e');
    }
  }

  void subscribeToGeographicalChannels(
    String driverId,
    double latitude,
    double longitude,
  ) {
    if (_stompClient == null || !_isConnected) {
      print('⚠️ Cannot subscribe to geo channels - not connected');
      return;
    }

    try {
      _stompClient!.send(
        destination: '/app/pubsub/driver/subscribe',
        body: jsonEncode({
          'driverId': driverId,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      print('📍 Subscribed to geo channels at: $latitude, $longitude');
    } catch (e) {
      print('❌ Error subscribing to geo channels: $e');
    }
  }

  void updateDriverLocation(
    String driverId,
    double latitude,
    double longitude,
    bool isAvailable,
  ) {
    if (_stompClient == null || !_isConnected) {
      print('⚠️ Cannot update location - not connected');
      return;
    }

    try {
      _stompClient!.send(
        destination: '/app/pubsub/driver/location',
        body: jsonEncode({
          'driverId': driverId,
          'latitude': latitude,
          'longitude': longitude,
          'isAvailable': isAvailable,
        }),
      );
    } catch (e) {
      print('❌ Error updating location: $e');
    }
  }

  void acceptRideRequest(String requestId, String driverId, String riderId) {
    if (_stompClient == null || !_isConnected) {
      print('⚠️ Cannot accept ride - not connected');
      return;
    }

    try {
      _stompClient!.send(
        destination: '/app/pubsub/ride/accept',
        body: jsonEncode({
          'requestId': requestId,
          'driverId': driverId,
          'riderId': riderId,
        }),
      );

      print('✅ Sent ride acceptance for request: $requestId');
    } catch (e) {
      print('❌ Error accepting ride: $e');
    }
  }

  void declineRideRequest(String requestId, String driverId, String reason) {
    if (_stompClient == null || !_isConnected) {
      print('⚠️ Cannot decline ride - not connected');
      return;
    }

    try {
      _stompClient!.send(
        destination: '/app/pubsub/ride/reject',
        body: jsonEncode({
          'requestId': requestId,
          'driverId': driverId,
          'reason': reason,
        }),
      );

      print('❌ Sent ride rejection for request: $requestId');
    } catch (e) {
      print('❌ Error declining ride: $e');
    }
  }

  void sendHeartbeat(String driverId) {
    if (_stompClient == null || !_isConnected) return;

    try {
      _stompClient!.send(
        destination: '/app/driver/heartbeat',
        body: jsonEncode({
          'driverId': driverId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );
    } catch (e) {
      print('❌ Error sending heartbeat: $e');
    }
  }

  void unsubscribeFromGeographicalChannels(String driverId) {
    if (_stompClient == null || !_isConnected) return;

    try {
      _stompClient!.send(
        destination: '/app/pubsub/driver/unsubscribe',
        body: jsonEncode({'driverId': driverId}),
      );

      print('🔇 Unsubscribed from geo channels');
    } catch (e) {
      print('❌ Error unsubscribing: $e');
    }
  }

  Timer? _reconnectTimer;

  void _scheduleReconnect(String driverId, String accessToken) {
    _reconnectTimer?.cancel();
    
    _reconnectAttempts++;
    final delay = Duration(seconds: 5 * _reconnectAttempts);
    
    print('🔄 Scheduling reconnection attempt $_reconnectAttempts in ${delay.inSeconds}s...');
    
    _reconnectTimer = Timer(delay, () {
      if (!_isConnected && _reconnectAttempts <= _maxReconnectAttempts) {
        print('🔄 Attempting to reconnect WebSocket (attempt $_reconnectAttempts/$_maxReconnectAttempts)...');
        connect(driverId, accessToken);
      }
    });
  }

  void resetReconnectionAttempts() {
    _reconnectAttempts = 0;
  }

  Future<void> disconnect() async {
    print('🔌 Disconnecting WebSocket...');

    _reconnectTimer?.cancel();
    _isConnecting = false;
    _reconnectAttempts = 0;

    if (_currentDriverId != null) {
      unsubscribeFromGeographicalChannels(_currentDriverId!);
    }

    if (_stompClient != null) {
      try {
        _stompClient!.deactivate();
      } catch (e) {
        print('⚠️ Error during deactivation: $e');
      }
      _stompClient = null;
    }

    _isConnected = false;
    _currentDriverId = null;
    _accessToken = null;
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