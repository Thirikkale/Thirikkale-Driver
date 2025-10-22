class ScheduledRide {
  final String id;
  final String riderId;
  final String? driverId;
  final String pickupAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final String dropoffAddress;
  final double dropoffLatitude;
  final double dropoffLongitude;
  final double? distanceKm; // nearby list
  final double? rideDistanceKm; // provided sometimes
  final String scheduledTime; // ISO8601 string
  final String status;
  final int passengers;
  final bool isSharedRide;
  final String? rideType;
  final String? vehicleType;
  final bool? isWomenOnly;
  final double? maxFare;
  final double? pickupDistanceKm; // route-match
  final double? dropoffDistanceKm; // route-match
  final double? totalDistanceKm; // route-match

  ScheduledRide({
    required this.id,
    required this.riderId,
    required this.pickupAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropoffAddress,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    required this.scheduledTime,
    required this.status,
    required this.passengers,
    required this.isSharedRide,
    this.driverId,
    this.distanceKm,
    this.rideDistanceKm,
    this.rideType,
    this.vehicleType,
    this.isWomenOnly,
    this.maxFare,
    this.pickupDistanceKm,
    this.dropoffDistanceKm,
    this.totalDistanceKm,
  });

  factory ScheduledRide.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) => v == null ? null : (v as num).toDouble();
    return ScheduledRide(
      id: json['id'] as String,
      riderId: json['riderId'] as String,
      driverId: json['driverId'] as String?,
      pickupAddress: json['pickupAddress'] as String? ?? '',
      pickupLatitude: (json['pickupLatitude'] as num).toDouble(),
      pickupLongitude: (json['pickupLongitude'] as num).toDouble(),
      dropoffAddress: json['dropoffAddress'] as String? ?? '',
      dropoffLatitude: (json['dropoffLatitude'] as num).toDouble(),
      dropoffLongitude: (json['dropoffLongitude'] as num).toDouble(),
      distanceKm: _toDouble(json['distanceKm']),
      rideDistanceKm: _toDouble(json['rideDistanceKm']),
      scheduledTime: json['scheduledTime'] as String,
      status: json['status'] as String,
      passengers: (json['passengers'] as num?)?.toInt() ?? 1,
      isSharedRide: json['isSharedRide'] as bool? ?? false,
      rideType: json['rideType'] as String?,
      vehicleType: json['vehicleType'] as String?,
      isWomenOnly: json['isWomenOnly'] as bool?,
      maxFare: _toDouble(json['maxFare']),
      pickupDistanceKm: _toDouble(json['pickupDistanceKm']),
      dropoffDistanceKm: _toDouble(json['dropoffDistanceKm']),
      totalDistanceKm: _toDouble(json['totalDistanceKm']),
    );
  }
}
