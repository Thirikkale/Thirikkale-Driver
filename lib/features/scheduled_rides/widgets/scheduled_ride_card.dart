import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/features/scheduled_rides/models/scheduled_ride.dart';

class ScheduledRideCard extends StatelessWidget {
  final ScheduledRide ride;
  final bool showAssignButton;
  final bool showUnassignButton;
  final bool showNavigateButton;
  final VoidCallback? onAssign;
  final VoidCallback? onUnassign;
  final VoidCallback? onNavigate;
  final VoidCallback? onTap;

  const ScheduledRideCard({
    super.key,
    required this.ride,
    this.showAssignButton = false,
    this.showUnassignButton = false,
    this.showNavigateButton = false,
    this.onAssign,
    this.onUnassign,
    this.onNavigate,
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
              if (showAssignButton || showUnassignButton || showNavigateButton) ...[
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
    return Row(
      children: [
        if (showAssignButton)
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
        if (showNavigateButton) ...[
          if (showUnassignButton) const SizedBox(width: 12),
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
        ],
        if (showUnassignButton) ...[
          if (showNavigateButton) const SizedBox(width: 12),
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
        ],
      ],
    );
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
