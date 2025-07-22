import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar_name.dart';

class PayoutHistory extends StatelessWidget {
  const PayoutHistory({super.key});

  final String balance = "4,999 LKR";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbarName(title: "Payout History", showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.sectionSpacing),
            Text(
              "July 22",
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  padding: EdgeInsets.all(2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.subtleGrey,
                    borderRadius: BorderRadius.circular(45),
                  ),
                  child: Icon(Icons.directions_car, size: 30),
                ),
                Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Zip",
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "1:37pm",
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "LKR 999.00",
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.grey, thickness: 1),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
