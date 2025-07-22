import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/features/vehicle_details/manage_vehicles.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar_name.dart';

class CurrentVehicle extends StatelessWidget {

  final Map<String, String> vehicle;
  const CurrentVehicle(
    [Map<String, String>? vehicle, key,]) :
    vehicle = vehicle ?? const {
      "imagePath": "assets/vehicle/car_photo.jpg",
      "vehicleName": "2015 Toyota Vitz",
      "plateNumber": "WP CBF-8828",
    };

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppbarName(title: "Vehicle Details", showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 24.0, left: 24.0, right: 24.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: AppDimensions.sectionSpacing,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Your vehicle", style: AppTextStyles.heading2),
                  Gap(20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(vehicle["imagePath"]!),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(vehicle["vehicleName"]!, style: AppTextStyles.heading2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  vehicle["plateNumber"]!,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.grey,
                                  ),
                                ),
                                Gap(25),
                                Text(
                                  "Rides only",
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.sectionSpacing + 10,),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Revenue License",
                                      style: AppTextStyles.heading3,
                                    ),
                                    Row(
                                      children: [
                                        Gap(10),
                                        Text(
                                          "Completed",
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.grey,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20.0,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                            Gap(5),
                            Divider(color: AppColors.lightGrey, thickness: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Vehicle registration",
                                      style: AppTextStyles.heading3,
                                    ),
                                    Row(
                                      children: [
                                        Gap(10),
                                        Text(
                                          "Completed",
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.grey,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20.0,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                            Gap(5),
                            Divider(color: AppColors.lightGrey, thickness: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Vehicle insurance",
                                      style: AppTextStyles.heading3,
                                    ),
                                    Row(
                                      children: [
                                        Gap(10),
                                        Text(
                                          "Completed",
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.grey,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20.0,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                            Gap(5),
                            Divider(color: AppColors.lightGrey, thickness: 1),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageVehicles(),
                        ),
                      ),
                  style: AppButtonStyles.primaryButton,
                  child: Text("Manage Vehicles"),
                ),
              ),
              const SizedBox(height: 16,)
            ],
          ),
        ),
      ),
    );
  }
}
