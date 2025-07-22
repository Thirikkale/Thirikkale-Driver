import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/features/home/widgets/vehicle_info.dart';
import 'package:thirikkale_driver/features/vehicle_details/add_new_vehicle.dart';
import 'package:thirikkale_driver/features/vehicle_details/current_vehicle.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar.dart';

class ManageVehicles extends StatefulWidget {
  const ManageVehicles({super.key});

  @override
  State<ManageVehicles> createState() => _ManageVehiclesState();
}

class _ManageVehiclesState extends State<ManageVehicles> {
  int? selectedVehicleIndex;

  final List<Map<String, String>> vehicles = [
    {
      "imagePath": "assets/vehicle/car_photo.jpg",
      "vehicleName": "2015 Toyota Vitz",
      "plateNumber": "WP CBF-8828",
    },
    {
      "imagePath": "assets/vehicle/tuktuk_photo.jpg",
      "vehicleName": "2014 TVS",
      "plateNumber": "WP CBC-3328",
    },
    {
      "imagePath": "assets/vehicle/bike_photo.jpg",
      "vehicleName": "2017 TVS Discovery",
      "plateNumber": "WP CAF-8568",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerWidget: Image.asset(
          'assets/icons/thirikkale_driver_appbar_logo.png',
          height: 50.0,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Your vehicles", style: AppTextStyles.heading2),
                Gap(15),
                ...List.generate(vehicles.length, (index) {
                  final vehicle = vehicles[index];
                  final isSelected = selectedVehicleIndex == index;
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedVehicleIndex = index;
                          });
                        },
                        child: VehicleInfo(
                          imagePath: vehicle["imagePath"]!,
                          vehicleName: vehicle["vehicleName"]!,
                          plateNumber: vehicle["plateNumber"]!,
                          isSelected: isSelected,
                        ),
                      ),
                      Gap(7),
                    ],
                  );
                }),
                Gap(15),
                SizedBox(
                  width: double.infinity,
                  child: InkWell(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddNewVehicle(),
                          ),
                        ),
                    child: AppButtonStyles.dottedButton(
                      Row(
                        children: [
                          Icon(Icons.add_circle_outline, color: AppColors.grey),
                          SizedBox(width: 8.0),
                          Text(
                            "Add another vehicle",
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    selectedVehicleIndex == null
                        ? null
                        : () {
                          final selectedVehicle =
                              vehicles[selectedVehicleIndex!];
                          // Replace with navigation to your next page or logic
                          // print("Selected Vehicle: $selectedVehicle");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CurrentVehicle(selectedVehicle),
                            ),
                          );
                        },
                style: AppButtonStyles.primaryButton,
                child: Text("Select this vehicle"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
