class RideRequest {
  final String rideId;
  final String riderId;
  final String riderName;
  final String riderPhone;
  final double riderRating;
  final String pickupAddress;
  final String destinationAddress;
  final double pickupLat;
  final double pickupLng;
  final double destinationLat;
  final double destinationLng;
  final double distanceKm;
  final int estimatedMinutes;
  final double fareAmount;
  final String paymentMethod;
  final String? riderProfileImageUrl;
  final String requestTimestamp;
  final String? specialInstructions;

  RideRequest({
    required this.rideId,
    required this.riderId,
    required this.riderName,
    required this.riderPhone,
    required this.riderRating,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.fareAmount,
    required this.paymentMethod,
    this.riderProfileImageUrl,
    required this.requestTimestamp,
    this.specialInstructions,
  });

  // Helper getters
  LatLng get pickupLocation => LatLng(pickupLat, pickupLng);
  LatLng get destinationLocation => LatLng(destinationLat, destinationLng);
  DateTime get requestTime => DateTime.parse(requestTimestamp);

  // Create from backend JSON response
  factory RideRequest.fromBackendJson(Map<String, dynamic> json) {
    return RideRequest(
      rideId: json['id'] ?? '',
      riderId: json['userId'] ?? '',
      riderName: json['riderName'] ?? 'Unknown Rider',
      riderPhone: json['riderPhone'] ?? '+94000000000',
      riderRating: (json['riderRating'] ?? 4.5).toDouble(),
      pickupAddress: json['pickupLocation'] ?? '',
      destinationAddress: json['dropoffLocation'] ?? '',
      pickupLat: (json['pickupLatitude'] ?? 0.0).toDouble(),
      pickupLng: (json['pickupLongitude'] ?? 0.0).toDouble(),
      destinationLat: (json['dropoffLatitude'] ?? 0.0).toDouble(),
      destinationLng: (json['dropoffLongitude'] ?? 0.0).toDouble(),
      distanceKm: (json['estimatedDistance'] ?? 0.0).toDouble(),
      estimatedMinutes: (json['estimatedDuration'] ?? 0).round(),
      fareAmount: (json['estimatedFare'] ?? 0.0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'Cash',
      riderProfileImageUrl: json['riderProfileImageUrl'],
      requestTimestamp: json['requestTime'] ?? DateTime.now().toIso8601String(),
      specialInstructions: json['specialRequests'],
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'rideId': rideId,
      'riderId': riderId,
      'riderName': riderName,
      'riderPhone': riderPhone,
      'riderRating': riderRating,
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'destinationLat': destinationLat,
      'destinationLng': destinationLng,
      'distanceKm': distanceKm,
      'estimatedMinutes': estimatedMinutes,
      'fareAmount': fareAmount,
      'paymentMethod': paymentMethod,
      'riderProfileImageUrl': riderProfileImageUrl,
      'requestTimestamp': requestTimestamp,
      'specialInstructions': specialInstructions,
    };
  }
}

// Add LatLng class if not already imported
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);
}
