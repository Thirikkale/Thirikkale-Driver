import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/core/utils/navigation_utils.dart';
import 'package:thirikkale_driver/features/authentication/screens/upload_screens/camera_screen.dart';
import 'package:thirikkale_driver/features/authentication/widgets/upload_screen_widgets/build_reason_item.dart';
import 'package:thirikkale_driver/features/authentication/widgets/upload_screen_widgets/guidelines_widget.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar.dart';

class DrivingLicenseScreen extends StatelessWidget {
  const DrivingLicenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerWidget: Image.asset(
          'assets/icons/thirikkale_driver_appbar_logo.png',
          height: 50.0,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upload Driving License', style: AppTextStyles.heading1),
              const SizedBox(height: 24),

              Text(
                'Why do we need your driving license?',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 16),

              BuildReasonItem(
                icon: Icons.verified_user,
                title: 'Legal requirement',
                description:
                    'A valid driving license is required by law to operate a vehicle commercially.',
              ),
              const SizedBox(height: 16),

              BuildReasonItem(
                icon: Icons.check_circle,
                title: 'Account activation',
                description:
                    'Your license verification is required to activate your driver account.',
              ),
              const SizedBox(height: 32),

              const GuidelinesWidget(
                title: 'Photo Guidelines',
                icon: Icons.camera_alt_outlined,
                guidelines: [
                  '• Take a clear photo of the front of your license',
                  '• Ensure all text is readable and not blurred',
                  '• Make sure the license is not expired',
                  '• Good lighting with no shadows or glare',
                  '• Place license on a flat, contrasting surface',
                  '• Capture the entire license within the frame',
                ],
              ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppButtonStyles.primaryButton,
                  onPressed: () {
                    Navigator.of(context).push(
                      NoAnimationPageRoute(
                        builder:
                            (context) => const CameraScreen(
                              documentType: 'driving_license',
                            ),
                      ),
                    );
                  },
                  child: const Text('Take Photo'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
