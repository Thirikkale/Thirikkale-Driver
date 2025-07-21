import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/widgets/error_message.dart';

class NetworkErrorWidget extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry? margin;

  const NetworkErrorWidget({
    super.key,
    this.errorMessage,
    this.onRetry,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null) return const SizedBox.shrink();

    return ErrorMessageWidget(
      message: errorMessage!,
      onRetry: onRetry,
      retryText: 'Retry',
      icon: Icons.wifi_off,
      backgroundColor: AppColors.warning.withOpacity(0.9),
      margin: margin,
    );
  }
}
