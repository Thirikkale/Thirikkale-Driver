import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/core/utils/navigation_utils.dart';
import 'package:thirikkale_driver/features/authentication/screens/upload_screens/camera_screen.dart';
import 'package:thirikkale_driver/features/authentication/widgets/upload_screen_widgets/build_reason_item.dart';
import 'package:thirikkale_driver/features/authentication/widgets/upload_screen_widgets/guidelines_widget.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar.dart';

class RevenueLicenseScreen extends StatefulWidget {
  final String vehicleId;

  const RevenueLicenseScreen({super.key, required this.vehicleId});

  @override
  State<RevenueLicenseScreen> createState() => _RevenueLicenseScreenState();
}

class _RevenueLicenseScreenState extends State<RevenueLicenseScreen> {
  Future<void> _handleTakePhoto() async {
    final result = await Navigator.of(context).push<bool>(
      NoAnimationPageRoute(
        builder:
            (context) => CameraScreen(
              documentType: 'revenue_license',
              vehicleId: widget.vehicleId,
            ),
      ),
    );

    if (!mounted) return;

    // If photo was successfully uploaded, return true to mark as completed
    if (result == true) {
      Navigator.of(context).pop(true);
    }
  }

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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pageHorizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Revenue License',
                      style: AppTextStyles.heading1,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Why do we need your revenue license?',
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: 16),
                    const BuildReasonItem(
                      icon: Icons.business,
                      title: 'Commercial operation permit',
                      description:
                          'Revenue license authorizes your vehicle for commercial passenger transport.',
                    ),
                    const SizedBox(height: 16),
                    const BuildReasonItem(
                      icon: Icons.verified,
                      title: 'Legal compliance',
                      description:
                          'Required by law to operate as a commercial driver in your area.',
                    ),
                    const SizedBox(height: 16),
                    const BuildReasonItem(
                      icon: Icons.monetization_on,
                      title: 'Earning eligibility',
                      description:
                          'Essential for activating your driver account and start earning.',
                    ),
                    const SizedBox(height: 32),
                    const GuidelinesWidget(
                      title: 'Photo Guidelines',
                      icon: Icons.camera_alt_outlined,
                      guidelines: [
                        '• Take a clear photo of the front of your revenue license',
                        '• Document size: 3.5" × 2.5" (8.9cm × 6.4cm)',
                        '• Ensure license is valid and not expired',
                        '• All text and numbers must be clearly readable',
                        '• Place on a flat, dark surface for contrast',
                        '• Good lighting with no shadows or reflections',
                        '• Capture the entire license within the frame',
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(
                AppDimensions.pageHorizontalPadding,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppButtonStyles.primaryButton,
                  onPressed: _handleTakePhoto,
                  child: const Text('Take Photo'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
