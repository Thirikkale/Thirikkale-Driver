class RideRequest {
  final String rideId;
  final String riderId;
  final String riderName;
  final String riderPhone;
  final double riderRating;
  final String? riderProfileImageUrl;

  // ✅ ADD Driver details
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final double? driverRating;
  final String? driverProfileImageUrl;
  final String? vehicleType;
  final String? vehiclePlateNumber;
  final String? vehicleModel;
  final String? vehicleColor;

  final String pickupAddress;
  final String destinationAddress;
  final double pickupLat;
  final double pickupLng;
  final double destinationLat;
  final double destinationLng;

  // ✅ ADD Driver location for tracking
  final double? driverLat;
  final double? driverLng;

  final double distanceKm;
  final int estimatedMinutes;
  final double fareAmount;
  final String paymentMethod;
  final String requestTimestamp;
  final String? acceptedTimestamp;
  final String? specialInstructions;
  final String status; // ✅ ADD status

  RideRequest({
    required this.rideId,
    required this.riderId,
    required this.riderName,
    required this.riderPhone,
    required this.riderRating,
    this.riderProfileImageUrl,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.driverRating,
    this.driverProfileImageUrl,
    this.vehicleType,
    this.vehiclePlateNumber,
    this.vehicleModel,
    this.vehicleColor,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationLat,
    required this.destinationLng,
    this.driverLat,
    this.driverLng,
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.fareAmount,
    required this.paymentMethod,
    required this.requestTimestamp,
    this.acceptedTimestamp,
    this.specialInstructions,
    this.status = 'PENDING',
  });

  // Helper getters
  LatLng get pickupLocation => LatLng(pickupLat, pickupLng);
  LatLng get destinationLocation => LatLng(destinationLat, destinationLng);
  LatLng? get driverLocation =>
      driverLat != null && driverLng != null
          ? LatLng(driverLat!, driverLng!)
          : null;
  DateTime get requestTime => DateTime.parse(requestTimestamp);
  DateTime? get acceptedTime =>
      acceptedTimestamp != null ? DateTime.parse(acceptedTimestamp!) : null;

  // ✅ Create from backend JSON
  factory RideRequest.fromBackendJson(Map<String, dynamic> json) {
    return RideRequest(
      rideId: json['requestId'] ?? json['rideId'] ?? '',
      riderId: json['riderId'] ?? '',
      riderName: json['riderName'] ?? 'Rider',
      riderPhone: json['riderPhone'] ?? '+94000000000',
      riderRating: (json['riderRating'] ?? 4.5).toDouble(),
      riderProfileImageUrl: json['riderProfileImageUrl'],
      driverId: json['driverId'],
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
      driverRating:
          json['driverRating'] != null
              ? (json['driverRating'] as num).toDouble()
              : null,
      driverProfileImageUrl: json['driverProfileImageUrl'],
      vehicleType: json['vehicleType'],
      vehiclePlateNumber: json['vehiclePlateNumber'],
      vehicleModel: json['vehicleModel'],
      vehicleColor: json['vehicleColor'],
      pickupAddress: json['pickupAddress'] ?? 'Unknown pickup',
      destinationAddress: json['dropoffAddress'] ?? 'Unknown destination',
      pickupLat: (json['pickupLatitude'] ?? 0.0).toDouble(),
      pickupLng: (json['pickupLongitude'] ?? 0.0).toDouble(),
      destinationLat: (json['dropoffLatitude'] ?? 0.0).toDouble(),
      destinationLng: (json['dropoffLongitude'] ?? 0.0).toDouble(),
      driverLat:
          json['driverLatitude'] != null
              ? (json['driverLatitude'] as num).toDouble()
              : null,
      driverLng:
          json['driverLongitude'] != null
              ? (json['driverLongitude'] as num).toDouble()
              : null,
      distanceKm: (json['estimatedDistance'] ?? 0.0).toDouble(),
      estimatedMinutes: (json['estimatedDuration'] ?? 0).toInt(),
      fareAmount: (json['estimatedFare'] ?? 0.0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'CASH',
      requestTimestamp: json['requestTime'] ?? DateTime.now().toIso8601String(),
      acceptedTimestamp: json['acceptedTime'],
      specialInstructions: json['specialRequests'],
      status: json['status'] ?? 'PENDING',
    );
  }
}

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}
