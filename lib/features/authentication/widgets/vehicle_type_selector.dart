import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/features/authentication/models/vehicle_type_model.dart';
import 'package:thirikkale_driver/features/authentication/widgets/vehicle_type_bottomsheet.dart';

class VehicleTypeSelector extends StatelessWidget {
  final VehicleType selectedVehicle;
  final List<VehicleType> vehicleTypes;
  final ValueChanged<VehicleType?> onChanged;

  const VehicleTypeSelector({
    super.key,
    required this.selectedVehicle,
    required this.vehicleTypes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await VehicleTypeBottomSheet.show(
          context,
          vehicleTypes: vehicleTypes,
          selectedVehicle: selectedVehicle,
        );
        if (result != null) {
          onChanged(result);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: AppColors.divider, width: 1.5),
        ),
        child: Row(
          children: [
            Image.asset(
              selectedVehicle.imagePath,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                selectedVehicle.name,
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary),
          ],
        ),
      ),
    );
  }
}