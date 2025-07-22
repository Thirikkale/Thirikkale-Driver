import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_driver/features/drivepass/screens/drive_pass_history_screen.dart';
import 'package:thirikkale_driver/features/drivepass/screens/purchase_details_screen.dart';

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
      // Custom AppBar
      appBar: CustomAppbarName(title: 'Drive Pass', showBackButton: true),

      // Body
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
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
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
                                  color: AppColors.warning.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  option.icon,
                                  color: AppColors.warning,
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
                  const SizedBox(height: 20),
                  _buildBenefitItem(
                    icon: Icons.account_balance_wallet,
                    title: 'Pay with your Thirikkale balance',
                    description:
                        'Purchase Drive Pass even if your balance is negative, and pay it off with your earnings.',
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
            color: AppColors.black,
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

      // Navigate to Purchase Details screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  PurchaseDetailsScreen(selectedOption: selectedOption),
        ),
      );
    }
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

class PaymentMethod {
  final String name;
  final IconData icon;
  final String subtitle;

  PaymentMethod({
    required this.name,
    required this.icon,
    required this.subtitle,
  });
}

class SavedCard {
  final String name;
  final String subtitle;
  final IconData icon;

  SavedCard({required this.name, required this.subtitle, required this.icon});
}
