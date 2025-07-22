import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_driver/features/earnings/widgets/earnings_navigation_panel.dart';

class TripsPaymentScreen extends StatefulWidget {
  const TripsPaymentScreen({super.key});

  @override
  State<TripsPaymentScreen> createState() => _TripsPaymentScreenState();
}

class _TripsPaymentScreenState extends State<TripsPaymentScreen> {
  String _selectedPeriod = 'Today';
  final List<String> _periods = [
    'Today',
    'This Week',
    'This Month',
    'All Time',
  ];
  String _selectedPaymentFilter = 'All';
  final List<String> _paymentFilters = ['All', 'Card', 'Cash'];

  final double _commissionRate = 0.15; // 15% commission

  // Mock trip data with comprehensive details
  final List<Map<String, dynamic>> _trips = [
    {
      'id': 'TR001',
      'from': 'Colombo Fort Railway Station',
      'to': 'Mount Lavinia Beach Resort',
      'fare': 650.00,
      'distance': '15.2 km',
      'duration': '32 min',
      'paymentMethod': 'Card',
      'completedTime': '09:45 AM',
      'completedDate': 'Today',
      'fullDate': 'July 22, 2025',
      'status': 'Completed',
      'customerRating': 4.8,
      'tip': 50.0,
      'riderCount': 2,
    },
    {
      'id': 'TR002',
      'from': 'Dehiwala Junction',
      'to': 'Bambalapitiya Plaza',
      'fare': 420.00,
      'distance': '8.7 km',
      'duration': '24 min',
      'paymentMethod': 'Cash',
      'completedTime': '11:20 AM',
      'completedDate': 'Today',
      'fullDate': 'July 22, 2025',
      'status': 'Completed',
      'customerRating': 5.0,
      'tip': 0.0,
      'riderCount': 1,
    },
    {
      'id': 'TR003',
      'from': 'Wellawatta Market',
      'to': 'Kollupitiya Commercial Hub',
      'fare': 380.00,
      'distance': '6.4 km',
      'duration': '18 min',
      'paymentMethod': 'Card',
      'completedTime': '02:15 PM',
      'completedDate': 'Today',
      'fullDate': 'July 22, 2025',
      'status': 'Completed',
      'customerRating': 4.5,
      'tip': 25.0,
      'riderCount': 3,
    },
    {
      'id': 'TR004',
      'from': 'Galle Face Green',
      'to': 'Nugegoda Shopping Complex',
      'fare': 580.00,
      'distance': '12.8 km',
      'duration': '28 min',
      'paymentMethod': 'Cash',
      'completedTime': '04:30 PM',
      'completedDate': 'Today',
      'fullDate': 'July 22, 2025',
      'status': 'Completed',
      'customerRating': 4.7,
      'tip': 30.0,
      'riderCount': 2,
    },
    {
      'id': 'TR005',
      'from': 'Maharagama Town',
      'to': 'Pettah Central Market',
      'fare': 490.00,
      'distance': '11.5 km',
      'duration': '26 min',
      'paymentMethod': 'Card',
      'completedTime': '06:45 PM',
      'completedDate': 'Yesterday',
      'fullDate': 'July 21, 2025',
      'status': 'Completed',
      'customerRating': 4.9,
      'tip': 40.0,
      'riderCount': 1,
    },
  ];

  List<Map<String, dynamic>> get _filteredTrips {
    return _trips.where((trip) {
      if (_selectedPaymentFilter == 'All') return true;
      return trip['paymentMethod'] == _selectedPaymentFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppbarName(
        title: 'Trip Payments',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 16),
            _buildPaymentFilter(),
            const SizedBox(height: 20),
            _buildTripsList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => EarningsNavigationPanel.show(context),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.payment, color: AppColors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children:
            _periods.map((period) {
              final isSelected = period == _selectedPeriod;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPeriod = period),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.primaryBlue
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      period,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color:
                            isSelected
                                ? AppColors.white
                                : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildPaymentFilter() {
    return Container(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _paymentFilters.length,
        itemBuilder: (context, index) {
          final filter = _paymentFilters[index];
          final isSelected = filter == _selectedPaymentFilter;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (filter != 'All') ...[
                    Icon(
                      filter == 'Card' ? Icons.credit_card : Icons.money,
                      size: 16,
                      color:
                          isSelected
                              ? AppColors.primaryBlue
                              : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(filter),
                ],
              ),
              onSelected: (selected) {
                setState(() => _selectedPaymentFilter = filter);
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

  Widget _buildTripsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trip Details',
              style: AppTextStyles.heading3.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_filteredTrips.length} trips',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredTrips.length,
          itemBuilder:
              (context, index) => _buildTripCard(_filteredTrips[index]),
        ),
      ],
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final isCard = trip['paymentMethod'] == 'Card';
    final totalAmount = (trip['fare'] as double) + (trip['tip'] as double);

    String formatCurrency(double amount) {
      return 'LKR ${amount.toStringAsFixed(2)}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isCard
                  ? AppColors.primaryBlue.withOpacity(0.2)
                  : AppColors.success.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Trip Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trip ID and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Trip ${trip['id']}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${trip['riderCount']} ${trip['riderCount'] == 1 ? 'rider' : 'riders'}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        trip['status'],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Route Information
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PICKUP',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  trip['from'],
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 6,
                        ),
                        width: 2,
                        height: 20,
                        color: AppColors.lightGrey,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DESTINATION',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  trip['to'],
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Trip Details
                Row(
                  children: [
                    Expanded(
                      child: _buildTripDetailItem(
                        Icons.straighten,
                        'Distance',
                        trip['distance'],
                        AppColors.primaryBlue,
                      ),
                    ),
                    Expanded(
                      child: _buildTripDetailItem(
                        Icons.timer,
                        'Duration',
                        trip['duration'],
                        AppColors.success,
                      ),
                    ),
                    Expanded(
                      child: _buildTripDetailItem(
                        Icons.people,
                        'Riders',
                        '${trip['riderCount']} ${trip['riderCount'] == 1 ? 'rider' : 'riders'}',
                        AppColors.warning,
                      ),
                    ),
                    Expanded(
                      child: _buildTripDetailItem(
                        Icons.star,
                        'Rating',
                        '${trip['customerRating']}⭐',
                        AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Payment Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (isCard ? AppColors.primaryBlue : AppColors.success)
                  .withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                isCard
                                    ? AppColors.primaryBlue
                                    : AppColors.success,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${trip['paymentMethod']} Payment',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    isCard
                                        ? AppColors.primaryBlue
                                        : AppColors.success,
                              ),
                            ),
                            Text(
                              '${trip['completedDate']} • ${trip['completedTime']}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatCurrency(totalAmount),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontSize: 18,
                          ),
                        ),
                        if (trip['tip'] > 0)
                          Text(
                            '+${formatCurrency(trip['tip'])} tip',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Payment Breakdown
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.lightGrey.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Trip Fare', style: AppTextStyles.bodySmall),
                          Text(
                            formatCurrency(trip['fare']),
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (trip['tip'] > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Customer Tip',
                              style: AppTextStyles.bodySmall,
                            ),
                            Text(
                              formatCurrency(trip['tip']),
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (!isCard) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Commission (${(_commissionRate * 100).toInt()}%)',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                            Text(
                              '-${formatCurrency((trip['fare'] as double) * _commissionRate)}',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Earnings',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            formatCurrency(
                              isCard
                                  ? totalAmount
                                  : totalAmount -
                                      ((trip['fare'] as double) *
                                          _commissionRate),
                            ),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetailItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
