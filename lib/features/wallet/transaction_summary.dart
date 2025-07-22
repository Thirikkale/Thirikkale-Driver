import 'package:flutter/material.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar_name.dart';

class TransactionSummary extends StatelessWidget {
  const TransactionSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbarName(title: "Transaction Summary", showBackButton: true),
    );
  }
}