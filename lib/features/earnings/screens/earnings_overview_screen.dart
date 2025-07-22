import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_driver/features/earnings/widgets/earnings_navigation_panel.dart';

class EarningsOverviewScreen extends StatefulWidget {
  const EarningsOverviewScreen({super.key});

  @override
  State<EarningsOverviewScreen> createState() => _EarningsOverviewScreenState();
}

class _EarningsOverviewScreenState extends State<EarningsOverviewScreen> {
  String _selectedPeriod = 'Today';
  final List<String> _periods = [
    'Today',
    'This Week',
    'This Month',
    'All Time',
  ];

  // Payment method statistics
  final double _cardPaymentTotal = 8750.00;
  final double _cashPaymentTotal = 6490.00;
  final double _commissionRate = 0.15; // 15% commission
  final double _cardTrips = 18;
  final double _cashTrips = 10;

  // Helper methods for earnings calculations
  double get _cardCommission => _cardPaymentTotal * _commissionRate;
  double get _cashCommission => _cashPaymentTotal * _commissionRate;
  double get _driverEarningsFromCard => _cardPaymentTotal - _cardCommission;

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
            _buildDetailedEarningsBreakdown(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildQuickStats(),
            const SizedBox(height: 24),
            _buildRecentActivity(),
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
      title: 'Earnings Overview',
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

  Widget _buildDetailedEarningsBreakdown() {
    final double totalCardAmount = _cardPaymentTotal;
    final double totalCashAmount = _cashPaymentTotal;
    final double totalGrossAmount = totalCardAmount + totalCashAmount;

    // What company pays to driver (card trips - company keeps commission)
    final double companyPaysToDriver = _driverEarningsFromCard;

    // What driver owes to company (cash commission)
    final double driverOwesToCompany = _cashCommission;

    // Final balance (what driver actually receives)
    final double finalBalance =
        companyPaysToDriver + totalCashAmount - driverOwesToCompany;

    // Helper function to format currency
    String formatCurrency(double amount) {
      return 'LKR ${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Header
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: AppColors.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Earnings Breakdown',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // NET EARNINGS - MOST PROMINENT
          Container(
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
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
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
                        color: AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'YOUR NET EARNINGS',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Final amount you receive',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  formatCurrency(finalBalance),
                  style: AppTextStyles.heading1.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.white,
                    fontSize: 36,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Cash collected + Company payment - Commission owed',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Trip Amounts Section
          _buildSectionHeader('Trip Collections'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAmountCard(
                  'Card Trips',
                  formatCurrency(totalCardAmount),
                  '${_cardTrips.toInt()} trips',
                  AppColors.primaryBlue,
                  Icons.credit_card,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAmountCard(
                  'Cash Trips',
                  formatCurrency(totalCashAmount),
                  '${_cashTrips.toInt()} trips',
                  AppColors.success,
                  Icons.money,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildAmountCard(
            'Total Collections',
            formatCurrency(totalGrossAmount),
            '${(_cardTrips + _cashTrips).toInt()} total trips',
            AppColors.textPrimary,
            Icons.receipt_long,
            isTotal: true,
          ),

          const SizedBox(height: 24),

          // Commission Breakdown
          _buildSectionHeader('Commission Breakdown'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAmountCard(
                  'Card Commission',
                  formatCurrency(_cardCommission),
                  '${(_commissionRate * 100).toInt()}% of card trips',
                  AppColors.warning,
                  Icons.percent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAmountCard(
                  'Cash Commission',
                  formatCurrency(_cashCommission),
                  '${(_commissionRate * 100).toInt()}% of cash trips',
                  AppColors.error,
                  Icons.percent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Payment Flow Section
          _buildSectionHeader('How Your Earnings Are Calculated'),
          const SizedBox(height: 12),

          // Calculation Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                // Step 1: Cash collected
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          '1',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Cash trips you keep',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '+${formatCurrency(totalCashAmount)}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Step 2: Company payment
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          '2',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Company pays you (card trips - commission)',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '+${formatCurrency(companyPaysToDriver)}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Step 3: Commission owed
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          '3',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You pay commission on cash trips',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '-${formatCurrency(driverOwesToCompany)}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: AppColors.lightGrey),
                const SizedBox(height: 16),
                // Final calculation
                Row(
                  children: [
                    Icon(
                      Icons.calculate,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'TOTAL CALCULATION',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      formatCurrency(finalBalance),
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Company pays to driver
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_downward,
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
                        'Company Pays You',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        'Card trips after commission',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '+${formatCurrency(companyPaysToDriver)}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Driver owes to company
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_upward,
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
                        'You Owe Company',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                      Text(
                        'Commission from cash trips',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '-${formatCurrency(driverOwesToCompany)}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.bodyLarge.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildAmountCard(
    String title,
    String amount,
    String subtitle,
    Color color,
    IconData icon, {
    bool isTotal = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isTotal
                ? color.withOpacity(0.1)
                : AppColors.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: isTotal ? Border.all(color: color.withOpacity(0.3)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
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
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.heading3.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'View Trips',
                'Detailed trip history',
                Icons.route,
                AppColors.primaryBlue,
                () => Navigator.pushNamed(context, '/trips'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionCard(
                'Bonuses',
                'Track your bonuses',
                Icons.star,
                AppColors.success,
                () => Navigator.pushNamed(context, '/bonuses'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionCard(
                'Analytics',
                'Earnings insights',
                Icons.analytics,
                AppColors.warning,
                () => Navigator.pushNamed(context, '/earnings-analytics'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionCard(
                'History',
                'Past earnings',
                Icons.history,
                AppColors.error,
                () => Navigator.pushNamed(context, '/earnings-history'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats ($_selectedPeriod)',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                'Total Trips',
                '${(_cardTrips + _cashTrips).toInt()}',
                Icons.route,
              ),
              _buildStatDivider(),
              _buildStatItem(
                'Avg. Fare',
                'LKR ${((_cardPaymentTotal + _cashPaymentTotal) / (_cardTrips + _cashTrips)).toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                Icons.money,
              ),
              _buildStatDivider(),
              _buildStatItem('Rating', '4.8', Icons.star),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commission Saved',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'LKR ${_cardCommission.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      'Company paid on card trips',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Commission Owed',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'LKR ${_cashCommission.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                    Text(
                      'From cash trips',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                        fontSize: 10,
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
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
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: AppTextStyles.heading3.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/trips'),
              child: Text(
                'View All',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._buildRecentActivityItems(),
      ],
    );
  }

  List<Widget> _buildRecentActivityItems() {
    final recentActivities = [
      {
        'type': 'Trip Completed',
        'description': 'Colombo Fort → Mount Lavinia',
        'amount': '+LKR 450',
        'time': '2 hours ago',
        'icon': Icons.route,
        'color': AppColors.success,
      },
      {
        'type': 'Bonus Earned',
        'description': 'Peak hour bonus',
        'amount': '+LKR 200',
        'time': '3 hours ago',
        'icon': Icons.star,
        'color': AppColors.warning,
      },
      {
        'type': 'Trip Completed',
        'description': 'Dehiwala → Bambalapitiya',
        'amount': '+LKR 320',
        'time': '4 hours ago',
        'icon': Icons.route,
        'color': AppColors.success,
      },
    ];

    return recentActivities.map((activity) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (activity['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                activity['icon'] as IconData,
                color: activity['color'] as Color,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['type'] as String,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    activity['description'] as String,
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
                  activity['amount'] as String,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: activity['color'] as Color,
                  ),
                ),
                Text(
                  activity['time'] as String,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }
}
