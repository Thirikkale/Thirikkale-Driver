import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_driver/core/provider/driver_provider.dart';
import 'package:thirikkale_driver/features/home/widgets/sliding_go_button.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';

class OnlineDriverBottomSheet extends StatefulWidget {
  final DraggableScrollableController controller;
  final VoidCallback onToggleOnlineStatus;

  const OnlineDriverBottomSheet({
    super.key,
    required this.controller,
    required this.onToggleOnlineStatus,
  });

  @override
  State<OnlineDriverBottomSheet> createState() =>
      _OnlineDriverBottomSheetState();
}

class _OnlineDriverBottomSheetState extends State<OnlineDriverBottomSheet> {
  // Define the three snapping points for the sheet
  final double _minSheetSize = 0.10;
  final double _midSheetSize = 0.42;
  final double _maxSheetSize = 0.8;

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverProvider>(
      builder: (context, driverProvider, child) {
        return DraggableScrollableSheet(
          controller: widget.controller,
          initialChildSize: _midSheetSize,
          minChildSize: _minSheetSize,
          maxChildSize: _maxSheetSize,
          snap: true,
          snapSizes: [_minSheetSize, _midSheetSize, _maxSheetSize],
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: widget.controller,
                builder: (context, child) {
                  final isExpanded =
                      widget.controller.isAttached &&
                      widget.controller.size > (_midSheetSize - 0.1);

                  return ListView(
                    controller: scrollController,
                    padding: EdgeInsets.zero,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "You're Online",
                            style: AppTextStyles.heading2,
                          ),
                        ),
                      ),
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.pageHorizontalPadding,
                          ),
                          child: Column(
                            children: [
                              const Divider(),
                              const SizedBox(height: 10),
                              ListTile(
                                leading: const Icon(
                                  Icons.bar_chart,
                                  color: AppColors.textPrimary,
                                ),
                                title: Text(
                                  'View Earnings',
                                  style: AppTextStyles.bodyLarge,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () {
                                  // TODO: Navigate to earnings page
                                },
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.settings,
                                  color: AppColors.textPrimary,
                                ),
                                title: Text(
                                  'Trip Settings',
                                  style: AppTextStyles.bodyLarge,
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () {
                                  // TODO: Navigate to settings
                                },
                              ),
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 20),
                              SlidingGoButton(
                                isOnline: true,
                                isLoading: driverProvider.isSettingAvailability,
                                onToggle:
                                    widget
                                        .onToggleOnlineStatus, 
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
