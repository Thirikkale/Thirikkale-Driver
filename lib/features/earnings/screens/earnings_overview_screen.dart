import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_driver/features/earnings/widgets/earnings_summary_card.dart';

class EarningsOverviewScreen extends StatefulWidget {
  const EarningsOverviewScreen({super.key});

  @override
  State<EarningsOverviewScreen> createState() => _EarningsOverviewScreenState();
}

class _EarningsOverviewScreenState extends State<EarningsOverviewScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  String _selectedPeriod = 'Today';
  final List<String> _periods = [
    'Today',
    'This Week',
    'This Month',
    'All Time',
  ];

  bool _isCardVisible = true;
  bool _isInitialized = false; // Payment method statistics
  final double _cardPaymentTotal = 8750.00;
  final double _cashPaymentTotal = 6490.00;
  final double _commissionRate = 0.15; // 15% commission
  final double _cardTrips = 18;
  final double _cashTrips = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: -200.0, // Height to slide up
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Mark as initialized first
    _isInitialized = true;

    // Defer scroll listener attachment to next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollController.addListener(_onScroll);
      }
    });
  }

  void _onScroll() {
    if (!mounted || !_isInitialized) return;

    const double threshold = 50.0; // Scroll threshold to trigger animation

    if (_scrollController.offset > threshold && _isCardVisible) {
      setState(() {
        _isCardVisible = false;
      });
      _animationController.forward();
    } else if (_scrollController.offset <= threshold && !_isCardVisible) {
      setState(() {
        _isCardVisible = true;
      });
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _tabController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Helper methods for earnings calculations
  double get _cardCommission => _cardPaymentTotal * _commissionRate;
  double get _cashCommission => _cashPaymentTotal * _commissionRate;
  double get _driverEarningsFromCard => _cardPaymentTotal - _cardCommission;
  double get _netEarnings =>
      _driverEarningsFromCard + (_cashPaymentTotal - _cashCommission);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildPeriodSelector(),
          _isInitialized
              ? AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Opacity(
                      opacity: _isCardVisible ? 1.0 : 0.0,
                      child: EarningsSummaryCard(
                        netEarnings: _netEarnings,
                        cardTrips: _cardTrips.toInt(),
                        cashTrips: _cashTrips.toInt(),
                        totalCommission: _cardCommission + _cashCommission,
                      ),
                    ),
                  );
                },
              )
              : EarningsSummaryCard(
                netEarnings: _netEarnings,
                cardTrips: _cardTrips.toInt(),
                cashTrips: _cashTrips.toInt(),
                totalCommission: _cardCommission + _cashCommission,
              ),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEarningsTab(),
                _buildTripsTab(),
                _buildBonusesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNavigationPanel,
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.dashboard, color: AppColors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppbarName(title: 'Earnings', showBackButton: true);
  }

  void _showNavigationPanel() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 20),
                Text(
                  'Earnings Dashboard',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                // Navigation options
                _buildNavigationItem(
                  icon: Icons.analytics,
                  title: 'Earnings Analytics',
                  subtitle: 'View detailed insights and trends',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/earnings-analytics');
                  },
                ),
                _buildNavigationItem(
                  icon: Icons.history,
                  title: 'Earnings History',
                  subtitle: 'View past earnings and transactions',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/earnings-history');
                  },
                ),
                _buildNavigationItem(
                  icon: Icons.account_balance_wallet,
                  title: 'Payout Settings',
                  subtitle: 'Manage payment methods and schedule',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/payout-settings');
                  },
                ),
                _buildNavigationItem(
                  icon: Icons.download,
                  title: 'Export Data',
                  subtitle: 'Download earnings reports',
                  onTap: () {
                    Navigator.pop(context);
                    _showExportOptions();
                  },
                ),
                _buildNavigationItem(
                  icon: Icons.receipt_long,
                  title: 'Tax Documents',
                  subtitle: 'Access tax forms and summaries',
                  onTap: () {
                    Navigator.pop(context);
                    _showTaxDocuments();
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildNavigationItem({
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
            color: AppColors.primaryBlue.withOpacity(0.1),
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

  void _showExportOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
        );
      },
    );
  }

  Widget _buildExportOption({
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

  void _showTaxDocuments() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
                title: '2024 Tax Summary',
                subtitle: 'Annual earnings summary for tax filing',
                icon: Icons.summarize,
              ),
              const SizedBox(height: 12),
              _buildTaxDocumentItem(
                title: '1099-K Form',
                subtitle: 'Payment card and third party network transactions',
                icon: Icons.description,
              ),
              const SizedBox(height: 12),
              _buildTaxDocumentItem(
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
        );
      },
    );
  }

  Widget _buildTaxDocumentItem({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.3),
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

  Widget _buildTabBar() {
    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryBlue,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primaryBlue,
        indicatorWeight: 3,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.bodyMedium,
        tabs: const [
          Tab(text: 'Earnings'),
          Tab(text: 'Trips'),
          Tab(text: 'Bonuses'),
        ],
      ),
    );
  }

  Widget _buildTripsTab() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
      itemCount: 10,
      itemBuilder: (context, index) => _buildTripCard(index),
    );
  }

  Widget _buildEarningsTab() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
      children: [
        _buildEarningsChart(),
        const SizedBox(height: 16),
        ...List.generate(8, (index) => _buildEarningsCard(index)),
      ],
    );
  }

  Widget _buildBonusesTab() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
      itemCount: 5,
      itemBuilder: (context, index) => _buildBonusCard(index),
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
        'paymentMethod': 'Card',
      },
      {
        'from': 'Dehiwala',
        'to': 'Bambalapitiya',
        'fare': '320',
        'time': '11:15 AM',
        'distance': '8.2 km',
        'paymentMethod': 'Cash',
      },
      {
        'from': 'Wellawatta',
        'to': 'Kollupitiya',
        'fare': '280',
        'time': '2:45 PM',
        'distance': '6.8 km',
        'paymentMethod': 'Card',
      },
      {
        'from': 'Galle Face',
        'to': 'Nugegoda',
        'fare': '520',
        'time': '5:20 PM',
        'distance': '15.3 km',
        'paymentMethod': 'Cash',
      },
      {
        'from': 'Maharagama',
        'to': 'Pettah',
        'fare': '380',
        'time': '7:10 PM',
        'distance': '11.2 km',
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
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isCard ? AppColors.primaryBlue : AppColors.success)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCard ? Icons.credit_card : Icons.money,
                  color: isCard ? AppColors.primaryBlue : AppColors.success,
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
                    Text(
                      '${trip['distance']} • ${trip['time']}',
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
                            isCard ? AppColors.primaryBlue : AppColors.success,
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
    );
  }

  Widget _buildEarningsChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method Breakdown',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPaymentMethodItem(
                'Card Payments',
                'LKR ${_cardPaymentTotal.toStringAsFixed(0)}',
                'Company pays driver',
                Icons.credit_card,
                AppColors.primaryBlue,
              ),
              _buildPaymentMethodItem(
                'Cash Payments',
                'LKR ${_cashPaymentTotal.toStringAsFixed(0)}',
                'Driver pays commission',
                Icons.money,
                AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCommissionSummary(),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(
    String label,
    String amount,
    String description,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(child: Icon(icon, color: color, size: 24)),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Commission Summary (${(_commissionRate * 100).toInt()}%)',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Card Commission',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'LKR ${_cardCommission.toStringAsFixed(2)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    'Company pays',
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
                    'Cash Commission',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'LKR ${_cashCommission.toStringAsFixed(2)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  Text(
                    'Driver pays',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 1,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Earnings:',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'LKR ${_netEarnings.toStringAsFixed(2)}',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(int index) {
    final earnings = [
      {
        'type': 'Card Payment',
        'amount': '450',
        'time': '9:30 AM',
        'icon': Icons.credit_card,
        'paymentMethod': 'Card',
        'description': 'Colombo Fort → Mt. Lavinia',
      },
      {
        'type': 'Cash Payment',
        'amount': '320',
        'time': '11:15 AM',
        'icon': Icons.money,
        'paymentMethod': 'Cash',
        'description': 'Dehiwala → Bambalapitiya',
      },
      {
        'type': 'Card Payment',
        'amount': '280',
        'time': '2:45 PM',
        'icon': Icons.credit_card,
        'paymentMethod': 'Card',
        'description': 'Wellawatta → Kollupitiya',
      },
      {
        'type': 'Cash Payment',
        'amount': '520',
        'time': '5:20 PM',
        'icon': Icons.money,
        'paymentMethod': 'Cash',
        'description': 'Galle Face → Nugegoda',
      },
    ];

    final earning = earnings[index % earnings.length];
    final fare = double.parse(earning['amount']! as String);
    final isCard = earning['paymentMethod'] == 'Card';
    final commission = fare * _commissionRate;
    final driverEarning = isCard ? fare - commission : fare;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isCard ? AppColors.primaryBlue : AppColors.success)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  earning['icon'] as IconData,
                  color: isCard ? AppColors.primaryBlue : AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      earning['type']! as String,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      earning['description']! as String,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      earning['time']! as String,
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
                    'LKR ${earning['amount']}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    'LKR ${driverEarning.toStringAsFixed(0)}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commission (${(_commissionRate * 100).toInt()}%):',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'LKR ${commission.toStringAsFixed(0)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCard ? AppColors.success : AppColors.error,
                  ),
                ),
                Text(
                  isCard ? '(Company pays)' : '(You owe)',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isCard ? AppColors.success : AppColors.error,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBonusCard(int index) {
    final bonuses = [
      {
        'type': 'Peak Hour Bonus',
        'amount': 'LKR 200',
        'description': '5-7 PM rush hour',
        'status': 'Earned',
      },
      {
        'type': 'Completion Bonus',
        'amount': 'LKR 150',
        'description': '10+ trips completed',
        'status': 'Earned',
      },
      {
        'type': 'Weekend Bonus',
        'amount': 'LKR 300',
        'description': 'Saturday premium',
        'status': 'Pending',
      },
      {
        'type': 'Rating Bonus',
        'amount': 'LKR 100',
        'description': '4.8+ rating maintained',
        'status': 'Earned',
      },
    ];

    final bonus = bonuses[index % bonuses.length];
    final isEarned = bonus['status'] == 'Earned';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isEarned
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isEarned ? AppColors.success : AppColors.warning)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isEarned ? Icons.star : Icons.schedule,
              color: isEarned ? AppColors.success : AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bonus['type']!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bonus['description']!,
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
                bonus['amount']!,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isEarned ? AppColors.success : AppColors.warning,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (isEarned ? AppColors.success : AppColors.warning)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  bonus['status']!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isEarned ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
