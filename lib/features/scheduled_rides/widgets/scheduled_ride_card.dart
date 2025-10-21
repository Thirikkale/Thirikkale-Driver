import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/features/scheduled_rides/models/card_models.dart';
import 'package:thirikkale_driver/features/scheduled_rides/models/scheduled_ride.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduledRideCard extends StatelessWidget {
  final ScheduledRide ride;
  final RiderCardModel? riderDetails;
  final bool showAssignButton;
  final bool showUnassignButton;
  final bool showNavigateButton;
  final bool showStartTripButton;
  final bool showEndTripButton;
  final VoidCallback? onAssign;
  final VoidCallback? onUnassign;
  final VoidCallback? onNavigate;
  final VoidCallback? onStartTrip;
  final VoidCallback? onEndTrip;
  final VoidCallback? onTap;

  const ScheduledRideCard({
    super.key,
    required this.ride,
    this.riderDetails,
    this.showAssignButton = false,
    this.showUnassignButton = false,
    this.showNavigateButton = false,
    this.showStartTripButton = false,
    this.showEndTripButton = false,
    this.onAssign,
    this.onUnassign,
    this.onNavigate,
    this.onStartTrip,
    this.onEndTrip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0, // We're handling shadow with Container
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.lightGrey.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Header with time and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildTimeSection(),
                  ),
                  _buildStatusBadge(),
                ],
              ),
              
              // Rider details section (only show if riderDetails available)
              if (riderDetails != null) ...[
                const SizedBox(height: 16),
                _buildRiderDetailsSection(),
              ],
              
              const SizedBox(height: 16),
              
              // Pickup location
              _buildLocationRow(
                icon: Icons.trip_origin,
                iconColor: AppColors.success,
                address: ride.pickupAddress,
                label: 'Pickup',
              ),
              
              // Dashed line between locations
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 4, bottom: 4),
                child: CustomPaint(
                  size: const Size(2, 30),
                  painter: DashedLinePainter(),
                ),
              ),
              
              // Dropoff location
              _buildLocationRow(
                icon: Icons.location_on,
                iconColor: AppColors.error,
                address: ride.dropoffAddress,
                label: 'Dropoff',
              ),
              
              const SizedBox(height: 16),
              
              // Ride details
              _buildRideDetails(),
              
              // Distance and fare info if available
              if (ride.distanceKm != null || ride.maxFare != null) ...[
                const SizedBox(height: 12),
                _buildDistanceAndFare(),
              ],
              
              // Action buttons
              if (showAssignButton || showUnassignButton || showNavigateButton || showStartTripButton || showEndTripButton) ...[
                const SizedBox(height: 16),
                _buildActionButtons(context),
              ],
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildTimeSection() {
    try {
      final scheduledDateTime = DateTime.parse(ride.scheduledTime);
      final timeStr = _formatTime(scheduledDateTime);
      final dateStr = _formatDate(scheduledDateTime);
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                timeStr,
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            dateStr,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    } catch (e) {
      return Text(
        ride.scheduledTime,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _formatDate(DateTime dateTime) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  Widget _buildStatusBadge() {
    Color statusColor;
    String statusText = ride.status;
    
    switch (ride.status.toUpperCase()) {
      case 'SCHEDULED':
        statusColor = AppColors.primaryBlue;
        break;
      case 'GROUPING':
        statusColor = AppColors.warning;
        break;
      case 'DISPATCHED':
        statusColor = AppColors.success;
        break;
      case 'COMPLETED':
        statusColor = AppColors.textSecondary;
        break;
      case 'CANCELLED':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.bodySmall.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRiderDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Profile picture or avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBlue.withOpacity(0.1),
              image: riderDetails?.profilePicUrl != null
                  ? DecorationImage(
                      image: NetworkImage(riderDetails!.profilePicUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: riderDetails?.profilePicUrl == null
                ? const Icon(
                    Icons.person,
                    size: 28,
                    color: AppColors.primaryBlue,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          
          // Rider info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Rider',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  riderDetails?.name ?? 'Loading...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (riderDetails?.contactNumber != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        riderDetails!.contactNumber,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Call button
          if (riderDetails?.contactNumber != null)
            IconButton(
              onPressed: () => _makePhoneCall(riderDetails!.contactNumber),
              icon: const Icon(Icons.phone, color: AppColors.success),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.success.withOpacity(0.1),
                padding: const EdgeInsets.all(8),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Remove any spaces, dashes, or formatting from the phone number
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final telUri = Uri(scheme: 'tel', path: cleanNumber);
    
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        print('❌ Cannot launch phone dialer for: $phoneNumber');
      }
    } catch (e) {
      print('❌ Error launching phone dialer: $e');
    }
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String address,
    required String label,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRideDetails() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        if (ride.vehicleType != null)
          _buildDetailChip(
            icon: Icons.directions_car,
            label: ride.vehicleType!,
            color: AppColors.primaryBlue,
          ),
        if (ride.passengers > 0)
          _buildDetailChip(
            icon: Icons.person,
            label: '${ride.passengers} ${ride.passengers == 1 ? 'passenger' : 'passengers'}',
            color: AppColors.textSecondary,
          ),
        if (ride.isSharedRide)
          _buildDetailChip(
            icon: Icons.people,
            label: 'Shared',
            color: AppColors.warning,
          ),
        if (ride.isWomenOnly == true)
          _buildDetailChip(
            icon: Icons.woman,
            label: 'Women Only',
            color: Colors.purple,
          ),
      ],
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceAndFare() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (ride.distanceKm != null || ride.rideDistanceKm != null)
            _buildInfoItem(
              icon: Icons.straighten,
              label: 'Distance',
              value: '${ride.rideDistanceKm ?? ride.distanceKm ?? 0} km',
            ),
          if (ride.maxFare != null)
            _buildInfoItem(
              icon: Icons.attach_money,
              label: 'Max Fare',
              value: 'Rs ${ride.maxFare!.toStringAsFixed(0)}',
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // Build list of buttons to display based on conditions
    final List<Widget> buttons = [];
    
    // For Nearby tab: Accept button
    if (showAssignButton) {
      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onAssign,
            icon: const Icon(Icons.check_circle_outline, size: 20),
            label: const Text('Accept Ride'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      );
    }
    
    // For Accepted tab with SCHEDULED status: Start Trip button
    if (showStartTripButton) {
      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onStartTrip,
            icon: const Icon(Icons.play_arrow, size: 20),
            label: const Text('Start Trip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      );
    }
    
    // For Accepted tab with ONGOING status: End Trip button
    if (showEndTripButton) {
      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onEndTrip,
            icon: const Icon(Icons.flag, size: 20),
            label: const Text('End Trip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      );
    }
    
    // Navigate button (available for accepted rides)
    if (showNavigateButton) {
      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onNavigate,
            icon: const Icon(Icons.navigation, size: 20),
            label: const Text('Navigate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      );
    }
    
    // Cancel button (only shown when ride is not ONGOING)
    if (showUnassignButton) {
      buttons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onUnassign,
            icon: const Icon(Icons.cancel_outlined, size: 20),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      );
    }
    
    // Join buttons with spacing
    final List<Widget> rowChildren = [];
    for (int i = 0; i < buttons.length; i++) {
      if (i > 0) {
        rowChildren.add(const SizedBox(width: 12));
      }
      rowChildren.add(buttons[i]);
    }
    
    return Row(children: rowChildren);
  }
}

// Custom painter for dashed line between locations
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSecondary.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 4;
    const dashSpace = 3;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
