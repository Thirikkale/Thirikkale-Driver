import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/core/utils/snackbar_helper.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_driver/features/drivepass/screens/drive_pass_screen.dart';

class PurchaseDetailsScreen extends StatefulWidget {
  final DrivePassOption selectedOption;

  const PurchaseDetailsScreen({super.key, required this.selectedOption});

  @override
  State<PurchaseDetailsScreen> createState() => _PurchaseDetailsScreenState();
}

class _PurchaseDetailsScreenState extends State<PurchaseDetailsScreen> {
  int? selectedPaymentMethodIndex;
  String? selectedCardInfo; // To store selected card info

  final List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      name: 'Wallet',
      icon: Icons.account_balance_wallet,
      subtitle: 'Current balance: -LKR 1,118.00',
    ),
    PaymentMethod(
      name: 'Card',
      icon: Icons.credit_card,
      subtitle: 'Select a payment card',
    ),
    PaymentMethod(name: 'Cash', icon: Icons.money, subtitle: 'Pay with cash'),
    PaymentMethod(
      name: 'Bank Transfer',
      icon: Icons.account_balance,
      subtitle: 'Transfer from bank',
    ),
  ];

  // Saved cards data
  final List<SavedCard> savedCards = [
    SavedCard(
      name: 'Visa ****1234',
      subtitle: 'Expires 12/26',
      icon: Icons.credit_card,
    ),
    SavedCard(
      name: 'MasterCard ****5678',
      subtitle: 'Expires 08/25',
      icon: Icons.credit_card,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom AppBar
      appBar: CustomAppbarName(title: 'Purchase details', showBackButton: true),

      // Body
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
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

                  // Balance Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.lightGrey, width: 1),
                    ),
                    child: Column(
                      children: [
                        // Current Thirikkale balance
                        _buildBalanceRow(
                          'Current Thirikkale balance',
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
                              '-${widget.selectedOption.price}',
                              isNegative: true,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  widget.selectedOption.duration,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 20),

                        // New Thirikkale balance
                        _buildBalanceRow(
                          'New Thirikkale balance',
                          'LKR 1,677.00',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Additional Information
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Purchasing a Drive Pass requires no upfront payment. We\'ll deduct the cost of the pass from your wallet now and future earnings will be automatically applied toward it.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Payment Method Section
                  Text(
                    'Payment Method',
                    style: AppTextStyles.heading2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Method Options
                  ...paymentMethods.asMap().entries.map((entry) {
                    int index = entry.key;
                    PaymentMethod method = entry.value;
                    bool isSelected = selectedPaymentMethodIndex == index;
                    bool isCardOption = method.name == 'Card';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          if (isCardOption) {
                            // Handle card selection popup
                            _showCardSelectionDialog();
                          } else {
                            setState(() {
                              selectedPaymentMethodIndex = index;
                              if (!isCardOption) selectedCardInfo = null;
                            });
                          }
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
                              // Payment method icon
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  method.icon,
                                  color: AppColors.primaryBlue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Payment method info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      method.name,
                                      style: AppTextStyles.heading3.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isCardOption && selectedCardInfo != null
                                          ? selectedCardInfo!
                                          : method.subtitle,
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
                                groupValue: selectedPaymentMethodIndex,
                                onChanged: (value) {
                                  if (isCardOption) {
                                    _showCardSelectionDialog();
                                  } else {
                                    setState(() {
                                      selectedPaymentMethodIndex = value;
                                      if (!isCardOption)
                                        selectedCardInfo = null;
                                    });
                                  }
                                },
                                activeColor: AppColors.primaryBlue,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),
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
                onPressed:
                    selectedPaymentMethodIndex != null
                        ? () {
                          // Handle purchase logic here
                          final selectedPaymentMethod =
                              paymentMethods[selectedPaymentMethodIndex!];

                          // Show success message
                          SnackbarHelper.showSuccessSnackBar(
                            context,
                            'Drive Pass purchased successfully with ${selectedPaymentMethod.name}!',
                          );

                          // Navigate back to Drive Pass screen or main screen
                          Navigator.of(context).popUntil(
                            (route) =>
                                route.isFirst ||
                                route.settings.name == '/drive-pass',
                          );
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedPaymentMethodIndex != null
                          ? AppColors.primaryBlue
                          : AppColors.lightGrey,
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

  void _showCardSelectionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select a Card',
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
                    children: [
                      // Saved Cards
                      ...savedCards.map((card) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedPaymentMethodIndex =
                                    1; // Card option index
                                selectedCardInfo = card.name;
                              });
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.lightGrey,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      card.icon,
                                      color: AppColors.primaryBlue,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          card.name,
                                          style: AppTextStyles.bodyLarge
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          card.subtitle,
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 12),

                      // Add New Card Option
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _handleAddNewCard();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryBlue.withValues(alpha: 0.05),
                                AppColors.primaryBlue.withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.add_card,
                                  color: AppColors.primaryBlue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Add new card',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                    Text(
                                      'Add a new payment card',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.primaryBlue.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.add_circle_outline,
                                color: AppColors.primaryBlue,
                                size: 20,
                              ),
                            ],
                          ),
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
    );
  }

  void _handleAddNewCard() {
    // Handle add new card functionality
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Card'),
          content: const Text('This will open the card addition flow.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Here you would navigate to card addition screen
                SnackbarHelper.showInfoSnackBar(
                  context,
                  'Card addition feature coming soon!',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: const Text('Add Card'),
            ),
          ],
        );
      },
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
