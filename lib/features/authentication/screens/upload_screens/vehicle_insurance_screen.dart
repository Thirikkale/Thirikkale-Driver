import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/core/utils/navigation_utils.dart';
import 'package:thirikkale_driver/features/authentication/screens/upload_screens/camera_screen.dart';
import 'package:thirikkale_driver/features/authentication/widgets/upload_screen_widgets/build_reason_item.dart';
import 'package:thirikkale_driver/features/authentication/widgets/upload_screen_widgets/guidelines_widget.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar.dart';

class VehicleInsuranceScreen extends StatelessWidget {
  const VehicleInsuranceScreen({super.key});

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pageHorizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text('Upload Vehicle Insurance', style: AppTextStyles.heading1),
              const SizedBox(height: 24),
              Text(
                'Why do we need your vehicle insurance?',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 16),
              const BuildReasonItem(
                icon: Icons.security,
                title: 'Safety protection',
                description:
                    'Insurance protects you, your passengers, and other road users in case of accidents.',
              ),
              const SizedBox(height: 16),
              const BuildReasonItem(
                icon: Icons.gavel,
                title: 'Legal requirement',
                description:
                    'Valid vehicle insurance is mandatory by law for all commercial vehicles.',
              ),
              const SizedBox(height: 16),
              const BuildReasonItem(
                icon: Icons.verified_user,
                title: 'Platform compliance',
                description:
                    'Insurance verification is required to activate your driver account and start earning.',
              ),
              const SizedBox(height: 32),
              const GuidelinesWidget(
                title: 'Photo Guidelines',
                icon: Icons.camera_alt_outlined,
                guidelines: [
                  '• Take a clear photo of your insurance certificate',
                  '• Ensure the policy is current and not expired',
                  '• All text, including policy number, must be readable',
                  '• Verify vehicle details match your registration',
                  '• Good lighting with no shadows or reflections',
                  '• Place document on a flat, contrasting surface',
                  '• Capture the entire certificate within the frame',
                ],
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppButtonStyles.primaryButton,
                  onPressed: () {
                    Navigator.of(context).push(
                      NoAnimationPageRoute(
                        builder:
                            (context) => const CameraScreen(
                              documentType: 'vehicle_insurance',
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
