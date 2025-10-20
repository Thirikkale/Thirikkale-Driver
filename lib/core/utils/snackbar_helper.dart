import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';

class SnackbarHelper {
  static void showSuccessSnackBar(BuildContext context, String message) {
    // ✅ Check if context is still valid
    if (!_isContextValid(context)) {
      print('⚠️ Cannot show SnackBar: Context is no longer valid');
      return;
    }

    _showCustomSnackBar(
      context,
      message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle,
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    // ✅ Check if context is still valid
    if (!_isContextValid(context)) {
      print('⚠️ Cannot show SnackBar: Context is no longer valid');
      return;
    }

    _showCustomSnackBar(
      context,
      message,
      backgroundColor: AppColors.error,
      icon: Icons.error,
    );
  }

  static void showWarningSnackBar(BuildContext context, String message) {
    // ✅ Check if context is still valid
    if (!_isContextValid(context)) {
      print('⚠️ Cannot show SnackBar: Context is no longer valid');
      return;
    }

    _showCustomSnackBar(
      context,
      message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning,
      textColor: AppColors.black, // ✅ Dark text for better contrast on yellow
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    // ✅ Check if context is still valid
    if (!_isContextValid(context)) {
      print('⚠️ Cannot show SnackBar: Context is no longer valid');
      return;
    }

    _showCustomSnackBar(
      context,
      message,
      backgroundColor: AppColors.primaryBlue,
      icon: Icons.info,
    );
  }

  // ✅ Helper method to check if context is valid
  static bool _isContextValid(BuildContext context) {
    try {
      // Try to access the context - if it throws, context is invalid
      ScaffoldMessenger.of(context);
      return true;
    } catch (e) {
      return false;
    }
  }

  static void _showCustomSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: textColor ?? AppColors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: textColor ?? AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: duration,
          margin: const EdgeInsets.all(16),
          elevation: 4,
        ),
      );
    } catch (e) {
      print('❌ Error showing SnackBar: $e');
    }
  }

  // ✅ Clear all active snackbars
  static void clearSnackBars(BuildContext context) {
    if (_isContextValid(context)) {
      try {
        ScaffoldMessenger.of(context).clearSnackBars();
      } catch (e) {
        print('⚠️ Error clearing SnackBars: $e');
      }
    }
  }
}
