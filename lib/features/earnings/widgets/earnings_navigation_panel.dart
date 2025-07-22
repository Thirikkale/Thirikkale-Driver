import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/config/routes.dart';

class EarningsNavigationPanel {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
        minHeight: MediaQuery.of(context).size.height,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Earnings Dashboard',
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Scrollable Navigation options
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildNavigationItem(
                          context,
                          icon: Icons.dashboard,
                          title: 'Earnings Overview',
                          subtitle: 'View earnings summary and insights',
                          onTap: () {
                            Navigator.pop(context);
                            if (context.mounted) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.earningsOverview,
                              );
                            }
                          },
                        ),
                        _buildNavigationItem(
                          context,
                          icon: Icons.history,
                          title: 'Earnings History',
                          subtitle: 'View past earnings and transactions',
                          onTap: () {
                            Navigator.pop(context);
                            if (context.mounted) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.earningsHistory,
                              );
                            }
                          },
                        ),
                        _buildNavigationItem(
                          context,
                          icon: Icons.route,
                          title: 'Trip Payments',
                          subtitle: 'View detailed trip history',
                          onTap: () {
                            Navigator.pop(context);
                            if (context.mounted) {
                              Navigator.pushNamed(context, AppRoutes.trips);
                            }
                          },
                        ),
                        _buildNavigationItem(
                          context,
                          icon: Icons.account_balance_wallet,
                          title: 'Payout Settings',
                          subtitle: 'Manage payment methods and schedule',
                          onTap: () {
                            Navigator.pop(context);
                            if (context.mounted) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.payoutSettings,
                              );
                            }
                          },
                        ),
                        _buildNavigationItem(
                          context,
                          icon: Icons.download,
                          title: 'Export Data',
                          subtitle: 'Download earnings reports',
                          onTap: () {
                            Navigator.pop(context);
                            if (context.mounted) {
                              _showExportOptions(context);
                            }
                          },
                        ),
                        _buildNavigationItem(
                          context,
                          icon: Icons.receipt_long,
                          title: 'Tax Documents',
                          subtitle: 'Access tax forms and summaries',
                          onTap: () {
                            Navigator.pop(context);
                            if (context.mounted) {
                              _showTaxDocuments(context);
                            }
                          },
                        ),
                        // Bottom padding for safe area
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  static Widget _buildNavigationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 24),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
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
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textSecondary,
          size: 16,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: AppColors.white,
      ),
    );
  }

  static void _showExportOptions(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.download, color: AppColors.primaryBlue),
                const SizedBox(width: 12),
                const Text('Export Earnings'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildExportOption(
                  context,
                  icon: Icons.picture_as_pdf,
                  title: 'Export as PDF',
                  subtitle: 'Generate detailed PDF report',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PDF export functionality coming soon'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildExportOption(
                  context,
                  icon: Icons.table_chart,
                  title: 'Export as Excel',
                  subtitle: 'Download spreadsheet format',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Excel export functionality coming soon'),
                      ),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  static Widget _buildExportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showTaxDocuments(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.receipt_long, color: AppColors.primaryBlue),
                const SizedBox(width: 12),
                const Text('Tax Documents'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTaxDocumentItem(
                  context,
                  title: '2024 Tax Summary',
                  subtitle: 'Annual earnings summary for tax filing',
                  icon: Icons.summarize,
                ),
                const SizedBox(height: 12),
                _buildTaxDocumentItem(
                  context,
                  title: '1099-K Form',
                  subtitle: 'Payment card and third party network transactions',
                  icon: Icons.description,
                ),
                const SizedBox(height: 12),
                _buildTaxDocumentItem(
                  context,
                  title: 'Monthly Statements',
                  subtitle: 'Detailed monthly earning breakdowns',
                  icon: Icons.calendar_month,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  static Widget _buildTaxDocumentItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.download, color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }
}
