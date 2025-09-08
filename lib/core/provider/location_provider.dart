import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:thirikkale_driver/core/services/location_service.dart';
import 'package:thirikkale_driver/core/services/places_api_service.dart';

class LocationProvider extends ChangeNotifier {
  // Current location state
  Map<String, dynamic>? _currentLocation;
  Position? _currentPosition;
  bool _isLoadingCurrentLocation = false;
  String? _locationError;

  // Places search state
  List<Map<String, dynamic>> _placePredictions = [];
  bool _isSearchingPlaces = false;
  String? _searchError;

  // Session management
  String _sessionToken = '';

  // Getters
  Map<String, dynamic>? get currentLocation => _currentLocation;
  Position? get currentPosition => _currentPosition; 
  bool get isLoadingCurrentLocation => _isLoadingCurrentLocation;
  String? get locationError => _locationError;

  List<Map<String, dynamic>> get placePredictions => _placePredictions;
  bool get isSearchingPlaces => _isSearchingPlaces;
  String? get searchError => _searchError;

  String get sessionToken => _sessionToken;

  // Helper methods for state management
  void _setLoadingCurrentLocation(bool loading) {
    _isLoadingCurrentLocation = loading;
    notifyListeners();
  }

  void _setCurrentLocation(Map<String, dynamic>? location) {
    _currentLocation = location;

    // Also update the Position object
    if (location != null) {
      _currentPosition = Position(
        latitude: location['latitude'],
        longitude: location['longitude'],
        timestamp: DateTime.now(),
        accuracy: location['accuracy'] ?? 0.0,
        altitude: location['altitude'] ?? 0.0,
        altitudeAccuracy: location['altitudeAccuracy'] ?? 0.0,
        heading: location['heading'] ?? 0.0,
        headingAccuracy: location['headingAccuracy'] ?? 0.0,
        speed: location['speed'] ?? 0.0,
        speedAccuracy: location['speedAccuracy'] ?? 0.0,
      );
    } else {
      _currentPosition = null;
    }

    notifyListeners();
  }

  void _setLocationError(String? error) {
    _locationError = error;
    notifyListeners();
  }

  void _setSearchingPlaces(bool searching) {
    _isSearchingPlaces = searching;
    notifyListeners();
  }

  void _setPlacePredictions(List<Map<String, dynamic>> predictions) {
    _placePredictions = predictions;
    notifyListeners();
  }

  void _setSearchError(String? error) {
    _searchError = error;
    notifyListeners();
  }

  void _resetLocationState() {
    _currentLocation = null;
    _isLoadingCurrentLocation = false;
    _locationError = null;
  }

  void _resetSearchState() {
    _placePredictions = [];
    _isSearchingPlaces = false;
    _searchError = null;
  }

  // Check if location is available
  bool get isLocationAvailable =>
      _currentLocation != null && _currentPosition != null;

  // Current Location Methods
  Future<void> getCurrentLocation() async {
    print('🔍 LocationProvider: Getting current location...');
    _setLoadingCurrentLocation(true);
    _setLocationError(null);

    try {
      final location = await LocationService.getCurrentLocation();
      print('✅ LocationProvider: Location obtained: ${location}');
      _setCurrentLocation(location);
      _setLocationError(null);
    } on LocationServiceException catch (e) {
      print('❌ LocationProvider: LocationServiceException: ${e.message}');
      _setLocationError(e.message);
      _setCurrentLocation(null);
    } catch (e) {
      print('❌ LocationProvider: Generic error: ${e.toString()}');
      _setLocationError('Failed to get location: ${e.toString()}');
      _setCurrentLocation(null);
    } finally {
      _setLoadingCurrentLocation(false);
    }
  }

  // Try to get last known location first (faster)
  Future<void> getLocationQuick() async {
    _setLoadingCurrentLocation(true);
    _setLocationError(null);

    try {
      // Try last known location first
      final lastKnown = await LocationService.getLastKnownLocation();
      if (lastKnown != null) {
        _setCurrentLocation(lastKnown);
      }

      // Then get fresh location
      final location = await LocationService.getCurrentLocation();
      _setCurrentLocation(location);
      _setLocationError(null);
    } on LocationServiceException catch (e) {
      _setLocationError(e.message);
      if (_currentLocation == null) {
        _setCurrentLocation(null);
      }
    } catch (e) {
      _setLocationError('Failed to get location: ${e.toString()}');
      if (_currentLocation == null) {
        _setCurrentLocation(null);
      }
    } finally {
      _setLoadingCurrentLocation(false);
    }
  }

  // Places Search Methods
  Future<void> searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      clearSearchResults();
      return;
    }

    _setSearchingPlaces(true);
    _setSearchError(null);

    try {
      final predictions = await PlacesApiService.getPlacePredictions(
        query,
        sessionToken: _sessionToken,
        latitude: _currentLocation?['latitude'],
        longitude: _currentLocation?['longitude'],
      );

      _setPlacePredictions(predictions);
      _setSearchError(null);
    } on PlacesApiException catch (e) {
      _setSearchError(e.message);
      _setPlacePredictions([]);
    } catch (e) {
      _setSearchError('Search failed. Please try again.');
      _setPlacePredictions([]);
    } finally {
      _setSearchingPlaces(false);
    }
  }

  void clearSearchResults() {
    _setPlacePredictions([]);
  }

  void generateNewSessionToken() {
    _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Get formatted address string
  String get currentLocationAddress {
    if (_currentLocation != null) {
      return _currentLocation!['shortAddress'] ??
          _currentLocation!['address'] ??
          'Current Location';
    }
    return 'Current Location';
  }

  // Check if location permission is needed
  bool get needsLocationPermission =>
      _currentLocation == null && _locationError != null;

  // Get coordinates
  double? get currentLatitude => _currentLocation?['latitude'];
  double? get currentLongitude => _currentLocation?['longitude'];

  // Reset all states
  void reset() {
    _resetLocationState();
    _resetSearchState();
    generateNewSessionToken();
    notifyListeners();
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    await LocationService.openLocationSettings();
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await LocationService.openAppSettings();
  }

  // Update Current Location (safe for build phase)
  // Update Current Location (safe for build phase)
  void updateCurrentLocation(Map<String, dynamic> location) {
    // Store location immediately without notifying
    _currentLocation = location;

    // Also update Position object
    _currentPosition = Position(
      latitude: location['latitude'],
      longitude: location['longitude'],
      timestamp: DateTime.now(),
      accuracy: location['accuracy'] ?? 0.0,
      altitude: location['altitude'] ?? 0.0,
      altitudeAccuracy: location['altitudeAccuracy'] ?? 0.0,
      heading: location['heading'] ?? 0.0,
      headingAccuracy: location['headingAccuracy'] ?? 0.0,
      speed: location['speed'] ?? 0.0,
      speedAccuracy: location['speedAccuracy'] ?? 0.0,
    );
  
    // Schedule notification for after the current build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
