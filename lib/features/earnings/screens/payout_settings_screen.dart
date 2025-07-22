import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_driver/features/earnings/widgets/earnings_navigation_panel.dart';

class PayoutSettingsScreen extends StatefulWidget {
  const PayoutSettingsScreen({super.key});

  @override
  State<PayoutSettingsScreen> createState() => _PayoutSettingsScreenState();
}

class _PayoutSettingsScreenState extends State<PayoutSettingsScreen> {
  bool _autoPayoutEnabled = true;
  String _selectedPayoutMethod = 'Bank Account';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBalanceCard(),
            _buildPayoutMethods(),
            _buildAutoPayoutSettings(),
            _buildPayoutHistory(),
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
      title: 'Payout Settings',
      showBackButton: true,
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Balance',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white.withOpacity(0.8),
                ),
              ),
              Icon(
                Icons.account_balance_wallet,
                color: AppColors.white,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'LKR 12,450.00',
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _withdrawNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Withdraw Now',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _viewTransactions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white.withOpacity(0.2),
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(Icons.history, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutMethods() {
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
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payout Methods',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildPayoutMethodTile(
            'Bank Account',
            'Commercial Bank - ****1234',
            Icons.account_balance,
            isSelected: _selectedPayoutMethod == 'Bank Account',
            onTap: () => setState(() => _selectedPayoutMethod = 'Bank Account'),
          ),
          _buildPayoutMethodTile(
            'Mobile Wallet',
            'eZ Cash - 077*****89',
            Icons.phone_android,
            isSelected: _selectedPayoutMethod == 'Mobile Wallet',
            onTap:
                () => setState(() => _selectedPayoutMethod = 'Mobile Wallet'),
          ),
          _buildPayoutMethodTile(
            'Cash Pickup',
            'Pickup from nearest center',
            Icons.location_on,
            isSelected: _selectedPayoutMethod == 'Cash Pickup',
            onTap: () => setState(() => _selectedPayoutMethod = 'Cash Pickup'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addPayoutMethod,
              icon: const Icon(Icons.add),
              label: const Text('Add New Method'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: BorderSide(color: AppColors.primaryBlue),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutMethodTile(
    String title,
    String subtitle,
    IconData icon, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 20),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Radio<String>(
          value: title,
          groupValue: _selectedPayoutMethod,
          onChanged: (value) => onTap(),
          activeColor: AppColors.primaryBlue,
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            width: 1,
          ),
        ),
        tileColor: isSelected ? AppColors.primaryBlue.withOpacity(0.05) : null,
      ),
    );
  }

  Widget _buildAutoPayoutSettings() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
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
          Text(
            'Auto Payout Settings',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(
              'Enable Auto Payout',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Automatically transfer earnings daily',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            value: _autoPayoutEnabled,
            onChanged: (value) => setState(() => _autoPayoutEnabled = value),
            activeColor: AppColors.primaryBlue,
            contentPadding: EdgeInsets.zero,
          ),
          if (_autoPayoutEnabled) ...[
            const SizedBox(height: 16),
            _buildAutoPayoutOption('Minimum Balance', 'LKR 1,000'),
            _buildAutoPayoutOption('Payout Frequency', 'Daily at 6:00 AM'),
            _buildAutoPayoutOption('Processing Fee', 'LKR 50 per transaction'),
          ],
        ],
      ),
    );
  }

  Widget _buildAutoPayoutOption(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutHistory() {
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
              Text(
                'Recent Payouts',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: _viewAllPayouts,
                child: Text(
                  'View All',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPayoutHistoryItem(
            'Jan 21, 2025',
            'LKR 8,500',
            'Completed',
            AppColors.success,
            'Commercial Bank',
          ),
          _buildPayoutHistoryItem(
            'Jan 20, 2025',
            'LKR 6,200',
            'Completed',
            AppColors.success,
            'eZ Cash',
          ),
          _buildPayoutHistoryItem(
            'Jan 19, 2025',
            'LKR 9,100',
            'Processing',
            AppColors.warning,
            'Commercial Bank',
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutHistoryItem(
    String date,
    String amount,
    String status,
    Color statusColor,
    String method,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
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
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      method,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
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
        ],
      ),
    );
  }

  void _withdrawNow() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Withdraw Earnings'),
            content: const Text(
              'Are you sure you want to withdraw your available balance?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Withdrawal request submitted'),
                    ),
                  );
                },
                child: const Text('Withdraw'),
              ),
            ],
          ),
    );
  }

  void _viewTransactions() {
    Navigator.pushNamed(context, '/earnings-history');
  }

  void _addPayoutMethod() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add payout method feature coming soon')),
    );
  }

  void _viewAllPayouts() {
    Navigator.pushNamed(context, '/earnings-history');
  }
}
