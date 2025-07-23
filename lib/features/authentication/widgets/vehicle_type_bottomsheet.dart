import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/features/authentication/models/vehicle_type_model.dart';
import 'package:thirikkale_driver/features/authentication/widgets/vehicle_type_tile.dart';

class VehicleTypeBottomSheet extends StatelessWidget {
  final List<VehicleType> vehicleTypes;
  final VehicleType selectedVehicle;

  const VehicleTypeBottomSheet({
    super.key,
    required this.vehicleTypes,
    required this.selectedVehicle,
  });

  static Future<VehicleType?> show(
    BuildContext context, {
    required List<VehicleType> vehicleTypes,
    required VehicleType selectedVehicle,
  }) {
    return showModalBottomSheet<VehicleType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VehicleTypeBottomSheet(
        vehicleTypes: vehicleTypes,
        selectedVehicle: selectedVehicle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildTitle(),
          const Divider(height: 1, color: AppColors.divider),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: vehicleTypes.length,
              itemBuilder: (context, index) {
                final vehicle = vehicleTypes[index];
                final isSelected = vehicle == selectedVehicle;
                return VehicleTypeTile(
                  vehicle: vehicle,
                  isSelected: isSelected,
                  onTap: () {
                    Navigator.pop(context, vehicle);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Text(
        'Select Vehicle Type',
        style: AppTextStyles.heading3,
      ),
    );
  }
}