import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/features/home/screens/drive_pass_history_screen.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar_name.dart';

class DrivePassScreen extends StatefulWidget {
  const DrivePassScreen({super.key});

  @override
  State<DrivePassScreen> createState() => _DrivePassScreenState();
}

class _DrivePassScreenState extends State<DrivePassScreen> {
  int? selectedPassIndex;

  final List<DrivePassOption> drivePassOptions = [
    DrivePassOption(
      duration: '4 hours',
      price: 'LKR 559.00',
      icon: Icons.credit_card,
    ),
    DrivePassOption(
      duration: '1 day',
      price: 'LKR 999.00',
      icon: Icons.credit_card,
    ),
    DrivePassOption(
      duration: '3 days',
      price: 'LKR 1,999.00',
      icon: Icons.credit_card,
    ),
    DrivePassOption(
      duration: '5 days',
      price: 'LKR 2,499.00',
      icon: Icons.credit_card,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppbarName(title: "Drive Pass", showBackButton: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Choose a Drive Pass',
                    style: AppTextStyles.heading1,
                  ),
                  const SizedBox(height: 32),

                  // Drive Pass Options
                  ...drivePassOptions.asMap().entries.map((entry) {
                    int index = entry.key;
                    DrivePassOption option = entry.value;
                    bool isSelected = selectedPassIndex == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedPassIndex = index;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? AppColors.primaryBlue
                                      : AppColors.lightGrey,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  option.icon,
                                  color: AppColors.primaryBlue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Text content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option.duration,
                                      style: AppTextStyles.heading3.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      option.price,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Radio button
                              Radio<int>(
                                value: index,
                                groupValue: selectedPassIndex,
                                onChanged: (value) {
                                  setState(() {
                                    selectedPassIndex = value;
                                  });
                                },
                                activeColor: AppColors.primaryBlue,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Drive Pass History
                  InkWell(
                    onTap: () {
                      // Navigate to Drive Pass history
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DrivePassHistoryScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'Drive Pass history',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Benefits Section
                  Text(
                    'Benefits',
                    style: AppTextStyles.heading2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Benefit items
                  _buildBenefitItem(
                    icon: Icons.local_offer,
                    title: 'Get unlimited offers',
                    description:
                        'There\'s no limit on the trip requests you\'ll receive, and no cap on your earnings.',
                  ),
                  const SizedBox(height: 20),
                  _buildBenefitItem(
                    icon: Icons.trending_up,
                    title: 'Earn more on every trip',
                    description:
                        'Since you pay no Service Fee, you keep that amount in earnings for every trip.',
                  ),
                ],
              ),
            ),
          ),

          // Continue Button
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    selectedPassIndex != null
                        ? () {
                          // Handle continue action
                          _handleContinue();
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: AppColors.lightGrey,
                ),
                child: Text(
                  'Continue',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.primaryBlue,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleContinue() {
    if (selectedPassIndex != null) {
      final selectedOption = drivePassOptions[selectedPassIndex!];

      // Show purchase details bottom sheet with animation
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildPurchaseDetailsSheet(selectedOption),
      );
    }
  }

  Widget _buildPurchaseDetailsSheet(DrivePassOption selectedOption) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header with close button
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Purchase details',
                  style: AppTextStyles.heading2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.black),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    'With Drive Pass, you\'re no longer charged a service fee after this trip. You will save on every trip.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Current wallet balance
                  _buildBalanceRow(
                    'Current wallet balance',
                    '-LKR 1,118.00',
                    isNegative: true,
                  ),

                  const SizedBox(height: 16),

                  // Drive Pass
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBalanceRow(
                        'Drive Pass',
                        '-${selectedOption.price}',
                        isNegative: true,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedOption.duration,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // New Wallet balance
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBalanceRow(
                        'New wallet balance',
                        'LKR 1,677.00',
                        isTotal: true,
                      ),
                      const SizedBox(height: 8),
                      // Text(
                      //   'Purchasing a Drive Pass requires no upfront payment. We\'ll deduct the cost of the pass from your wallet now and future earnings will be automatically be applied toward it.',
                      //   style: AppTextStyles.bodySmall.copyWith(
                      //     color: AppColors.textSecondary,
                      //     height: 1.4,
                      //   ),
                      // ),
                    ],
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),

          // Purchase button
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet
                  // Handle purchase logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Drive Pass purchased successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Purchase Drive Pass',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceRow(
    String title,
    String amount, {
    bool isNegative = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color:
                isNegative
                    ? AppColors.error
                    : isTotal
                    ? AppColors.success
                    : AppColors.black,
          ),
        ),
      ],
    );
  }
}

class DrivePassOption {
  final String duration;
  final String price;
  final IconData icon;

  DrivePassOption({
    required this.duration,
    required this.price,
    required this.icon,
  });
}
