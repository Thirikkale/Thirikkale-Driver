import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/features/trip_history/widgets/trip_card.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  List<Map<String, dynamic>> _allTrips = [];
  DateTime? _startDate;
  DateTime? _endDate;
  String _sortBy = 'latest'; // 'latest', 'oldest', 'amount'

  @override
  void initState() {
    super.initState();
    _initializeTrips();
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _initializeTrips() {
    // TODO: Replace with actual API call
    _allTrips = List.generate(
      10,
      (index) => {
        'id': 'TRIP${index + 1}',
        'isCompleted': index % 3 != 0,
        'amount': 250.0 + (index * 50),
        'dateTime': DateTime.now().subtract(Duration(days: index, hours: index)),
        'pickup': 'Central Mall, Thirikkale',
        'dropoff': 'Railway Station, Thirikkale',
        'duration': '${15 + (index % 30)} mins',
        'distance': '${2 + (index % 8)} km',
      },
    );
    _sortTrips();
  }

  void _sortTrips() {
    setState(() {
      switch (_sortBy) {
        case 'latest':
          _allTrips.sort((a, b) => (b['dateTime'] as DateTime).compareTo(a['dateTime'] as DateTime));
          break;
        case 'oldest':
          _allTrips.sort((a, b) => (a['dateTime'] as DateTime).compareTo(b['dateTime'] as DateTime));
          break;
        case 'amount':
          _allTrips.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
          break;
      }
    });
  }

  void _filterByDateRange(DateTimeRange? dateRange) {
    if (dateRange != null) {
      setState(() {
        _startDate = dateRange.start;
        _endDate = dateRange.end;
        _initializeTrips(); // Reset to all trips
        _allTrips = _allTrips.where((trip) {
          final tripDate = trip['dateTime'] as DateTime;
          return tripDate.isAfter(_startDate!) && 
                 tripDate.isBefore(_endDate!.add(const Duration(days: 1)));
        }).toList();
        _sortTrips();
      });
    }
  }

  void _showDateRangePicker(BuildContext context) {
    showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    ).then(_filterByDateRange);
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text('Sort by', style: AppTextStyles.heading3),
          ),
          ListTile(
            leading: Icon(Icons.access_time, color: AppColors.primaryBlue),
            title: Text('Latest First', style: AppTextStyles.bodyMedium),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _sortBy = 'latest';
                _sortTrips();
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.history, color: AppColors.primaryBlue),
            title: Text('Oldest First', style: AppTextStyles.bodyMedium),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _sortBy = 'oldest';
                _sortTrips();
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.monetization_on, color: AppColors.primaryBlue),
            title: Text('Amount (High to Low)', style: AppTextStyles.bodyMedium),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _sortBy = 'amount';
                _sortTrips();
              });
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTripsList(BuildContext context, bool? isCompleted) {
    final trips = _allTrips.where((trip) => 
      isCompleted == null || trip['isCompleted'] == isCompleted
    ).toList();

    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No trips found',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return TripCard(
          isCompleted: trip['isCompleted'] as bool,
          amount: trip['amount'] as double,
          time: _formatDateTime(trip['dateTime'] as DateTime),
          pickup: trip['pickup'] as String,
          dropoff: trip['dropoff'] as String,
          duration: trip['duration'] as String,
          distance: trip['distance'] as String,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Trip History', style: AppTextStyles.heading3),
          actions: [
            IconButton(
              icon: Icon(Icons.calendar_today, color: AppColors.primaryBlue),
              onPressed: () => _showDateRangePicker(context),
            ),
            IconButton(
              icon: Icon(Icons.sort, color: AppColors.primaryBlue),
              onPressed: () => _showSortOptions(context),
            ),
          ],
          bottom: TabBar(
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
            labelStyle: AppTextStyles.button,
            unselectedLabelStyle: AppTextStyles.bodyMedium,
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryBlue,
          ),
        ),
        body: TabBarView(
          children: [
            _buildTripsList(context, null), // All trips
            _buildTripsList(context, true), // Completed trips
            _buildTripsList(context, false), // Cancelled trips
          ],
        ),
      ),
    );
  }
}