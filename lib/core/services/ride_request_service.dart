import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_driver/core/provider/auth_provider.dart';
import 'package:thirikkale_driver/core/provider/ride_provider.dart';
import 'package:thirikkale_driver/features/home/models/ride_request_model.dart';
import 'package:thirikkale_driver/features/home/widgets/ride_request_card.dart';

class RideRequestService {
  static final RideRequestService _instance = RideRequestService._internal();
  factory RideRequestService() => _instance;
  RideRequestService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  OverlayEntry? _overlayEntry;
  StreamSubscription? _rideRequestSubscription;
  Timer? _soundTimer;

  // Initialize the service
  Future<void> initialize() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    await _audioPlayer.setVolume(1.0);
  }

  // Show ride request overlay
  void showRideRequest(
    BuildContext context,
    RideRequest rideRequest,
    VoidCallback onAccept,
    VoidCallback onDecline,
  ) {
    _removeOverlay();
    _playNotificationSound();
    _vibrateDevice();

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Material(
            color: Colors.black.withOpacity(0.8),
            child: SafeArea(
              child: Center(
                child: RideRequestCard(
                  rideRequest: rideRequest,
                  onAccept: onAccept,
                  onDecline: onDecline,
                ),
              ),
            ),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // Hide ride request overlay
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _audioPlayer.stop();
    _soundTimer?.cancel();
    _soundTimer = null;
  }

  // Play notification sound with maximum volume and repeat
  Future<void> _playNotificationSound() async {
    try {
      // Set volume to maximum
      await _audioPlayer.setVolume(1.0);

      // Play the sound immediately
      await _audioPlayer.play(AssetSource('sounds/alert_sound_final.mp3'));

      // Repeat the sound every 3 seconds for 30 seconds (or until overlay is removed)
      _soundTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        if (_overlayEntry != null) {
          try {
            await _audioPlayer.play(
              AssetSource('sounds/alert_sound_final.mp3'),
            );
          } catch (e) {
            print('Error repeating notification sound: $e');
          }
        } else {
          timer.cancel();
        }
      });
    } catch (e) {
      print('Error playing notification sound: $e');
      // Fallback to system sound with vibration
      SystemSound.play(SystemSoundType.alert);

      // Repeat system sound as fallback
      _soundTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (_overlayEntry != null) {
          SystemSound.play(SystemSoundType.alert);
          HapticFeedback.heavyImpact();
        } else {
          timer.cancel();
        }
      });
    }
  }

  // Enhanced vibrate device with pattern
  void _vibrateDevice() {
    // Initial strong vibration
    HapticFeedback.heavyImpact();

    // Create a vibration pattern
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_overlayEntry != null && timer.tick < 10) {
        // Vibrate for 5 seconds
        HapticFeedback.mediumImpact();
      } else {
        timer.cancel();
      }
    });
  }

  // Handle accept action
  void _handleAccept(BuildContext context, RideRequest rideRequest) async {
    _removeOverlay();

    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final driverId = authProvider.userId;
    final accessToken = await authProvider.getCurrentToken();

    if (driverId != null && accessToken != null) {
      final success = await rideProvider.acceptRide(driverId, accessToken);
      if (success) {
        print('✅ Ride request accepted: ${rideRequest.rideId}');
      } else {
        print('❌ Failed to accept ride request: ${rideRequest.rideId}');
        // Could show an error message to the user here
      }
    }
  }

  // // Handle decline action
  // void _handleDecline(BuildContext context, RideRequest rideRequest) async {
  //   _removeOverlay();

  //   final rideProvider = Provider.of<RideProvider>(context, listen: false);
  //   final authProvider = Provider.of<AuthProvider>(context, listen: false);

  //   final driverId = authProvider.userId;
  //   final accessToken = await authProvider.getCurrentToken();

  //   await rideProvider.declineRide('Driver declined', driverId, accessToken);
  //   print('❌ Ride request declined: ${rideRequest.rideId}');
  // }

  // Generate dummy ride request for testing
  RideRequest generateDummyRideRequest() {
    // ... your existing dummy data generation code ...
    final random = Random();
    final riders = [
      {'name': 'John Doe', 'phone': '+94777123456'},
      {'name': 'Jane Smith', 'phone': '+94711234567'},
      {'name': 'Mike Johnson', 'phone': '+94701234567'},
      {'name': 'Sarah Wilson', 'phone': '+94751234567'},
    ];

    final pickupLocations = [
      {
        'address': 'Colombo Fort Railway Station, Colombo 01',
        'lat': 6.9344,
        'lng': 79.8428,
      },
      {
        'address': 'Galle Face Green, Colombo 03',
        'lat': 6.9197,
        'lng': 79.8467,
      },
      {
        'address': 'Independence Square, Colombo 07',
        'lat': 6.9074,
        'lng': 79.8687,
      },
      {'address': 'Nugegoda Junction, Nugegoda', 'lat': 6.8649, 'lng': 79.8997},
    ];

    final destinations = [
      {
        'address': 'Bandaranaike International Airport, Katunayake',
        'lat': 7.1808,
        'lng': 79.8841,
      },
      {
        'address': 'University of Colombo, Colombo 03',
        'lat': 6.9022,
        'lng': 79.8607,
      },
      {
        'address': 'Keells Super, Kandy Road, Malabe',
        'lat': 6.9147,
        'lng': 79.9729,
      },
      {
        'address': 'Mount Lavinia Hotel, Mount Lavinia',
        'lat': 6.8344,
        'lng': 79.8633,
      },
    ];

    final paymentMethods = ['Cash', 'Card', 'Wallet'];
    final specialInstructions = [
      'Please call when you arrive at the pickup location.',
      'I will be waiting near the main entrance.',
      'Look for someone wearing a red shirt.',
      null,
      'Please be on time, I have a flight to catch.',
    ];

    final rider = riders[random.nextInt(riders.length)];
    final pickup = pickupLocations[random.nextInt(pickupLocations.length)];
    final destination = destinations[random.nextInt(destinations.length)];
    final paymentMethod = paymentMethods[random.nextInt(paymentMethods.length)];
    final instruction =
        specialInstructions[random.nextInt(specialInstructions.length)];

    final distance = random.nextDouble() * 30 + 5;
    final estimatedTime = (distance * 2 + random.nextInt(20)).round();
    final baseFare = distance * 100;
    final fare = baseFare + random.nextInt(500);

    return RideRequest(
      rideId: 'RR${DateTime.now().millisecondsSinceEpoch}',
      riderId: 'rider_${random.nextInt(1000)}',
      riderName: rider['name']!,
      riderPhone: rider['phone']!,
      riderRating: 3.5 + random.nextDouble() * 1.5,
      pickupAddress: pickup['address'] as String,
      destinationAddress: destination['address'] as String,
      pickupLat: pickup['lat'] as double,
      pickupLng: pickup['lng'] as double,
      destinationLat: destination['lat'] as double,
      destinationLng: destination['lng'] as double,
      distanceKm: distance,
      estimatedMinutes: estimatedTime,
      fareAmount: fare,
      paymentMethod: paymentMethod,
      riderProfileImageUrl: null,
      requestTimestamp: DateTime.now().toIso8601String(),
      specialInstructions: instruction,
    );
  }

  // Dispose resources
  void dispose() {
    _audioPlayer.dispose();
    _rideRequestSubscription?.cancel();
    _removeOverlay();
  }

  void hideOverlay() {
    _removeOverlay();
  }
}
