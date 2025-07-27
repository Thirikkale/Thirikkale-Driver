import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/bottom_sheet_helper.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/core/utils/snackbar_helper.dart';

/// Example usage of BottomSheetHelper
class BottomSheetExamples {
  
  /// Example: Basic bottom sheet with custom content
  static void showBasicExample(BuildContext context) {
    BottomSheetHelper.showBasicBottomSheet(
      context: context,
      title: 'Basic Bottom Sheet',
      content: Column(
        children: [
          const Text('This is a basic bottom sheet with custom content.'),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Enter some text',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        const BottomSheetAction(
          text: 'Cancel',
          isOutlined: true,
        ),
        BottomSheetAction(
          text: 'Save',
          onPressed: () {
            SnackbarHelper.showSuccessSnackBar(
              context,
              'Data saved successfully!',
            );
          },
        ),
      ],
    );
  }

  /// Example: Confirmation dialog
  static void showConfirmationExample(BuildContext context) {
    BottomSheetHelper.showConfirmationBottomSheet(
      context: context,
      title: 'Delete Item',
      content: 'Are you sure you want to delete this item? This action cannot be undone.',
      icon: Icons.delete_outline,
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmButtonColor: AppColors.error,
      onConfirm: () {
        SnackbarHelper.showSuccessSnackBar(
          context,
          'Item deleted successfully!',
        );
      },
      onCancel: () {
        SnackbarHelper.showInfoSnackBar(
          context,
          'Deletion cancelled',
        );
      },
    );
  }

  /// Example: Selection bottom sheet
  static void showSelectionExample(BuildContext context) {
    final vehicleTypes = [
      const BottomSheetOption(
        title: 'Car',
        subtitle: 'Standard 4-seater vehicle',
        icon: Icons.directions_car,
        value: 'car',
      ),
      const BottomSheetOption(
        title: 'Motorcycle',
        subtitle: 'Fast delivery option',
        icon: Icons.motorcycle,
        value: 'motorcycle',
      ),
      const BottomSheetOption(
        title: 'Truck',
        subtitle: 'Large cargo capacity',
        icon: Icons.local_shipping,
        value: 'truck',
      ),
      const BottomSheetOption(
        title: 'Van',
        subtitle: 'Medium cargo capacity',
        icon: Icons.airport_shuttle,
        value: 'van',
      ),
    ];

    BottomSheetHelper.showSelectionBottomSheet<String>(
      context: context,
      title: 'Select Vehicle Type',
      subtitle: 'Choose your preferred vehicle type',
      options: vehicleTypes,
      showSearch: true,
    ).then((selectedValue) {
      if (selectedValue != null) {
        SnackbarHelper.showSuccessSnackBar(
          context,
          'Selected: ${selectedValue.toUpperCase()}',
        );
      }
    });
  }

  /// Example: Action sheet
  static void showActionSheetExample(BuildContext context) {
    final actions = [
      const ActionSheetOption(
        title: 'Edit Profile',
        subtitle: 'Modify your driver information',
        icon: Icons.edit,
        value: 'edit',
      ),
      const ActionSheetOption(
        title: 'Share Profile',
        subtitle: 'Share your driver profile',
        icon: Icons.share,
        value: 'share',
      ),
      const ActionSheetOption(
        title: 'Report Issue',
        subtitle: 'Report a problem with your account',
        icon: Icons.report_problem,
        value: 'report',
      ),
      const ActionSheetOption(
        title: 'Delete Account',
        subtitle: 'Permanently delete your account',
        icon: Icons.delete_forever,
        value: 'delete',
        isDestructive: true,
      ),
    ];

    BottomSheetHelper.showActionSheet<String>(
      context: context,
      title: 'Account Options',
      subtitle: 'Choose an action for your account',
      options: actions,
    ).then((selectedAction) {
      if (selectedAction != null) {
        switch (selectedAction) {
          case 'edit':
            SnackbarHelper.showInfoSnackBar(context, 'Opening edit profile...');
            break;
          case 'share':
            SnackbarHelper.showInfoSnackBar(context, 'Opening share options...');
            break;
          case 'report':
            SnackbarHelper.showInfoSnackBar(context, 'Opening report form...');
            break;
          case 'delete':
            _showDeleteConfirmation(context);
            break;
        }
      }
    });
  }

  /// Example: Payment card details bottom sheet
  static void showPaymentCardExample(BuildContext context) {
    BottomSheetHelper.showBasicBottomSheet(
      context: context,
      title: 'Add Payment Card',
      content: _buildPaymentCardForm(),
      actions: [
        const BottomSheetAction(
          text: 'Cancel',
          isOutlined: true,
        ),
        BottomSheetAction(
          text: 'Add Card',
          onPressed: () {
            SnackbarHelper.showSuccessSnackBar(
              context,
              'Payment card added successfully!',
            );
          },
        ),
      ],
      maxHeight: MediaQuery.of(context).size.height * 0.8,
    );
  }

  /// Example: Draggable bottom sheet
  static void showDraggableExample(BuildContext context) {
    BottomSheetHelper.showDraggableBottomSheet(
      context: context,
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Draggable Bottom Sheet',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            const Text(
              'This is a draggable bottom sheet. You can drag it up and down to resize it.',
            ),
            const SizedBox(height: 20),
            ...List.generate(
              20,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Item ${index + 1}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Example: Custom bottom sheet
  static void showCustomExample(BuildContext context) {
    BottomSheetHelper.showCustomBottomSheet(
      context: context,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.primaryBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              size: 48,
              color: AppColors.white,
            ),
            const SizedBox(height: 16),
            Text(
              'Custom Bottom Sheet',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This is a custom bottom sheet with gradient background.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                SnackbarHelper.showSuccessSnackBar(
                  context,
                  'Custom action completed!',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primaryBlue,
              ),
              child: const Text('Take Action'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static Widget _buildPaymentCardForm() {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Card Number',
            hintText: '1234 5678 9012 3456',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.credit_card),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'MM/YY',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Card Holder Name',
            hintText: 'John Doe',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(value: false, onChanged: (value) {}),
            const Expanded(
              child: Text(
                'Save this card for future payments',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static void _showDeleteConfirmation(BuildContext context) {
    BottomSheetHelper.showConfirmationBottomSheet(
      context: context,
      title: 'Delete Account',
      content: 'This action is permanent and cannot be undone. All your data will be lost.',
      icon: Icons.warning,
      confirmText: 'Delete Forever',
      cancelText: 'Keep Account',
      confirmButtonColor: AppColors.error,
      onConfirm: () {
        SnackbarHelper.showErrorSnackBar(
          context,
          'Account deletion initiated',
        );
      },
    );
  }
}
