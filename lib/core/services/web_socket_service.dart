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

    final wsUrl = '${ApiConfig.webSocketUrl}/ride-service/ws/ride-tracking';
    print('🌐 WebSocket URL: $wsUrl');

    try {
      _stompClient = StompClient(
        config: StompConfig(
          url: wsUrl,

          onConnect: (StompFrame frame) {
            print('✅✅✅ FLUTTER: WebSocket connected successfully');
            print('✅✅✅ FLUTTER: Connection frame: ${frame.command}');
            print('✅✅✅ FLUTTER: Connection headers: ${frame.headers}');
            _isConnected = true;
            _isConnecting = false;
            _reconnectAttempts = 0;
            _connectionController.add(true);

            // ✅ Add delay before subscribing
            Future.delayed(const Duration(milliseconds: 500), () {
              print('✅✅✅ FLUTTER: Now subscribing to channels...');
              _subscribeToChannels(driverId);
            });
          },

          onWebSocketError: (dynamic error) {
            print('❌❌❌ FLUTTER: WebSocket error: $error');
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
            print('❌❌❌ FLUTTER: STOMP error: ${frame.body}');
            print('❌❌❌ FLUTTER: STOMP error headers: ${frame.headers}');
            print('❌❌❌ FLUTTER: STOMP error command: ${frame.command}');
            _isConnected = false;
            _isConnecting = false;
            _connectionController.add(false);
          },

          onDisconnect: (StompFrame frame) {
            print('🔌 WebSocket disconnected');
            print('🔌 Disconnect frame: ${frame.body}');
            _isConnected = false;
            _isConnecting = false;
            _connectionController.add(false);
          },

          // ✅✅✅ CRITICAL: HTTP headers for WebSocket upgrade
          webSocketConnectHeaders: {'Authorization': 'Bearer $accessToken'},

          // ✅✅✅ CRITICAL: STOMP CONNECT headers for authentication
          stompConnectHeaders: {
            'Authorization': 'Bearer $accessToken',
            'driver-id': driverId,
            'login': driverId, // ✅ Some STOMP brokers need this
            'passcode': accessToken, // ✅ Some STOMP brokers need this
          },

          useSockJS: true,
          connectionTimeout: const Duration(seconds: 30),
          heartbeatIncoming: const Duration(seconds: 10),
          heartbeatOutgoing: const Duration(seconds: 10),

          beforeConnect: () async {
            print('🔄 Preparing to connect WebSocket...');
            print('🔑 Using access token: ${accessToken.substring(0, 20)}...');
            print('👤 Driver ID: $driverId');
          },
        ),
      );

      _stompClient!.activate();
    } catch (e, stackTrace) {
      print('❌❌❌ FLUTTER: Error creating WebSocket connection: $e');
      print('❌❌❌ FLUTTER: Stack trace: $stackTrace');
      _isConnected = false;
      _isConnecting = false;
      _connectionController.add(false);

      if (_reconnectAttempts < _maxReconnectAttempts) {
        _scheduleReconnect(driverId, accessToken);
      }
    }
  }

  void sendActiveRideLocation({
    required String rideId,
    required double latitude,
    required double longitude,
  }) {
    if (_stompClient == null || !_isConnected) {
      print('❌ Cannot send active ride location: Not connected');
      return;
    }

    // This is the new destination for in-ride tracking
    final destination = '/app/ride/$rideId/location';
    print('📍 Sending active ride location to: $destination');

    _stompClient!.send(
      destination: destination,
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'isAvailable': false, // Driver is busy on a ride
      }),
    );
  }

  void _subscribeToChannels(String driverId) {
    if (_stompClient == null || !_isConnected) {
      print('⚠️ Cannot subscribe - not connected');
      return;
    }

    try {
      print('🔔 Subscribing to channels for driver: $driverId');

      // ✅ Subscribe to pub/sub ride requests (PRIMARY - This is what backend sends to)
      _stompClient!.subscribe(
        destination: '/user/$driverId/queue/pubsub-ride-requests',
        callback: (StompFrame frame) {
          print('📨📨📨 FLUTTER: RAW MESSAGE RECEIVED on pubsub-ride-requests');
          print('📨📨📨 FLUTTER: Frame body: ${frame.body}');
          print('📨📨📨 FLUTTER: Frame command: ${frame.command}');
          print('📨📨📨 FLUTTER: Frame headers: ${frame.headers}');

          if (frame.body != null) {
            try {
              final data = jsonDecode(frame.body!);
              print('📨📨📨 FLUTTER: Parsed data: $data');

              // Check if this is a ride request
              if (data['requestId'] != null) {
                final rideRequest = RideRequest.fromBackendJson(data);
                print(
                  '📨📨📨 FLUTTER: Created RideRequest object: ${rideRequest.rideId}',
                );
                print('📨📨📨 FLUTTER: About to add to stream controller');
                _rideRequestController.add(rideRequest);
                print(
                  '📨📨📨 FLUTTER: Successfully added to stream controller',
                );
              } else {
                print(
                  '⚠️⚠️⚠️ FLUTTER: No requestId in data, treating as update',
                );
                _rideUpdateController.add(data);
              }
            } catch (e, stackTrace) {
              print('❌❌❌ FLUTTER: Error parsing pubsub ride request: $e');
              print('❌❌❌ FLUTTER: Stack trace: $stackTrace');
            }
          } else {
            print('⚠️⚠️⚠️ FLUTTER: Frame body is null!');
          }
        },
      );

      // ✅ Subscribe to direct ride requests (BACKUP)
      _stompClient!.subscribe(
        destination: '/user/$driverId/queue/ride-requests',
        callback: (StompFrame frame) {
          print('📨 FLUTTER BACKUP: Received on ride-requests');
          if (frame.body != null) {
            try {
              final data = jsonDecode(frame.body!);
              final rideRequest = RideRequest.fromBackendJson(data);
              print(
                '📨 FLUTTER BACKUP: Parsed ride request: ${rideRequest.rideId}',
              );
              _rideRequestController.add(rideRequest);
            } catch (e) {
              print('❌ FLUTTER BACKUP: Parse error: $e');
            }
          }
        },
      );

      // ✅ Subscribe to ride updates
      _stompClient!.subscribe(
        destination: '/user/$driverId/queue/ride-updates',
        callback: (StompFrame frame) {
          print('📨 FLUTTER: Received ride update');
          if (frame.body != null) {
            try {
              final data = jsonDecode(frame.body!);
              _rideUpdateController.add(data);
            } catch (e) {
              print('❌ FLUTTER: Error parsing ride update: $e');
            }
          }
        },
      );

      print(
        '🔔🔔🔔 FLUTTER: Subscribed to ALL WebSocket channels for driver: $driverId',
      );
    } catch (e, stackTrace) {
      print('❌❌❌ FLUTTER: Error subscribing to channels: $e');
      print('❌❌❌ FLUTTER: Stack trace: $stackTrace');
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

    print(
      '🔄 Scheduling reconnection attempt $_reconnectAttempts in ${delay.inSeconds}s...',
    );

    _reconnectTimer = Timer(delay, () {
      if (!_isConnected && _reconnectAttempts <= _maxReconnectAttempts) {
        print(
          '🔄 Attempting to reconnect WebSocket (attempt $_reconnectAttempts/$_maxReconnectAttempts)...',
        );
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
