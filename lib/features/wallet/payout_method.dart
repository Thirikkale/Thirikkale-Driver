import 'package:flutter/material.dart';
import 'package:thirikkale_driver/widgets/common/custom_input_field_label.dart';

class PayoutMethod extends StatefulWidget {
  const PayoutMethod({super.key});

  @override
  State<PayoutMethod> createState() => _PayoutMethodState();
}

class _PayoutMethodState extends State<PayoutMethod> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbarName(title: "Payout Method", showBackButton: true),
    );
  }
}