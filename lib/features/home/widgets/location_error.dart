import 'package:flutter/material.dart';
import 'package:thirikkale_driver/widgets/error_message.dart';

class LocationErrorWidget extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry? margin;

  const LocationErrorWidget({
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
      icon: Icons.location_off,
      margin: margin,
    );
  }
}
