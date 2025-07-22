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
  String _selectedPeriod = 'All';
  final List<String> _periods = ['Today', 'This Week', 'This Month', 'All'];
  String _selectedFilter = 'All Transactions';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 20),
            _buildSummaryCard(),
            const SizedBox(height: 24),
            _buildHistoryList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => EarningsNavigationPanel.show(context),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.menu, color: AppColors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return const CustomAppbarName(
      title: 'Transactions History',
      showBackButton: true,
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

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue.withOpacity(0.1), AppColors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.primaryBlue.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction Summary',
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Financial overview for $_selectedPeriod',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Credits',
                  'LKR 12,480',
                  '+15.2%',
                  AppColors.success,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  'Total Debits',
                  'LKR 2,060',
                  '-8.3%',
                  AppColors.error,
                  Icons.trending_down,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance, color: AppColors.success, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Net Balance',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Your current earnings balance',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'LKR 10,420',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    String amount,
    String change,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontSize: 16,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter and Sort Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transaction History',
              style: AppTextStyles.heading3.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: _showFilterOptions,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list,
                          color: AppColors.primaryBlue,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _selectedFilter == 'All Transactions'
                              ? 'Filter'
                              : _selectedFilter,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // Export functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              Icons.download,
                              color: AppColors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Text('Export feature coming soon!'),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.download,
                          color: AppColors.success,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Export',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDateSection('Today', [
          _buildTransactionItem(
            'Company Payment',
            '+LKR 4,250',
            '2:30 PM',
            'Card trip settlements (3 trips)',
            'CREDIT',
            AppColors.success,
            Icons.account_balance,
          ),
          _buildTransactionItem(
            'Commission Deduction',
            '-LKR 975',
            '2:30 PM',
            'Cash trip commission (15%)',
            'DEBIT',
            AppColors.error,
            Icons.percent,
          ),
          _buildTransactionItem(
            'Weekend Bonus',
            '+LKR 500',
            '11:59 PM',
            'Performance bonus payment',
            'CREDIT',
            AppColors.primaryBlue,
            Icons.star,
          ),
        ]),
        _buildDateSection('Yesterday', [
          _buildTransactionItem(
            'Company Payment',
            '+LKR 6,840',
            '5:45 PM',
            'Card trip settlements (5 trips)',
            'CREDIT',
            AppColors.success,
            Icons.account_balance,
          ),
          _buildTransactionItem(
            'Commission Deduction',
            '-LKR 635',
            '5:45 PM',
            'Cash trip commission (15%)',
            'DEBIT',
            AppColors.error,
            Icons.percent,
          ),
        ]),
        _buildDateSection('Jan 20, 2025', [
          _buildTransactionItem(
            'Weekly Settlement',
            '+LKR 2,890',
            '6:00 PM',
            'Net balance settlement',
            'CREDIT',
            AppColors.primaryBlue,
            Icons.account_balance_wallet,
          ),
          _buildTransactionItem(
            'Commission Adjustment',
            '-LKR 450',
            '6:00 PM',
            'Previous period adjustment',
            'DEBIT',
            AppColors.warning,
            Icons.adjust,
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

  Widget _buildTransactionItem(
    String title,
    String amount,
    String time,
    String description,
    String transactionType,
    Color statusColor,
    IconData icon,
  ) {
    final bool isCredit = transactionType == 'CREDIT';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            width: 4,
            color: isCredit ? AppColors.success : AppColors.error,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isCredit
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            transactionType,
                            style: AppTextStyles.bodySmall.copyWith(
                              color:
                                  isCredit
                                      ? AppColors.success
                                      : AppColors.error,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: AppTextStyles.bodyMedium.copyWith(
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
                    amount,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isCredit ? AppColors.success : AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    isCredit ? Icons.trending_up : Icons.trending_down,
                    size: 16,
                    color: isCredit ? AppColors.success : AppColors.error,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              description,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
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
                  'Filter Transaction History',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                _buildFilterOption('All Transactions', Icons.all_inclusive),
                _buildFilterOption('Company Payments', Icons.account_balance),
                _buildFilterOption('Commission Deductions', Icons.percent),
                _buildFilterOption('Bonuses & Incentives', Icons.star),
                _buildFilterOption(
                  'Settlement History',
                  Icons.account_balance_wallet,
                ),
                _buildFilterOption('Credit Transactions', Icons.add_circle),
                _buildFilterOption('Debit Transactions', Icons.remove_circle),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildFilterOption(String title, IconData icon) {
    final bool isSelected = _selectedFilter == title;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:
            isSelected
                ? AppColors.primaryBlue.withOpacity(0.1)
                : AppColors.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border:
            isSelected
                ? Border.all(color: AppColors.primaryBlue.withOpacity(0.5))
                : null,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppColors.primaryBlue.withOpacity(0.2)
                    : AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? AppColors.primaryBlue : AppColors.primaryBlue,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        trailing:
            isSelected
                ? Icon(
                  Icons.check_circle,
                  size: 20,
                  color: AppColors.primaryBlue,
                )
                : Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
        onTap: () {
          Navigator.pop(context);
          setState(() => _selectedFilter = title);
          // Show feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Filter applied: $title'),
              duration: const Duration(seconds: 2),
              backgroundColor: AppColors.primaryBlue,
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
