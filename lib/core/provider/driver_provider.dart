import 'package:flutter/material.dart';

class DriverProvider extends ChangeNotifier {
  bool _isOnline = false;
  double _dailyEarnings = 0.0;
  int _totalTrips = 0;
  Duration _onlineTime = Duration.zero;

  // Getters
  bool get isOnline => _isOnline;
  double get dailyEarnings => _dailyEarnings;
  int get totalTrips => _totalTrips;
  Duration get onlineTime => _onlineTime;

  // Formatted getters
  String get formattedEarnings => 'LKR ${_dailyEarnings.toStringAsFixed(2)}';
  String get formattedOnlineTime {
    final hours = _onlineTime.inHours;
    final minutes = _onlineTime.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  /// Toggle online status
  void toggleOnlineStatus() {
    _isOnline = !_isOnline;
    notifyListeners();
  }

  /// Set online status
  void setOnlineStatus(bool status) {
    _isOnline = status;
    notifyListeners();
  }

  /// Add trip earnings
  void addTrip(double earnings) {
    _totalTrips++;
    _dailyEarnings += earnings;
    notifyListeners();
  }

  /// Update online time
  void updateOnlineTime(Duration time) {
    _onlineTime = time;
    notifyListeners();
  }

  /// Reset daily stats
  void resetDailyStats() {
    _dailyEarnings = 0.0;
    _totalTrips = 0;
    _onlineTime = Duration.zero;
    notifyListeners();
  }
}
