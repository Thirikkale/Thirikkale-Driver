import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_driver/core/provider/location_provider.dart';
import 'package:thirikkale_driver/core/provider/driver_provider.dart';
import 'package:thirikkale_driver/core/services/location_service.dart';
import 'package:thirikkale_driver/core/services/map_service.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/core/utils/navigation_utils.dart';
import 'package:thirikkale_driver/core/utils/snackbar_helper.dart';
import 'package:thirikkale_driver/features/home/widgets/driver_sidebar.dart';
import 'package:thirikkale_driver/features/home/widgets/location_search_widget.dart';
// import 'package:thirikkale_driver/features/home/widgets/driver_status_widget.dart';
// import 'package:thirikkale_driver/features/home/widgets/earnings_bottom_sheet.dart';
import 'package:thirikkale_driver/features/home/widgets/sliding_go_button.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _locationSubscription;

  // Map state
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Search state
  String? _selectedDestination;
  LatLng? _destinationLocation;

  @override
  void initState() {
    super.initState();
    // Defer location initialization to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    LocationService.stopWatchingLocation();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );

    try {
      // Get initial location
      await locationProvider.getCurrentLocation();

      if (locationProvider.currentLocation != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateCurrentLocationMarker();
          _animateToCurrentLocation();
        });

        // Start watching location changes
        _startLocationTracking();
      }
    } catch (e) {
      if (mounted) {
        _showLocationPermissionDialog();
      }
    }
  }

  void _startLocationTracking() {
    _locationSubscription = LocationService.watchLocation(
      onLocationUpdate: (location) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final locationProvider = Provider.of<LocationProvider>(
              context,
              listen: false,
            );
            locationProvider.updateCurrentLocation(location);
            _updateCurrentLocationMarker();
          });
        }
      },
      onError: (error) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SnackbarHelper.showErrorSnackBar(context, error);
          });
        }
      },
    );
  }

  void _updateCurrentLocationMarker() {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    final currentLocation = locationProvider.currentLocation;

    if (currentLocation != null) {
      final position = LatLng(
        currentLocation['latitude'],
        currentLocation['longitude'],
      );

      setState(() {
        _markers.removeWhere(
          (marker) => marker.markerId.value == 'current_location',
        );
        _markers.add(MapService.createCurrentLocationMarker(position));
      });
    }
  }

  void _animateToCurrentLocation() {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    final currentLocation = locationProvider.currentLocation;

    if (_mapController != null && currentLocation != null) {
      final position = LatLng(
        currentLocation['latitude'],
        currentLocation['longitude'],
      );

      MapService.animateToPosition(_mapController!, position);
    }
  }

  void _onLocationSelected(String locationName, LatLng location) {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    final currentLocation = locationProvider.currentLocation;

    setState(() {
      _selectedDestination = locationName;
      _destinationLocation = location;

      // Add destination marker
      _markers.removeWhere((marker) => marker.markerId.value == 'destination');
      _markers.add(MapService.createDestinationMarker(location, locationName));

      // Create polyline if current location exists
      if (currentLocation != null) {
        _createPolyline();
      }
    });

    _animateToShowBothLocations();
  }

  void _createPolyline() {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    final currentLocation = locationProvider.currentLocation;

    if (currentLocation != null && _destinationLocation != null) {
      final start = LatLng(
        currentLocation['latitude'],
        currentLocation['longitude'],
      );

      setState(() {
        _polylines.clear();
        _polylines.add(
          MapService.createRoutePolyline(start, _destinationLocation!),
        );
      });
    }
  }

  void _animateToShowBothLocations() {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    final currentLocation = locationProvider.currentLocation;

    if (_mapController != null &&
        currentLocation != null &&
        _destinationLocation != null) {
      final start = LatLng(
        currentLocation['latitude'],
        currentLocation['longitude'],
      );

      final bounds = MapService.calculateBounds(start, _destinationLocation!);
      MapService.animateToBounds(_mapController!, bounds);
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
              'Please enable location permission to use the map features.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await LocationService.openAppSettings();
                },
                child: const Text('Settings'),
              ),
            ],
          ),
    );
  }

  void _toggleOnlineStatus() {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    driverProvider.toggleOnlineStatus();

    if (driverProvider.isOnline) {
      _showGoOnlineBottomSheet();
    }
  }

  void _showGoOnlineBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GoOnlineBottomSheet(),
    );
  }

  // void _showEarningsBottomSheet() {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => const EarningsBottomSheet(),
  //   );
  // }

  LatLng _getDefaultLocation() {
    const defaultLocation = LatLng(6.9271, 79.8612); // Colombo, Sri Lanka
    return defaultLocation;
  }

  LatLng _getInitialCameraPosition() {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    final currentLocation = locationProvider.currentLocation;

    if (currentLocation != null) {
      return LatLng(currentLocation['latitude'], currentLocation['longitude']);
    }

    return _getDefaultLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const DriverSidebar(),
      body: Consumer2<LocationProvider, DriverProvider>(
        builder: (context, locationProvider, driverProvider, child) {
          final currentLocationMap = locationProvider.currentLocation;
          final LatLng? currentUserPosition =
              currentLocationMap != null
                  ? LatLng(
                    currentLocationMap['latitude'],
                    currentLocationMap['longitude'],
                  )
                  : null;
          return Stack(
            children: [
              // Google Map
              locationProvider.isLoadingCurrentLocation
                  ? const Center(child: CircularProgressIndicator())
                  : GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;

                      // Use addPostFrameCallback to avoid calling during build
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (locationProvider.currentLocation != null) {
                          _animateToCurrentLocation();
                        }
                      });
                    },
                    initialCameraPosition: CameraPosition(
                      target: _getInitialCameraPosition(),
                      zoom: 14.0, // Zoom in for more street-level detail
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    myLocationEnabled:
                        true, // Disable default location dot since we have custom marker
                    myLocationButtonEnabled: false,
                    mapType: MapType.normal,
                    zoomControlsEnabled: false,
                    compassEnabled: true,
                    rotateGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    mapToolbarEnabled: false,
                    trafficEnabled: false, // Can be enabled if needed
                  ),

              // Top overlay with search and menu
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        AppDimensions.pageHorizontalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Menu button
                              GestureDetector(
                                onTap:
                                    () =>
                                        _scaffoldKey.currentState?.openDrawer(),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.menu,
                                    color: AppColors.textPrimary,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Search bar
                              Expanded(
                                child: LocationSearchWidget(
                                  onLocationSelected: _onLocationSelected,
                                  currentUserLocation: currentUserPosition,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Navigate button (shows when destination is selected)
              if (_selectedDestination != null)
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 200,
                  left: AppDimensions.pageHorizontalPadding,
                  child: ElevatedButton.icon(
                    onPressed: _launchNavigation,
                    icon: const Icon(Icons.navigation, color: Colors.white),
                    label: const Text(
                      'Navigate',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),

              // // Driver status widget (top right)
              // Positioned(
              //   top: MediaQuery.of(context).padding.top + 80,
              //   right: AppDimensions.pageHorizontalPadding,
              //   child: DriverStatusWidget(
              //     isOnline: driverProvider.isOnline,
              //     onTap: _showEarningsBottomSheet,
              //   ),
              // ),

              // Go online/offline button (bottom center)
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: SlidingGoButton(
                    isOnline: driverProvider.isOnline,
                    onToggle: _toggleOnlineStatus,
                  ),
                ),
              ),

              // Current location button
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 200,
                right: AppDimensions.pageHorizontalPadding,
                child: FloatingActionButton(
                  backgroundColor: AppColors.white,
                  onPressed: _animateToCurrentLocation,
                  child: const Icon(
                    Icons.my_location,
                    color: AppColors.primaryBlue,
                    size: 30,
                  ),
                ),
              ),

              // Error message for location
              if (locationProvider.locationError != null)
                Positioned(
                  bottom: 300,
                  left: AppDimensions.pageHorizontalPadding,
                  right: AppDimensions.pageHorizontalPadding,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            locationProvider.locationError!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await locationProvider.getCurrentLocation();
                          },
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _launchNavigation() async {
    if (_destinationLocation != null) {
      await NavigationUtils.launchGoogleMapsNavigation(
        destinationLat: _destinationLocation!.latitude,
        destinationLng: _destinationLocation!.longitude,
        destinationName: _selectedDestination,
      );
    }
  }
}

// Go Online Bottom Sheet
class GoOnlineBottomSheet extends StatelessWidget {
  const GoOnlineBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pageHorizontalPadding,
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text('You\'re now online!', style: AppTextStyles.heading2),
                const SizedBox(height: 8),
                Text(
                  'You\'ll start receiving ride requests from nearby passengers.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppButtonStyles.primaryButton,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Got it'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
