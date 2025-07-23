import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/features/home/models/ride_request_model.dart';

class RideActionButtons extends StatelessWidget {
  final RideRequest rideRequest;
  final VoidCallback onNavigate;
  final VoidCallback? onArrived;
  final VoidCallback? onStartRide;
  final VoidCallback? onCompleteRide;
  final bool isEnRouteToPickup;
  final bool isAtPickup;
  final bool isRideStarted;

  const RideActionButtons({
    super.key,
    required this.rideRequest,
    required this.onNavigate,
    this.onArrived,
    this.onStartRide,
    this.onCompleteRide,
    this.isEnRouteToPickup = false,
    this.isAtPickup = false,
    this.isRideStarted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rider info row
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.lightGrey,
                  backgroundImage:
                      rideRequest.riderProfileImageUrl != null
                          ? NetworkImage(rideRequest.riderProfileImageUrl!)
                          : null,
                  child:
                      rideRequest.riderProfileImageUrl == null
                          ? Icon(
                            Icons.person,
                            color: AppColors.grey,
                            size: 20,
                          )
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rideRequest.riderName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'LKR ${rideRequest.fareAmount.toStringAsFixed(2)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Call button
                IconButton(
                  onPressed: () => _makePhoneCall(rideRequest.riderPhone),
                  icon: const Icon(Icons.phone),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                // Message button
                IconButton(
                  onPressed: () => _sendMessage(rideRequest.riderPhone),
                  icon: const Icon(Icons.message),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action buttons based on ride status
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (isRideStarted) {
      return _buildCompleteRideButton();
    } else if (isAtPickup) {
      return _buildStartRideButton();
    } else if (isEnRouteToPickup) {
      return _buildArrivedButton();
    } else {
      return _buildNavigateButton();
    }
  }

  Widget _buildNavigateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onNavigate,
        icon: const Icon(Icons.navigation, color: Colors.white),
        label: Text(
          'Navigate to Pickup',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  Widget _buildArrivedButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onArrived,
        icon: const Icon(Icons.location_on, color: Colors.white),
        label: Text(
          'I\'ve Arrived',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  Widget _buildStartRideButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onStartRide,
        icon: const Icon(Icons.play_arrow, color: Colors.white),
        label: Text(
          'Start Ride',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteRideButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onCompleteRide,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        label: Text(
          'Complete Ride',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _sendMessage(String phoneNumber) async {
    final Uri smsUri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }
}
