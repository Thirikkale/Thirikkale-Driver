import 'package:flutter/material.dart';
import 'package:thirikkale_driver/features/trip_history/widgets/trip_card.dart';

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings Activity'),
        actions: [
          IconButton(icon: const Icon(Icons.account_balance_wallet), onPressed: () {}),
          IconButton(icon: const Icon(Icons.sort), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButton<String>(
                      value: 'All',
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: ['All', 'Completed', 'Cancelled']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) {},
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButton<String>(
                      value: 'Feature',
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: ['Feature', 'Date', 'Amount']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) {},
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Trip List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: 10,
              itemBuilder: (context, index) => const TripCard(),
            ),
          ),
        ],
      ),
    );
  }
}
