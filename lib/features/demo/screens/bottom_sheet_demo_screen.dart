import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/bottom_sheet_examples.dart';

/// Demo screen to showcase all bottom sheet types
class BottomSheetDemoScreen extends StatelessWidget {
  const BottomSheetDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bottom Sheet Examples'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bottom Sheet Examples',
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap on any button below to see different types of bottom sheets in action.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: [
                    _buildDemoButton(
                      context: context,
                      title: 'Basic Bottom Sheet',
                      subtitle: 'Basic content with actions',
                      icon: Icons.menu,
                      onTap: () => BottomSheetExamples.showBasicExample(context),
                    ),
                    const SizedBox(height: 16),
                    _buildDemoButton(
                      context: context,
                      title: 'Confirmation Dialog',
                      subtitle: 'Confirm/cancel actions',
                      icon: Icons.help_outline,
                      onTap: () => BottomSheetExamples.showConfirmationExample(context),
                    ),
                    const SizedBox(height: 16),
                    _buildDemoButton(
                      context: context,
                      title: 'Selection List',
                      subtitle: 'Choose from options with search',
                      icon: Icons.list,
                      onTap: () => BottomSheetExamples.showSelectionExample(context),
                    ),
                    const SizedBox(height: 16),
                    _buildDemoButton(
                      context: context,
                      title: 'Action Sheet',
                      subtitle: 'Multiple action options',
                      icon: Icons.more_vert,
                      onTap: () => BottomSheetExamples.showActionSheetExample(context),
                    ),
                    const SizedBox(height: 16),
                    _buildDemoButton(
                      context: context,
                      title: 'Payment Card Form',
                      subtitle: 'Card details input form',
                      icon: Icons.credit_card,
                      onTap: () => BottomSheetExamples.showPaymentCardExample(context),
                    ),
                    const SizedBox(height: 16),
                    _buildDemoButton(
                      context: context,
                      title: 'Draggable Sheet',
                      subtitle: 'Resizable content area',
                      icon: Icons.drag_handle,
                      onTap: () => BottomSheetExamples.showDraggableExample(context),
                    ),
                    const SizedBox(height: 16),
                    _buildDemoButton(
                      context: context,
                      title: 'Custom Design',
                      subtitle: 'Fully customized appearance',
                      icon: Icons.palette,
                      onTap: () => BottomSheetExamples.showCustomExample(context),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
