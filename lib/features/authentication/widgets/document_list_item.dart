import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/features/authentication/models/document_item_model.dart';
import 'package:thirikkale_driver/features/authentication/screens/upload_screens/driving_license_screen.dart';
import 'package:thirikkale_driver/features/authentication/screens/upload_screens/profile_picture_screen.dart';
import 'package:thirikkale_driver/features/authentication/screens/upload_screens/revenue_license_screen.dart';
import 'package:thirikkale_driver/features/authentication/screens/upload_screens/vehicle_insurance_screen.dart';
import 'package:thirikkale_driver/features/authentication/screens/upload_screens/vehicle_registration_screen.dart';

class DocumentListItem extends StatelessWidget {
  final DocumentItem document;
  final VoidCallback? onTap; // Made optional with ?
  final Function(String documentTitle) onDocumentCompleted;

  const DocumentListItem({
    super.key,
    required this.document,
    this.onTap, // Removed required keyword
    required this.onDocumentCompleted,
  });

  String _getCompletionMessage(String documentTitle) {
    switch (documentTitle) {
      case 'Profile Picture':
        return 'Profile photo uploaded successfully';
      case 'Driving License':
        return 'Driving License uploaded successfully';
      case 'Revenue License':
        return 'Revenue License uploaded successfully';
      default:
        return 'Document uploaded successfully';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          document.isCompleted
              ? null
              : () async {
                if (document.title == 'Profile Picture') {
                  // Navigate to profile picture screen
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => ProfilePictureScreen(
                            onPhotoUploaded: () {
                              onDocumentCompleted('Profile Picture');
                            },
                          ),
                    ),
                  );

                  // If photo was successfully uploaded, mark as completed
                  if (result == true) {
                    onDocumentCompleted('Profile Picture');
                  }
                } else if (document.title == 'Driving License') {
                  // Navigate to driving license screen
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const DrivingLicenseScreen(),
                    ),
                  );

                  // If photo was successfully uploaded, mark as completed
                  if (result == true) {
                    onDocumentCompleted('Driving License');
                  }
                } else if (document.title == 'Revenue License') {
                  // Navigate to revenue license screen
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RevenueLicenseScreen(),
                    ),
                  );

                  // If photo was successfully uploaded, mark as completed
                  if (result == true) {
                    onDocumentCompleted('Revenue License');
                  }
                } else if (document.title == 'Vehicle Insurance') {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const VehicleInsuranceScreen(),
                    ),
                  );

                  if (result == true) {
                    onDocumentCompleted('Vehicle Insurance');
                  }
                } else if (document.title == 'Vehicle Registration') {
                  // Navigate to vehicle registration screen
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const VehicleRegistrationScreen(),
                    ),
                  );

                  if (result == true) {
                    onDocumentCompleted('Vehicle Registration');
                  }
                } else {
                  // For other documents, use the original toggle behavior if onTap is provided
                  onTap?.call();
                }
              },
      child: Opacity(
        opacity: document.isCompleted ? 0.6 : 1.0, // Fade completed items
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pageHorizontalPadding,
          ),

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 8.0,
            ),
            decoration: BoxDecoration(
              border: const Border(
                bottom: BorderSide(color: AppColors.divider, width: 1.0),
              ),
              color:
                  document.isCompleted
                      ? AppColors.success.withOpacity(0.1)
                      : Colors.transparent,
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            document.isCompleted
                                ? AppColors.success
                                : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      document.isCompleted
                          ? _getCompletionMessage(document.title)
                          : document.subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color:
                            document.isCompleted
                                ? AppColors.success
                                : AppColors.primaryBlue,
                        fontWeight:
                            document.isCompleted
                                ? FontWeight.w600
                                : FontWeight.w500,
                        fontStyle:
                            document.isCompleted
                                ? FontStyle.italic
                                : FontStyle.normal,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.check_circle,
                  color:
                      document.isCompleted
                          ? AppColors.success
                          : AppColors.lightGrey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
