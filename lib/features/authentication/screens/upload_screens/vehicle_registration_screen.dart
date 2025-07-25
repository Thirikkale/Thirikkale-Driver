import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/core/utils/navigation_utils.dart';
import 'package:thirikkale_driver/features/authentication/screens/upload_screens/camera_screen.dart';
import 'package:thirikkale_driver/features/authentication/widgets/upload_screen_widgets/build_reason_item.dart';
import 'package:thirikkale_driver/features/authentication/widgets/upload_screen_widgets/guidelines_widget.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  State<VehicleRegistrationScreen> createState() =>
      _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  Future<void> _handleTakePhoto() async {
    final result = await Navigator.of(context).push<bool>(
      NoAnimationPageRoute(
        builder:
            (context) =>
                const CameraScreen(documentType: 'vehicle_registration'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pageHorizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Upload Vehicle Registration',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 24),
              Text(
                'Why do we need your vehicle registration?',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 16),
              const BuildReasonItem(
                icon: Icons.assignment,
                title: 'Vehicle ownership verification',
                description:
                    'Confirms you are the legal owner or authorized user of the vehicle.',
              ),
              const SizedBox(height: 16),
              const BuildReasonItem(
                icon: Icons.verified,
                title: 'Legal compliance',
                description:
                    'Vehicle registration is required by law for all vehicles operating commercially.',
              ),
              const SizedBox(height: 16),
              const BuildReasonItem(
                icon: Icons.settings,
                title: 'Vehicle details matching',
                description:
                    'Ensures vehicle specifications match your selected service type.',
              ),
              const SizedBox(height: 32),
              const GuidelinesWidget(
                title: 'Photo Guidelines',
                icon: Icons.camera_alt_outlined,
                guidelines: [
                  '• Take a clear photo of your vehicle registration certificate',
                  '• Ensure the document is current and not expired',
                  '• All vehicle details must be clearly readable',
                  '• Vehicle number, owner name, and model should be visible',
                  '• Good lighting with no shadows or reflections',
                  '• Place document flat on a contrasting surface',
                  '• Capture the entire document within the frame',
                ],
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppButtonStyles.primaryButton,
                  onPressed: _handleTakePhoto,
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
