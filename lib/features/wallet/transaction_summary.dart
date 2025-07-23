import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/widgets/common/custom_input_field_label.dart';

class TransactionSummary extends StatefulWidget {
  const TransactionSummary({super.key});

  @override
  State<TransactionSummary> createState() => _TransactionSummaryState();
}

class _TransactionSummaryState extends State<TransactionSummary> {
  final List<Map<String, List<Map<String, String>>>> history = [
    {
      "July 23": [
        {
          "type": "Zip",
          "tripTime": "1:37pm",
          "paymentType": "card payment",
          "price": "LKR 999.0",
        },
        {
          "type": "Drive pass",
          "tripTime": "3:20pm",
          "price": "LKR 520.0",
        },
      ],
    },
    {
      "July 22": [
        {
          "type": "Payout",
          "tripTime": "9:00am",
          "price": "LKR 750.0",
        },
      ],
    },
  ];

  IconData getTripIcon(String type) {
    switch (type.toLowerCase()) {
      case 'zip':
        return Icons.directions_car;
      case 'drive pass':
        return Icons.local_activity;
      case 'payout':
        return Icons.monetization_on;
      default:
        return Icons.receipt_long;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbarName(title: "Transaction Summary", showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final entry = history[index].entries.first;
            final date = entry.key;
            final trips = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(10),
                ...trips.map((trip) {
                  final type = trip["type"] ?? "";
                  final tripTime = trip["tripTime"] ?? "";
                  final price = trip["price"] ?? "";

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          padding: const EdgeInsets.all(2),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.subtleGrey,
                            borderRadius: BorderRadius.circular(45),
                          ),
                          child: Icon(getTripIcon(type), size: 30),
                        ),
                        const Gap(10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        type,
                                        style:
                                            AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        type.toLowerCase() == "zip"
                                            ? "$tripTime • ${trip["paymentType"] ?? ""}"
                                            : tripTime,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    price,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Colors.grey,
                                thickness: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const Gap(16),
              ],
            );
          },
        ),
      ),
    );
  }
}
