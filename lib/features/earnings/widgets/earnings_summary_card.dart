import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';

class EarningsSummaryCard extends StatelessWidget {
  final double netEarnings;
  final int cardTrips;
  final int cashTrips;
  final double totalCommission;
  final String trendPercentage;
  final bool isPositiveTrend;

  const EarningsSummaryCard({
    super.key,
    required this.netEarnings,
    required this.cardTrips,
    required this.cashTrips,
    required this.totalCommission,
    this.trendPercentage = '+12%',
    this.isPositiveTrend = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalPadding,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Net Earnings',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'LKR ${netEarnings.toStringAsFixed(2)}',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositiveTrend ? Icons.trending_up : Icons.trending_down,
                      color: AppColors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trendPercentage,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildEarningStat(
                  'Card Trips',
                  '$cardTrips',
                  Icons.credit_card,
                  AppColors.white.withOpacity(0.9),
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: AppColors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildEarningStat(
                  'Cash Trips',
                  '$cashTrips',
                  Icons.money,
                  AppColors.white.withOpacity(0.9),
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: AppColors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildEarningStat(
                  'Commission',
                  'LKR ${totalCommission.toStringAsFixed(0)}',
                  Icons.percent,
                  AppColors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: color)),
      ],
    );
  }
}
