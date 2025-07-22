import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/features/wallet/payout_history.dart';
import 'package:thirikkale_driver/features/wallet/payout_method.dart';
import 'package:thirikkale_driver/features/wallet/transaction_summary.dart';
import 'package:thirikkale_driver/widgets/common/custom_input_field_label.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {

  String balance = "4,999 LKR";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbarName(
        title: "Wallet",
        showBackButton: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(20),
            Container(
              padding: EdgeInsets.all(15),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.subtleGrey,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Balance",
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(balance, style: AppTextStyles.heading1.copyWith(fontSize: 35)),
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TransactionSummary(),)
                          ),
                          child: Icon(Icons.arrow_forward_ios, color: AppColors.grey,)
                        ),
                      ]
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text("This is your current account balance", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey)),
                  ),
                  Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 15, top:8, bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.bolt, color: AppColors.white),
                            Text("Cash out", style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.white),),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TransactionSummary(),)
                          ),
                        child: Container(
                          padding: EdgeInsets.only(left: 15, right: 15, top:8, bottom: 8),
                          decoration: BoxDecoration(
                            color: AppColors.grey,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Summary", style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.white),),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Gap(10),
                ],
              ),
            ),
            Gap(30),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PayoutHistory())
              ),
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.lightGrey,
                    width: 2,
                  )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.monetization_on_sharp),
                        Gap(13),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Payout History", style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold)),
                            Text("Last payout : 12-07-2025  18:44h", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey)),
                          ],
                        )
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios, color: AppColors.grey, size: 20,),
                  ],
                ),
              ),
            ),
            Gap(10),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PayoutMethod(),)
              ),
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.lightGrey,
                    width: 2,
                  )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_balance_sharp),
                        Gap(13),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Payout method", style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold)),
                            Text("Bank account: xxxx xxxx xxxx 1234", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey)),
                          ],
                        )
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios, color: AppColors.grey, size: 20,),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
