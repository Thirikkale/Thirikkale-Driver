import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar.dart';

class Documents extends StatefulWidget {
  const Documents({super.key});

  @override
  State<Documents> createState() => _DocumentsState();
}

class _DocumentsState extends State<Documents> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerWidget: Image.asset(
          'assets/icons/thirikkale_driver_appbar_logo.png',
          height: 50.0,
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(bottom: 24.0, left: 24.0, right: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your documents", style: AppTextStyles.heading2),
            Gap(20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Profile photo", style: AppTextStyles.heading3),
                          Row(
                            children: [
                              Gap(10),
                              Text("Completed", style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.grey)),
                            ],
                          )
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios, size: 20.0, color: Colors.grey,)
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
                          Text("Driver's License", style: AppTextStyles.heading3),
                          Row(
                            children: [
                              Gap(10),
                              Text("Completed", style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.grey)),
                            ],
                          )
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios, size: 20.0, color: Colors.grey,)
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
                          Text("National Identity Card", style: AppTextStyles.heading3),
                          Row(
                            children: [
                              Gap(10),
                              Text("Optional", style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.grey)),
                            ],
                          )
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios, size: 20.0, color: Colors.grey,)
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
                          Text("Passport", style: AppTextStyles.heading3),
                          Row(
                            children: [
                              Gap(10),
                              Text("Optional", style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.grey)),
                            ],
                          )
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios, size: 20.0, color: Colors.grey,)
                    ],
                  ),
                  Gap(5),
                  Divider(color: AppColors.lightGrey, thickness: 1),
                ]
              ),
            )
          ]
        )
      )
    );
  }
}