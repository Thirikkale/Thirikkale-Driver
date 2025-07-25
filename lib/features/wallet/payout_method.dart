import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar_name.dart';

class PayoutMethod extends StatefulWidget {
  const PayoutMethod({super.key});

  @override
  State<PayoutMethod> createState() => _PayoutMethodState();
}

class _PayoutMethodState extends State<PayoutMethod> {
  final List<Map<String, List<Map<String, String>>>> accounts = [
    {
      "account_1": [
        {"account_number": "xxxx xxxx xxxx 1234"},
      ],
    },
    {
      "account_2": [
        {"account_number": "xxxx xxxx xxxx 5678"},
      ],
    },
    {
      "account_3": [
        {"account_number": "xxxx xxxx xxxx 9101"},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final selectedAccount = accounts[0].entries.first;

    return Scaffold(
      appBar: CustomAppbarName(title: "Payout Method", showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Selected account", style: AppTextStyles.heading3),
              const Gap(8),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.primaryBlue,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance_sharp),
                        const Gap(13),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bank Account",
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              selectedAccount.value.first["account_number"] ?? "",
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.grey,
                      size: 20,
                    ),
                  ],
                ),
              ),
              const Gap(30),
              const Text(
                "Payouts will be deposited to this account within 24h of the request. Limited no.of free payouts are allowed per week, extra payouts will be subject to an additional fee.",
              ),
              const Gap(40),
              Text("Linked accounts", style: AppTextStyles.heading3),
              const Gap(15),

              // === All Linked Accounts ===
              ...accounts.map((accountMap) {
                final entry = accountMap.entries.first;
                final accountNumber = entry.value.first["account_number"] ?? "";

                return Container(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.account_balance_sharp),
                              const Gap(13),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Bank Account",
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    accountNumber,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.grey,
                            size: 20,
                          ),
                        ],
                      ),
                      const Gap(5),
                      const Divider(
                        thickness: 1,
                        color: AppColors.lightGrey,
                        indent: 40, // aligns under text only
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
