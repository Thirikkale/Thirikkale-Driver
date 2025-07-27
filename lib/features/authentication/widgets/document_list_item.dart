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
  final VoidCallback? onRefreshStatus;

  const DocumentListItem({
    super.key,
    required this.document,
    this.onTap, // Removed required keyword
    required this.onDocumentCompleted,
    this.onRefreshStatus,
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

  Future<void> _handleDocumentUpload(
    BuildContext context,
    String documentTitle,
  ) async {
    Widget? screen;

    switch (documentTitle) {
      case 'Profile Picture':
        screen = ProfilePictureScreen(
          onPhotoUploaded: () {
            onDocumentCompleted('Profile Picture');
          },
        );
        break;
      case 'Driving License':
        screen = const DrivingLicenseScreen();
        break;
      case 'Revenue License':
        screen = const RevenueLicenseScreen();
        break;
      case 'Vehicle Insurance':
        screen = const VehicleInsuranceScreen();
        break;
      case 'Vehicle Registration':
        screen = const VehicleRegistrationScreen();
        break;
    }

    if (screen != null) {
      final result = await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => screen!));

      // If upload was successful, refresh status from backend
      if (result == true) {
        onDocumentCompleted(documentTitle);

        // Also refresh the status from backend to ensure consistency
        if (onRefreshStatus != null) {
          onRefreshStatus!();
        }
      }
    } else {
      // Fallback to original onTap behavior
      onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          document.isCompleted
              ? null
              : () => _handleDocumentUpload(context, document.title),
      child: Opacity(
        opacity: document.isCompleted ? 0.6 : 1.0,
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
                Expanded(
                  child: Column(
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
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    key: ValueKey(document.isCompleted),
                    document.isCompleted
                        ? Icons.check_circle
                        : Icons.upload_outlined,
                    color:
                        document.isCompleted
                            ? AppColors.success
                            : AppColors.lightGrey,
                    size: document.isCompleted ? 28 : 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
