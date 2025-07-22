import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';

/// A utility class for showing various types of bottom sheets consistently throughout the app
class BottomSheetHelper {
  /// Shows a basic bottom sheet with a title and content
  static Future<T?> showBasicBottomSheet<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<BottomSheetAction>? actions,
    bool showHandle = true,
    bool isScrollControlled = true,
    bool isDismissible = true,
    double? maxHeight,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => _BasicBottomSheet(
        title: title,
        content: content,
        actions: actions,
        showHandle: showHandle,
        maxHeight: maxHeight,
      ),
    );
  }

  /// Shows a confirmation bottom sheet with custom actions
  static Future<bool?> showConfirmationBottomSheet({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmButtonColor,
    IconData? icon,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => _ConfirmationBottomSheet(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmButtonColor: confirmButtonColor,
        icon: icon,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  /// Shows a list selection bottom sheet
  static Future<T?> showSelectionBottomSheet<T>({
    required BuildContext context,
    required String title,
    required List<BottomSheetOption<T>> options,
    String? subtitle,
    bool isDismissible = true,
    bool showSearch = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => _SelectionBottomSheet<T>(
        title: title,
        subtitle: subtitle,
        options: options,
        showSearch: showSearch,
      ),
    );
  }

  /// Shows an action sheet with multiple action options
  static Future<T?> showActionSheet<T>({
    required BuildContext context,
    required String title,
    required List<ActionSheetOption<T>> options,
    String? subtitle,
    bool isDismissible = true,
    bool showCancel = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => _ActionSheet<T>(
        title: title,
        subtitle: subtitle,
        options: options,
        showCancel: showCancel,
      ),
    );
  }

  /// Shows a custom bottom sheet with full control over content
  static Future<T?> showCustomBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
    Color? backgroundColor,
    double? maxHeight,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: backgroundColor ?? Colors.transparent,
      builder: (context) => Container(
        constraints: maxHeight != null
            ? BoxConstraints(maxHeight: maxHeight)
            : null,
        child: child,
      ),
    );
  }

  /// Shows a draggable scrollable bottom sheet
  static Future<T?> showDraggableBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    double initialChildSize = 0.5,
    double minChildSize = 0.25,
    double maxChildSize = 0.9,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        builder: (context, scrollController) => Container(
          // Add solid white background to prevent see-through
          color: Colors.white,
          child: SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  _buildHandle(),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget for basic bottom sheet layout
class _BasicBottomSheet extends StatelessWidget {
  final String title;
  final Widget content;
  final List<BottomSheetAction>? actions;
  final bool showHandle;
  final double? maxHeight;

  const _BasicBottomSheet({
    required this.title,
    required this.content,
    this.actions,
    this.showHandle = true,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Add solid white background to prevent see-through with border radius
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Container(
          constraints: maxHeight != null
              ? BoxConstraints(maxHeight: maxHeight!)
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHandle) _buildHandle(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pageHorizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    const SizedBox(height: 20),
                    content,
                    if (actions != null && actions!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildActions(context),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: AppTextStyles.heading3,
    );
  }

  Widget _buildActions(BuildContext context) {
    if (actions == null || actions!.isEmpty) return const SizedBox.shrink();

    if (actions!.length == 1) {
      return SizedBox(
        width: double.infinity,
        child: _buildActionButton(context, actions!.first),
      );
    }

    return Row(
      children: actions!.asMap().entries.map((entry) {
        final index = entry.key;
        final action = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index > 0 ? 8 : 0,
              right: index < actions!.length - 1 ? 8 : 0,
            ),
            child: _buildActionButton(context, action),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(BuildContext context, BottomSheetAction action) {
    if (action.isOutlined) {
      return OutlinedButton(
        onPressed: () {
          Navigator.pop(context);
          action.onPressed?.call();
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: action.color ?? AppColors.primaryBlue),
          foregroundColor: action.color ?? AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(action.text),
      );
    }

    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        action.onPressed?.call();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: action.color ?? AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(action.text),
    );
  }
}

/// Widget for confirmation bottom sheet
class _ConfirmationBottomSheet extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final Color? confirmButtonColor;
  final IconData? icon;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const _ConfirmationBottomSheet({
    required this.title,
    required this.content,
    required this.confirmText,
    required this.cancelText,
    this.confirmButtonColor,
    this.icon,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Add solid white background to prevent see-through with border radius
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pageHorizontalPadding,
              ),
              child: Column(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 48,
                      color: confirmButtonColor ?? AppColors.primaryBlue,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    title,
                    style: AppTextStyles.heading3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                            onCancel?.call();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.lightGrey),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            cancelText,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                            onConfirm?.call();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: confirmButtonColor ?? AppColors.primaryBlue,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(confirmText),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for selection bottom sheet
class _SelectionBottomSheet<T> extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<BottomSheetOption<T>> options;
  final bool showSearch;

  const _SelectionBottomSheet({
    required this.title,
    required this.options,
    this.subtitle,
    this.showSearch = false,
  });

  @override
  State<_SelectionBottomSheet<T>> createState() => _SelectionBottomSheetState<T>();
}

class _SelectionBottomSheetState<T> extends State<_SelectionBottomSheet<T>> {
  late List<BottomSheetOption<T>> filteredOptions;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredOptions = widget.options;
  }

  void _filterOptions(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredOptions = widget.options;
      } else {
        filteredOptions = widget.options.where((option) {
          return option.title.toLowerCase().contains(query.toLowerCase()) ||
              (option.subtitle?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Add solid white background to prevent see-through with border radius
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              _buildHandle(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pageHorizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTextStyles.heading3,
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.subtitle!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (widget.showSearch) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: _filterOptions,
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredOptions.length,
                  itemBuilder: (context, index) {
                    final option = filteredOptions[index];
                    return ListTile(
                      leading: option.icon != null
                          ? Icon(option.icon, color: option.iconColor)
                          : null,
                      title: Text(
                        option.title,
                        style: AppTextStyles.bodyLarge,
                      ),
                      subtitle: option.subtitle != null
                          ? Text(
                              option.subtitle!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(context, option.value);
                        option.onTap?.call();
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
        ),
      ),
    );
  }
}

/// Widget for action sheet
class _ActionSheet<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<ActionSheetOption<T>> options;
  final bool showCancel;

  const _ActionSheet({
    required this.title,
    required this.options,
    this.subtitle,
    this.showCancel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Add solid white background to prevent see-through with border radius
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              _buildHandle(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pageHorizontalPadding,
                ),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.heading3,
                      textAlign: TextAlign.center,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              ...options.map((option) => _buildActionOption(context, option)),
              if (showCancel) ...[
                const Divider(height: 1),
                ListTile(
                  title: Text(
                    'Cancel',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ],
              const SizedBox(height: 16),
            ],
        ),
      ),
    );
  }

  Widget _buildActionOption(BuildContext context, ActionSheetOption<T> option) {
    return Column(
      children: [
        ListTile(
          leading: option.icon != null
              ? Icon(
                  option.icon,
                  color: option.isDestructive
                      ? AppColors.error
                      : (option.iconColor ?? AppColors.primaryBlue),
                )
              : null,
          title: Text(
            option.title,
            style: AppTextStyles.bodyLarge.copyWith(
              color: option.isDestructive
                  ? AppColors.error
                  : AppColors.textPrimary,
            ),
          ),
          subtitle: option.subtitle != null
              ? Text(
                  option.subtitle!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
              : null,
          onTap: () {
            Navigator.pop(context, option.value);
            option.onTap?.call();
          },
        ),
        if (option != options.last) const Divider(height: 1),
      ],
    );
  }
}

/// Helper function to build the draggable handle
Widget _buildHandle() {
  return Container(
    width: 40,
    height: 4,
    margin: const EdgeInsets.only(top: 12, bottom: 20),
    decoration: BoxDecoration(
      color: AppColors.lightGrey,
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

/// Model classes for bottom sheet options and actions
class BottomSheetAction {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isOutlined;

  const BottomSheetAction({
    required this.text,
    this.onPressed,
    this.color,
    this.isOutlined = false,
  });
}

class BottomSheetOption<T> {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final T value;
  final VoidCallback? onTap;

  const BottomSheetOption({
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.onTap,
  });
}

class ActionSheetOption<T> {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final T value;
  final VoidCallback? onTap;
  final bool isDestructive;

  const ActionSheetOption({
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.onTap,
    this.isDestructive = false,
  });
}
