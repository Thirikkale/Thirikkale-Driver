import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/features/earnings/widgets/earnings_navigation_panel.dart';

class EarningsHistoryScreen extends StatefulWidget {
  const EarningsHistoryScreen({super.key});

  @override
  State<EarningsHistoryScreen> createState() => _EarningsHistoryScreenState();
}

class _EarningsHistoryScreenState extends State<EarningsHistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'This Week',
    'This Month',
    'Last Month',
    'Custom',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterChips(),
          _buildSummaryCards(),
          Expanded(child: _buildHistoryList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => EarningsNavigationPanel.show(context),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.menu, color: AppColors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return const CustomAppbarName(
      title: 'Earnings History',
      showBackButton: true,
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    _filters.map((filter) {
                      final isSelected = filter == _selectedFilter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedFilter = filter);
                          },
                          backgroundColor: AppColors.lightGrey,
                          selectedColor: AppColors.primaryBlue,
                          labelStyle: AppTextStyles.bodyMedium.copyWith(
                            color:
                                isSelected
                                    ? AppColors.white
                                    : AppColors.textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                          checkmarkColor: AppColors.white,
                          side: BorderSide.none,
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          IconButton(
            onPressed: _showFilterOptions,
            icon: const Icon(Icons.filter_list),
            color: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Earned',
              'LKR 45,890',
              Icons.account_balance_wallet,
              AppColors.primaryBlue,
              '+15%',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Total Trips',
              '124',
              Icons.directions_car,
              AppColors.success,
              '+8%',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalPadding,
      ),
      children: [
        _buildDateSection('Today', [
          _buildHistoryItem(
            'Trip to Kandy',
            'LKR 2,450',
            '10:30 AM',
            'Completed',
            AppColors.success,
          ),
          _buildHistoryItem(
            'Airport Drop',
            'LKR 1,650',
            '2:15 PM',
            'Completed',
            AppColors.success,
          ),
          _buildHistoryItem(
            'City Tour',
            'LKR 3,200',
            '6:00 PM',
            'Completed',
            AppColors.success,
          ),
        ]),
        _buildDateSection('Yesterday', [
          _buildHistoryItem(
            'Galle Trip',
            'LKR 1,890',
            '9:00 AM',
            'Completed',
            AppColors.success,
          ),
          _buildHistoryItem(
            'Local Trip',
            'LKR 850',
            '3:30 PM',
            'Completed',
            AppColors.success,
          ),
        ]),
        _buildDateSection('Jan 20, 2025', [
          _buildHistoryItem(
            'Weekend Bonus',
            'LKR 500',
            '11:59 PM',
            'Bonus',
            AppColors.primaryBlue,
          ),
          _buildHistoryItem(
            'Long Distance',
            'LKR 4,200',
            '1:00 PM',
            'Completed',
            AppColors.success,
          ),
        ]),
      ],
    );
  }

  Widget _buildDateSection(String date, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            date,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        ...items,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildHistoryItem(
    String title,
    String amount,
    String time,
    String status,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              status == 'Bonus' ? Icons.star : Icons.directions_car,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      time,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Earnings',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFilterOption('All Time', Icons.all_inclusive),
                _buildFilterOption('This Week', Icons.date_range),
                _buildFilterOption('This Month', Icons.calendar_month),
                _buildFilterOption('Last Month', Icons.calendar_today),
                _buildFilterOption('Custom Range', Icons.date_range),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  Widget _buildFilterOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      ),
      onTap: () {
        Navigator.pop(context);
        setState(() => _selectedFilter = title);
      },
      contentPadding: EdgeInsets.zero,
    );
  }
}
