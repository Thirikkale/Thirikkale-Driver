import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  // Convert from API response
  factory RideRequest.fromJson(Map<String, dynamic> json) {
    return RideRequest(
      rideId: json['ride_id'] ?? '',
      riderId: json['rider_id'] ?? '',
      riderName: json['rider_name'] ?? '',
      riderPhone: json['rider_phone'] ?? '',
      riderRating: (json['rider_rating'] ?? 0.0).toDouble(),
      pickupAddress: json['pickup_address'] ?? '',
      destinationAddress: json['destination_address'] ?? '',
      pickupLat: (json['pickup_lat'] ?? 0.0).toDouble(),
      pickupLng: (json['pickup_lng'] ?? 0.0).toDouble(),
      destinationLat: (json['destination_lat'] ?? 0.0).toDouble(),
      destinationLng: (json['destination_lng'] ?? 0.0).toDouble(),
      distanceKm: (json['distance_km'] ?? 0.0).toDouble(),
      estimatedMinutes: json['estimated_minutes'] ?? 0,
      fareAmount: (json['fare_amount'] ?? 0.0).toDouble(),
      paymentMethod: json['payment_method'] ?? '',
      riderProfileImageUrl: json['rider_profile_image_url'],
      requestTimestamp: json['request_timestamp'] ?? '',
      specialInstructions: json['special_instructions'],
    );
  }

  // Helper getters for UI
  LatLng get pickupLocation => LatLng(pickupLat, pickupLng);
  LatLng get destinationLocation => LatLng(destinationLat, destinationLng);
  DateTime get requestTime => DateTime.parse(requestTimestamp);
}