import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar_name.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final double _commissionRate = 0.15; // 15% commission
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Card', 'Cash', 'Today', 'This Week'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppbarName(title: 'Trips', showBackButton: true),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildTripsStats(),
          Expanded(child: _buildTripsList()),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              selected: isSelected,
              label: Text(filter),
              onSelected: (selected) {
                setState(() => _selectedFilter = filter);
              },
              backgroundColor: AppColors.white,
              selectedColor: AppColors.primaryBlue.withOpacity(0.1),
              labelStyle: TextStyle(
                color:
                    isSelected
                        ? AppColors.primaryBlue
                        : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primaryBlue : AppColors.lightGrey,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTripsStats() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalPadding,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem('Total Trips', '28', Icons.route),
          _buildStatDivider(),
          _buildStatItem('Card Trips', '18', Icons.credit_card),
          _buildStatDivider(),
          _buildStatItem('Cash Trips', '10', Icons.money),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.lightGrey,
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildTripsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
      itemCount: 15, // More trips for dedicated screen
      itemBuilder: (context, index) => _buildTripCard(index),
    );
  }

  Widget _buildTripCard(int index) {
    final trips = [
      {
        'from': 'Colombo Fort',
        'to': 'Mount Lavinia',
        'fare': '450',
        'time': '9:30 AM',
        'distance': '12.5 km',
        'duration': '28 min',
        'paymentMethod': 'Card',
      },
      {
        'from': 'Dehiwala',
        'to': 'Bambalapitiya',
        'fare': '320',
        'time': '11:15 AM',
        'distance': '8.2 km',
        'duration': '22 min',
        'paymentMethod': 'Cash',
      },
      {
        'from': 'Wellawatta',
        'to': 'Kollupitiya',
        'fare': '280',
        'time': '2:45 PM',
        'distance': '6.8 km',
        'duration': '18 min',
        'paymentMethod': 'Card',
      },
      {
        'from': 'Galle Face',
        'to': 'Nugegoda',
        'fare': '520',
        'time': '5:20 PM',
        'distance': '15.3 km',
        'duration': '35 min',
        'paymentMethod': 'Cash',
      },
      {
        'from': 'Maharagama',
        'to': 'Pettah',
        'fare': '380',
        'time': '7:10 PM',
        'distance': '11.2 km',
        'duration': '25 min',
        'paymentMethod': 'Card',
      },
    ];

    final trip = trips[index % trips.length];
    final fare = double.parse(trip['fare']!);
    final isCard = trip['paymentMethod'] == 'Card';
    final commission = fare * _commissionRate;
    final driverEarning = isCard ? fare - commission : fare;
    final commissionStatus =
        isCard
            ? 'Company pays commission'
            : 'You owe LKR ${commission.toStringAsFixed(0)} commission';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isCard
                  ? AppColors.primaryBlue.withOpacity(0.3)
                  : AppColors.success.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showTripDetails(trip, index),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isCard
                                ? AppColors.primaryBlue
                                : AppColors.success)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isCard ? Icons.credit_card : Icons.money,
                        color:
                            isCard ? AppColors.primaryBlue : AppColors.success,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${trip['from']} → ${trip['to']}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                trip['time']!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.straighten,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                trip['distance']!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.timer,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                trip['duration']!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'LKR ${trip['fare']}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (isCard
                                    ? AppColors.primaryBlue
                                    : AppColors.success)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            trip['paymentMethod']!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color:
                                  isCard
                                      ? AppColors.primaryBlue
                                      : AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Earnings',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'LKR ${driverEarning.toStringAsFixed(0)}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Text(
                          commissionStatus,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isCard ? AppColors.success : AppColors.error,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTripDetails(Map<String, String> trip, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Trip Details',
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                              'Route',
                              '${trip['from']} → ${trip['to']}',
                            ),
                            _buildDetailRow('Trip Time', trip['time']!),
                            _buildDetailRow('Distance', trip['distance']!),
                            _buildDetailRow('Duration', trip['duration']!),
                            _buildDetailRow(
                              'Payment Method',
                              trip['paymentMethod']!,
                            ),
                            _buildDetailRow(
                              'Total Fare',
                              'LKR ${trip['fare']}',
                            ),
                            const SizedBox(height: 20),
                            // Add more trip details here as needed
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.lightGrey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Trip Summary',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'This trip was completed successfully with ${trip['paymentMethod']!.toLowerCase()} payment.',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
