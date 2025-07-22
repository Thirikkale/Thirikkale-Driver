import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_driver/features/earnings/widgets/earnings_navigation_panel.dart';

class BonusesScreen extends StatefulWidget {
  const BonusesScreen({super.key});

  @override
  State<BonusesScreen> createState() => _BonusesScreenState();
}

class _BonusesScreenState extends State<BonusesScreen> {
  String _selectedPeriod = 'This Week';
  final List<String> _periods = [
    'Today',
    'This Week',
    'This Month',
    'All Time',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppbarName(title: 'Bonuses', showBackButton: true),
      body: Column(
        children: [
          _buildPeriodSelector(),
          _buildBonusStats(),
          Expanded(child: _buildBonusList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => EarningsNavigationPanel.show(context),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.star, color: AppColors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
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

  Widget _buildBonusStats() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalPadding,
      ),
      padding: const EdgeInsets.all(20),
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Bonuses',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.trending_up, color: AppColors.white, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'LKR 1,250',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '($_selectedPeriod)',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBonusStatItem('Earned', '8', AppColors.success),
              _buildStatDivider(),
              _buildBonusStatItem('Pending', '3', AppColors.warning),
              _buildStatDivider(),
              _buildBonusStatItem('Types', '5', AppColors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBonusStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 30,
      color: AppColors.white.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildBonusList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
      itemCount: 12, // More bonuses for dedicated screen
      itemBuilder: (context, index) => _buildBonusCard(index),
    );
  }

  Widget _buildBonusCard(int index) {
    final bonuses = [
      {
        'type': 'Peak Hour Bonus',
        'amount': '200',
        'description': '5-7 PM rush hour completed',
        'status': 'Earned',
        'date': 'Today, 7:15 PM',
        'icon': Icons.schedule,
        'condition': '5+ trips during rush hour',
      },
      {
        'type': 'Completion Bonus',
        'amount': '150',
        'description': '10+ trips completed today',
        'status': 'Earned',
        'date': 'Today, 6:45 PM',
        'icon': Icons.check_circle,
        'condition': 'Complete 10 trips in a day',
      },
      {
        'type': 'Weekend Bonus',
        'amount': '300',
        'description': 'Saturday premium earnings',
        'status': 'Pending',
        'date': 'Processing',
        'icon': Icons.weekend,
        'condition': 'Work on weekends',
      },
      {
        'type': 'Rating Bonus',
        'amount': '100',
        'description': '4.8+ rating maintained',
        'status': 'Earned',
        'date': 'Yesterday',
        'icon': Icons.star,
        'condition': 'Maintain 4.8+ rating for a week',
      },
      {
        'type': 'Distance Bonus',
        'amount': '250',
        'description': '100+ km driven today',
        'status': 'Earned',
        'date': 'Today, 8:30 PM',
        'icon': Icons.route,
        'condition': 'Drive 100+ km in a day',
      },
      {
        'type': 'Fuel Efficiency',
        'amount': '80',
        'description': 'Eco-friendly driving',
        'status': 'Pending',
        'date': 'Processing',
        'icon': Icons.eco,
        'condition': 'Maintain fuel efficiency',
      },
    ];

    final bonus = bonuses[index % bonuses.length];
    final isEarned = bonus['status'] == 'Earned';
    final bonusColor = isEarned ? AppColors.success : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bonusColor.withOpacity(0.3)),
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
          onTap: () => _showBonusDetails(bonus),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bonusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        bonus['icon'] as IconData,
                        color: bonusColor,
                        size: 24,
                      ),
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
                                  bonus['type'] as String,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: bonusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  bonus['status'] as String,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: bonusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bonus['description'] as String,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bonus['date'] as String,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'LKR ${bonus['amount']}',
                          style: AppTextStyles.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: bonusColor,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.textSecondary,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
                if (bonus['condition'] != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Condition: ${bonus['condition']}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBonusDetails(Map<String, dynamic> bonus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              final isEarned = bonus['status'] == 'Earned';
              final bonusColor =
                  isEarned ? AppColors.success : AppColors.warning;

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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bonusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            bonus['icon'] as IconData,
                            color: bonusColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bonus['type'] as String,
                                style: AppTextStyles.heading3.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'LKR ${bonus['amount']}',
                                style: AppTextStyles.heading2.copyWith(
                                  color: bonusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailSection(
                              'Status',
                              bonus['status'] as String,
                            ),
                            _buildDetailSection(
                              'Description',
                              bonus['description'] as String,
                            ),
                            _buildDetailSection(
                              'Date',
                              bonus['date'] as String,
                            ),
                            if (bonus['condition'] != null)
                              _buildDetailSection(
                                'Condition',
                                bonus['condition'] as String,
                              ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: bonusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bonus Information',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    isEarned
                                        ? 'This bonus has been successfully earned and will be added to your next payout.'
                                        : 'This bonus is currently being processed and will be credited once verified.',
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

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
