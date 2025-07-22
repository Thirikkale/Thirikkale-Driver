class VehicleType {
  final String name;
  final String imagePath;
  final int minAge;
  final int minVehicleYear;

  VehicleType({
    required this.name,
    required this.imagePath,
    required this.minAge,
    required this.minVehicleYear,
  });

  // It's good practice to override equality operators when comparing objects.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleType &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}