class DriverCardModel {
  final String name;
  final String contactNumber;
  final String? profilePicUrl;

  DriverCardModel({
    required this.name,
    required this.contactNumber,
    this.profilePicUrl,
  });

  factory DriverCardModel.fromJson(Map<String, dynamic> json) {
    return DriverCardModel(
      name: json['name'] as String? ?? '',
      contactNumber: json['contactNumber'] as String? ?? '',
      profilePicUrl: json['profilePicUrl'] as String?,
    );
  }
}

class RiderCardModel {
  final String name;
  final String contactNumber;
  final String? profilePicUrl;

  RiderCardModel({
    required this.name,
    required this.contactNumber,
    this.profilePicUrl,
  });

  factory RiderCardModel.fromJson(Map<String, dynamic> json) {
    return RiderCardModel(
      name: json['name'] as String? ?? '',
      contactNumber: json['contactNumber'] as String? ?? '',
      profilePicUrl: json['profilePicUrl'] as String?,
    );
  }
}
