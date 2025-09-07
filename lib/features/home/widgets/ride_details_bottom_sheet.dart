import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_driver/core/provider/ride_provider.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/features/home/models/ride_request_model.dart';
import 'package:url_launcher/url_launcher.dart';

class RiderDetailsBottomSheet extends StatefulWidget {
  final RideRequest rideRequest;
  final VoidCallback onNavigate;
  final VoidCallback? onArrived;
  final VoidCallback? onStartRide;
  final VoidCallback? onCompleteRide;
  final bool isEnRouteToPickup;
  final bool isAtPickup;
  final bool isRideStarted;

  const RiderDetailsBottomSheet({
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
  State<RiderDetailsBottomSheet> createState() =>
      _RiderDetailsBottomSheetState();
}

class _RiderDetailsBottomSheetState extends State<RiderDetailsBottomSheet> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();
  String? _selectedReason;

  final double _minSheetSize = 0.20;
  final double _maxSheetSize = 0.8;

  final List<String> _cancelReasons = [
    "Rider is not at the pickup location",
    "Rider asked to cancel",
    "Wrong pickup location",
    "Cannot contact rider",
    "Vehicle issue",
    "Other",
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: _minSheetSize,
      minChildSize: _minSheetSize,
      maxChildSize: _maxSheetSize,
      snap: true,
      snapSizes: [_minSheetSize, _maxSheetSize],
      builder: (context, scrollController) {
        return Container(
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
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              _buildRiderInfo(),
              const SizedBox(height: 16),
              _buildActionButtons(),
              const SizedBox(height: 16),
              // Use AnimatedBuilder to listen to the controller's size
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // Check if the sheet is fully expanded
                  final isExpanded =
                      _controller.isAttached &&
                      _controller.size > (_maxSheetSize - 0.01);

                  // Use Visibility to show/hide the cancel section
                  return Visibility(
                    visible: isExpanded,
                    child: Column(
                      children: [
                        const Divider(),
                        const SizedBox(height: 16),
                        _buildCancelSection(),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRiderInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.lightGrey,
          backgroundImage:
              widget.rideRequest.riderProfileImageUrl != null
                  ? NetworkImage(widget.rideRequest.riderProfileImageUrl!)
                  : null,
          child:
              widget.rideRequest.riderProfileImageUrl == null
                  ? const Icon(Icons.person, color: AppColors.grey, size: 20)
                  : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.rideRequest.riderName,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'LKR ${widget.rideRequest.fareAmount.toStringAsFixed(2)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _makePhoneCall(widget.rideRequest.riderPhone),
          icon: const Icon(Icons.phone),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _sendMessage(widget.rideRequest.riderPhone),
          icon: const Icon(Icons.message),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (widget.isRideStarted) {
      return _buildCompleteRideButton();
    } else if (widget.isAtPickup) {
      return _buildStartRideButton();
    } else if (widget.isEnRouteToPickup) {
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
        onPressed: widget.onNavigate,
        icon: const Icon(Icons.navigation, color: Colors.white),
        label: Text(
          'Navigate to Pickup',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: AppButtonStyles.primaryButton,
      ),
    );
  }

  Widget _buildArrivedButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: widget.onArrived,
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
        onPressed: widget.onStartRide,
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
        onPressed: widget.onCompleteRide,
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

  Widget _buildCancelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Need to cancel?',
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._cancelReasons.map(
          (reason) => RadioListTile<String>(
            title: Text(reason),
            value: reason,
            groupValue: _selectedReason,
            onChanged: (value) {
              setState(() {
                _selectedReason = value;
              });
            },
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed:
                _selectedReason == null
                    ? null
                    : () {
                      final rideProvider = Provider.of<RideProvider>(
                        context,
                        listen: false,
                      );
                      rideProvider.declineRide();
                      print('Ride cancelled with reason: $_selectedReason');
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.lightGrey,
            ),
            child: const Text('Cancel Ride'),
          ),
        ),
      ],
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
