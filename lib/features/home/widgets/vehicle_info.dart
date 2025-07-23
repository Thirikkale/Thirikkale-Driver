import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';

class VehicleInfo extends StatelessWidget {
  final String imagePath;
  final String vehicleName;
  final String plateNumber;
  final bool isSelected; // <-- NEW PARAMETER

  const VehicleInfo({
    super.key,
    required this.imagePath,
    required this.vehicleName,
    required this.plateNumber,
    this.isSelected = false, // <-- DEFAULT VALUE
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColors.primaryBlue : AppColors.lightGrey, // <-- CONDITIONAL COLOR
          width: 2,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 80.0,
                  width: 80.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                    ),
                  ),
                ),
                const Gap(15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicleName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      plateNumber,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Icon(CupertinoIcons.ellipsis),
          ],
        ),
      ),
    );
  }
}
