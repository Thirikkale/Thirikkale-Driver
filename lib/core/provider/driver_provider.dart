import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/services/availability_service.dart';

class DriverProvider extends ChangeNotifier {
  final AvailabilityService _availabilityService =
      AvailabilityService();

  bool _isOnline = false;
  double _dailyEarnings = 0.0;
  int _totalTrips = 0;
  Duration _onlineTime = Duration.zero;
  bool _isSettingAvailability = false;
  String? _errorMessage;

  // Getters
  bool get isOnline => _isOnline;
  double get dailyEarnings => _dailyEarnings;
  int get totalTrips => _totalTrips;
  Duration get onlineTime => _onlineTime;
  bool get isSettingAvailability => _isSettingAvailability;
  String? get errorMessage => _errorMessage;

  // Formatted getters
  String get formattedEarnings => 'LKR ${_dailyEarnings.toStringAsFixed(2)}';
  String get formattedOnlineTime {
    final hours = _onlineTime.inHours;
    final minutes = _onlineTime.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  /// Set driver availability (with backend integration)
  Future<bool> setDriverAvailability({
    required String driverId,
    required double latitude,
    required double longitude,
    required bool isAvailable,
    required String accessToken,
  }) async {
    _isSettingAvailability = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _availabilityService.setDriverAvailability(
        driverId: driverId,
        latitude: latitude,
        longitude: longitude,
        isAvailable: isAvailable,
        accessToken: accessToken,
      );

      if (result['success'] == true) {
        _isOnline = isAvailable;
        print('✅ Driver availability set successfully: $isAvailable');

        // If going offline, reset online time tracking
        if (!isAvailable) {
          _onlineTime = Duration.zero;
        }

        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error'] ?? 'Failed to set availability';
        print('❌ Failed to set driver availability: $_errorMessage');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error occurred';
      print('❌ Error in setDriverAvailability: $e');
      notifyListeners();
      return false;
    } finally {
      _isSettingAvailability = false;
      notifyListeners();
    }
  }

  /// Toggle online status
  Future<bool> toggleOnlineStatus({
    required String driverId,
    required double latitude,
    required double longitude,
    required String accessToken,
  }) async {
    return await setDriverAvailability(
      driverId: driverId,
      latitude: latitude,
      longitude: longitude,
      isAvailable: !_isOnline,
      accessToken: accessToken,
    );
  }

  /// Set online status locally (for offline usage)
  void setOnlineStatusLocally(bool status) {
    _isOnline = status;
    if (!status) {
      _onlineTime = Duration.zero;
    }
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
  void updateOnlineTime(Duration additionalTime) {
    if (_isOnline) {
      _onlineTime = _onlineTime + additionalTime;
      notifyListeners();
    }
  }

  /// Reset daily stats
  void resetDailyStats() {
    _dailyEarnings = 0.0;
    _totalTrips = 0;
    _onlineTime = Duration.zero;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

