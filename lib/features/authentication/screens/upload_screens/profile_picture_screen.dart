import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/core/utils/navigation_utils.dart';
import 'package:thirikkale_driver/features/authentication/screens/upload_screens/camera_screen.dart';
import 'package:thirikkale_driver/features/authentication/widgets/upload_screen_widgets/build_reason_item.dart';
import 'package:thirikkale_driver/features/authentication/widgets/upload_screen_widgets/guidelines_widget.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar.dart';

class ProfilePictureScreen extends StatefulWidget {
  final VoidCallback onPhotoUploaded;

  const ProfilePictureScreen({super.key, required this.onPhotoUploaded});

  @override
  State<ProfilePictureScreen> createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends State<ProfilePictureScreen> {
  Future<void> _handleTakePhoto() async {
    final result = await Navigator.of(context).push<bool>(
      NoAnimationPageRoute(
        builder:
            (context) => const CameraScreen(documentType: 'profile_picture'),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      widget.onPhotoUploaded();
      Navigator.of(context).pop();
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pageHorizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upload Profile Picture', style: AppTextStyles.heading1),
              const SizedBox(height: 24),
              Text('Why do we need your photo?', style: AppTextStyles.heading2),
              const SizedBox(height: 16),
              BuildReasonItem(
                icon: Icons.visibility,
                title: 'Helps riders recognize you',
                description:
                    'Your profile photo helps riders identify their driver when you arrive.',
              ),
              const SizedBox(height: 16),
              BuildReasonItem(
                icon: Icons.security,
                title: 'Safety and security',
                description:
                    'Profile photos increase trust and safety for both drivers and riders.',
              ),
              const SizedBox(height: 16),
              BuildReasonItem(
                icon: Icons.verified_user,
                title: 'Account verification',
                description:
                    'A clear photo helps us verify your identity and activate your account.',
              ),
              const SizedBox(height: 32),
              const GuidelinesWidget(
                title: 'Photo Guidelines',
                icon: Icons.info_outline,
                guidelines: [
                  '• Use a clear, recent photo of yourself',
                  '• Face the camera directly',
                  '• No filters, effects, or heavy editing',
                  '• Good lighting and clear background',
                  '• No sunglasses or hats covering your face',
                ],
              ),

              const Spacer(),
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
