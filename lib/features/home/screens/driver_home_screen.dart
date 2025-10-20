import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_driver/core/provider/auth_provider.dart';
import 'package:thirikkale_driver/core/provider/location_provider.dart';
import 'package:thirikkale_driver/core/provider/driver_provider.dart';
import 'package:thirikkale_driver/core/provider/ride_provider.dart';
import 'package:thirikkale_driver/core/services/location_service.dart';
import 'package:thirikkale_driver/core/services/map_service.dart';
import 'package:thirikkale_driver/core/services/ride_request_service.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/core/utils/navigation_utils.dart';
import 'package:thirikkale_driver/core/utils/snackbar_helper.dart';
import 'package:thirikkale_driver/features/home/models/ride_request_model.dart'
    hide LatLng;
import 'package:thirikkale_driver/features/home/widgets/driver_sidebar.dart';
import 'package:thirikkale_driver/features/home/widgets/location_error.dart';
import 'package:thirikkale_driver/features/home/widgets/location_search_widget.dart';
import 'package:thirikkale_driver/features/home/widgets/ride_details_bottom_sheet.dart';
import 'package:thirikkale_driver/features/home/widgets/sliding_go_button.dart';
import 'package:thirikkale_driver/features/home/widgets/online_driver_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController? _mapController;
  final Completer<GoogleMapController> _mapControllerCompleter =
      Completer<GoogleMapController>();
  StreamSubscription<Position>? _locationSubscription;
  bool _isMapReady = false;

  // Map state
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Search state
  String? _selectedDestination;
  LatLng? _destinationLocation;
  String? _currentlyDisplayedRideId;

  bool _isShowingRideRequestOverlay = false;

  final DraggableScrollableController _onlineSheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    // Defer location initialization to avoid setState during build

    // Set status bar to light content (white icons/text)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // White icons
        statusBarBrightness: Brightness.dark, // For iOS
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
      _connectWebSocket(); // ✅ Connect WebSocket once on screen load
      _setupListeners();
    });
  }

  // ✅ Connect WebSocket once and keep it alive
  void _connectWebSocket() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final driverId = authProvider.userId;
    final accessToken = await authProvider.getCurrentToken();

    if (driverId != null && accessToken != null) {
      print(
        '🔊 Starting persistent WebSocket connection for driver: $driverId',
      );
      await rideProvider.startListeningForRideRequests(driverId, accessToken);
    }
  }

  void _setupListeners() {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);

    // ✅ Add explicit stream listener
    rideProvider.rideRequestStream.listen(
      (rideRequest) {
        print(
          '🔔🔔🔔 FLUTTER HOME: Received ride request via stream: ${rideRequest.rideId}',
        );
        print('🔔🔔🔔 FLUTTER HOME: Pickup: ${rideRequest.pickupAddress}');

        if (mounted) {
          _showRideRequestOverlay(rideRequest);
        }
      },
      onError: (error) {
        print('❌❌❌ FLUTTER HOME: Stream error: $error');
      },
    );

    // Enhanced ride request listener with proper state handling
    rideProvider.addListener(() {
      // Show ride request overlay when new request received
      if (rideProvider.rideStatus == RideStatus.requestReceived &&
          rideProvider.currentRideRequest != null &&
          !rideProvider.isAcceptingRide &&
          !_isShowingRideRequestOverlay) {
        _showRideRequestOverlay(rideProvider.currentRideRequest!);
      }

      // Handle successful ride acceptance
      if (rideProvider.rideStatus == RideStatus.accepted &&
          rideProvider.currentRideRequest != null &&
          _currentlyDisplayedRideId !=
              rideProvider.currentRideRequest?.rideId) {
        // Hide overlay if still showing
        if (_isShowingRideRequestOverlay) {
          RideRequestService().hideOverlay();
          _isShowingRideRequestOverlay = false;
        }

        // Show success message
        _showSuccessMessage('Ride accepted successfully!');

        // Automatically create routes and show ride details
        _createRideRoutes();
        _currentlyDisplayedRideId = rideProvider.currentRideRequest?.rideId;
      }

      // Handle ride completion/cancellation
      if (rideProvider.rideStatus == RideStatus.idle &&
          _currentlyDisplayedRideId != null) {
        // Clear routes and reset map
        setState(() {
          _polylines.clear();
          _markers.removeWhere((m) => m.markerId.value != 'current_location');
        });
        _currentlyDisplayedRideId = null;
        _animateToCurrentLocation();
      }

      // Handle acceptance errors
      if (rideProvider.lastAcceptanceError != null) {
        _handleAcceptanceError(rideProvider.lastAcceptanceError!);
        rideProvider.clearAcceptanceError();
      }
    });
  }

  void _showRideRequestOverlay(RideRequest rideRequest) {
    _isShowingRideRequestOverlay = true;

    RideRequestService().showRideRequest(
      context,
      rideRequest,
      () => _handleAcceptRide(rideRequest),
      () => _handleDeclineRide(rideRequest),
    );
  }

  Future<void> _handleAcceptRide(RideRequest rideRequest) async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Hide the overlay
    RideRequestService().hideOverlay();
    _isShowingRideRequestOverlay = false;

    // Show loading dialog
    _showLoadingDialog('Accepting ride...');

    final driverId = authProvider.userId;
    final accessToken = await authProvider.getCurrentToken();

    if (driverId == null || accessToken == null) {
      _hideLoadingDialog();
      _showErrorMessage('Authentication error. Please login again.');
      return;
    }

    final result = await rideProvider.acceptRideWithDetails(
      driverId,
      accessToken,
    );

    _hideLoadingDialog();

    if (result['success'] == true) {
      // Success is handled by the listener in _setupRideRequestListener
      print('✅ Ride accepted: ${rideRequest.rideId}');
    } else {
      // Error is handled by the listener in _setupRideRequestListener
      print('❌ Failed to accept ride: ${result['error']}');
    }
  }

  // ✅ Handle decline ride action
  Future<void> _handleDeclineRide(RideRequest rideRequest) async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Hide the overlay
    RideRequestService().hideOverlay();
    _isShowingRideRequestOverlay = false;

    final driverId = authProvider.userId;
    final accessToken = await authProvider.getCurrentToken();

    await rideProvider.cancelRide('Driver declined', driverId, accessToken);

    _showInfoMessage('Ride request declined');
  }

  // ✅ Show loading dialog
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => WillPopScope(
            onWillPop: () async => false,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(message),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  // Hide loading dialog
  void _hideLoadingDialog() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  // Show success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show error message with retry option
  void _showErrorMessage(String message, {VoidCallback? onRetry}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action:
            onRetry != null
                ? SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: onRetry,
                )
                : null,
      ),
    );
  }

  // Show info message
  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  //  Handle acceptance errors with appropriate UI feedback
  void _handleAcceptanceError(String error) {
    // Determine if retry is possible based on error
    bool canRetry =
        !error.contains('already been accepted') &&
        !error.contains('Authentication');

    _showErrorMessage(
      error,
      onRetry:
          canRetry
              ? () {
                final rideProvider = Provider.of<RideProvider>(
                  context,
                  listen: false,
                );
                if (rideProvider.currentRideRequest != null) {
                  _handleAcceptRide(rideProvider.currentRideRequest!);
                }
              }
              : null,
    );
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
            final rideProvider = Provider.of<RideProvider>(
              context,
              listen: false,
            );
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            final driverProvider = Provider.of<DriverProvider>(
              context,
              listen: false,
            );

            locationProvider.updateCurrentLocation(location);
            _updateCurrentLocationMarker();

            // Update location via WebSocket if online and connected
            if (driverProvider.isOnline && rideProvider.isConnected) {
              final driverId = authProvider.userId;
              if (driverId != null) {
                rideProvider.updateDriverLocation(
                  driverId,
                  location['latitude'],
                  location['longitude'],
                  true, // isAvailable
                );
              }
            }
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

  @override
  void dispose() {
    // Remove the listener when disposing
    final rideProvider = Provider.of<RideProvider>(context, listen: false);

    // Remove listeners if they exist
    try {
      rideProvider.removeListener(_setupListeners);
    } catch (e) {
      print('Note: Ride provider listener was not attached');
    }

    _locationSubscription?.cancel();
    _mapController?.dispose();
    LocationService.stopWatchingLocation();
    rideProvider
        .stopListeningForRideRequests(); // ✅ Disconnect WebSocket on dispose

    if (_isShowingRideRequestOverlay) {
      RideRequestService().hideOverlay();
    }

    super.dispose();
  }

  Future<void> _initializeLocation() async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    await locationProvider.getCurrentLocation();

    if (!mounted) return;

    if (locationProvider.locationError != null) {
      // If there's an error, show the permission dialog.
      _showLocationPermissionDialog();
    } else if (locationProvider.currentLocation != null) {
      // If successful, proceed with updating the map.
      _updateCurrentLocationMarker();
      _animateToCurrentLocation();
      _startLocationTracking();
    }
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

  // Map creation callback
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (!_mapControllerCompleter.isCompleted) {
      _mapControllerCompleter.complete(controller);
    }

    // Set map ready flag after a small delay to ensure controller is fully initialized
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isMapReady = true;
        });

        // Now it's safe to animate
        final locationProvider = Provider.of<LocationProvider>(
          context,
          listen: false,
        );
        if (locationProvider.currentLocation != null) {
          _animateToCurrentLocation();
        }
      }
    });
  }

  void _animateToCurrentLocation() async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    final currentLocation = locationProvider.currentLocation;

    if (currentLocation != null && _isMapReady) {
      final position = LatLng(
        currentLocation['latitude'],
        currentLocation['longitude'],
      );

      try {
        final GoogleMapController controller =
            await _mapControllerCompleter.future;
        await MapService.animateToPosition(controller, position);
      } catch (e) {
        print('Error animating to current location: $e');
      }
    }
  }

  void _animateToShowBothLocations() async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    final currentLocation = locationProvider.currentLocation;

    if (currentLocation != null &&
        _destinationLocation != null &&
        _isMapReady) {
      final currentPos = LatLng(
        currentLocation['latitude'],
        currentLocation['longitude'],
      );

      final bounds = MapService.calculateBounds(
        currentPos,
        _destinationLocation!,
      );

      try {
        final GoogleMapController controller =
            await _mapControllerCompleter.future;
        await MapService.animateToBounds(controller, bounds);
      } catch (e) {
        print('Error animating to bounds: $e');
      }
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

  // Clear created polyline by search
  void _clearSearchRoutes() {
    setState(() {
      _selectedDestination = null;
      _destinationLocation = null;
      _polylines.clear();
      _markers.removeWhere((marker) => marker.markerId.value == 'destination');
    });
  }

  void _createPolyline() async {
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

      // Clear existing polylines
      setState(() {
        _polylines.clear();
      });

      // Get the route polyline from Directions API
      final routePolyline = await MapService.createRoutePolyline(
        start,
        _destinationLocation!,
      );

      if (routePolyline != null && mounted) {
        setState(() {
          _polylines.add(routePolyline);
        });
      }
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
                  await LocationService.openLocationSettings();
                },
                child: const Text('Settings'),
              ),
            ],
          ),
    );
  }

  Future<void> _toggleOnlineStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );

    // Get required data
    final driverId = authProvider.userId;
    final accessToken = await authProvider.getCurrentToken();

    if (driverId == null || accessToken == null) {
      SnackbarHelper.showErrorSnackBar(
        context,
        'Unable to update status. Please login again.',
      );
      return;
    }

    // Check if location is available
    if (!locationProvider.isLocationAvailable) {
      await locationProvider.getCurrentLocation();
      if (!locationProvider.isLocationAvailable) {
        _showLocationDialog(locationProvider);
        return;
      }
    }

    final currentPosition = locationProvider.currentPosition!;
    print(
      '✅ Using location: ${currentPosition.latitude}, ${currentPosition.longitude}',
    );

    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Text(
                driverProvider.isOnline
                    ? 'Going offline...'
                    : 'Going online...',
              ),
            ],
          ),
          duration: const Duration(seconds: 30),
        ),
      );
    }

    try {
      final success = await driverProvider.toggleOnlineStatus(
        driverId: driverId,
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
        accessToken: accessToken,
      );

      // Hide loading snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      if (success) {
        if (mounted) {
          SnackbarHelper.showSuccessSnackBar(
            context,
            driverProvider.isOnline
                ? 'You are now online and ready to receive rides!'
                : 'You are now offline.',
          );
        }
      } else {
        if (mounted) {
          SnackbarHelper.showErrorSnackBar(
            context,
            driverProvider.errorMessage ??
                'Failed to update status. Please try again.',
          );
        }
      }
    } catch (e) {
      // Hide loading snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        SnackbarHelper.showErrorSnackBar(
          context,
          'Network error. Please check your connection and try again.',
        );
      }
    }
  }

  void _showLocationDialog(LocationProvider locationProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Location Required'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locationProvider.locationError ??
                      'Location access is required to go online.',
                ),
                const SizedBox(height: 16),
                const Text('Please ensure that:'),
                const SizedBox(height: 8),
                const Text('• Location services are enabled on your device'),
                const Text('• Location permission is granted to this app'),
                const SizedBox(height: 8),
                Text(
                  'Current status: ${locationProvider.locationError ?? "Unknown error"}',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await locationProvider.openLocationSettings();
                },
                child: const Text('Open Settings'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _initializeLocation();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
    );
  }

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

  void _createRideRoutes() async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    final rideProvider = Provider.of<RideProvider>(context, listen: false);

    final currentLocation = locationProvider.currentLocation;
    final rideRequest = rideProvider.currentRideRequest;

    if (currentLocation != null && rideRequest != null && _isMapReady) {
      final driverLocation = LatLng(
        currentLocation['latitude'],
        currentLocation['longitude'],
      );

      setState(() {
        _markers.clear();
        _polylines.clear();
      });

      _markers.add(MapService.createCurrentLocationMarker(driverLocation));
      _markers.add(
        MapService.createPickupMarker(
          rideRequest.pickupLocation as LatLng,
          rideRequest.pickupAddress,
        ),
      );
      _markers.add(
        MapService.createDropMarker(
          rideRequest.destinationLocation as LatLng,
          rideRequest.destinationAddress,
        ),
      );

      final driverToPickupRoute = await MapService.createDriverToPickupRoute(
        driverLocation,
        rideRequest.pickupLocation as LatLng,
      );
      final pickupToDestinationRoute =
          await MapService.createPickupToDestinationRoute(
            rideRequest.pickupLocation as LatLng,
            rideRequest.destinationLocation as LatLng,
          );

      if (mounted) {
        setState(() {
          if (driverToPickupRoute != null) {
            _polylines.add(driverToPickupRoute);
          }
          if (pickupToDestinationRoute != null) {
            _polylines.add(pickupToDestinationRoute);
          }
        });

        try {
          final GoogleMapController controller =
              await _mapControllerCompleter.future;
          final bounds = MapService.calculateRideBounds(
            driverLocation,
            rideRequest.pickupLocation as LatLng,
            rideRequest.destinationLocation as LatLng,
          );
          await MapService.animateToBounds(controller, bounds, padding: 150);
        } catch (e) {
          print('Error animating to ride bounds: $e');
        }
      }
    }
  }

  void _navigateToPickup() async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final rideRequest = rideProvider.currentRideRequest;

    if (rideRequest != null) {
      final url =
          'google.navigation:q=${rideRequest.pickupLat},${rideRequest.pickupLng}';
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        rideProvider.startNavigation();
      }
    }
  }

  void _showTestRideRequest() {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    if (!driverProvider.isOnline) {
      SnackbarHelper.showErrorSnackBar(
        context,
        'You must be online to receive ride requests.',
      );
      return;
    }
    final rideRequest = RideRequestService().generateDummyRideRequest();
    RideRequestService().showRideRequest(
      context,
      rideRequest,
      () => _handleAcceptRide(rideRequest),
      () => _handleDeclineRide(rideRequest),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const DriverSidebar(),
        body: Consumer3<LocationProvider, DriverProvider, RideProvider>(
          builder: (
            context,
            locationProvider,
            driverProvider,
            rideProvider,
            child,
          ) {
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
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _getInitialCameraPosition(),
                        zoom: 14.0,
                      ),
                      markers: _markers,
                      polylines: _polylines,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      mapType: MapType.normal,
                      zoomControlsEnabled: false,
                      compassEnabled: true,
                      rotateGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      tiltGesturesEnabled: true,
                      zoomGesturesEnabled: true,
                      mapToolbarEnabled: false,
                      trafficEnabled: false,
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
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap:
                                  () => _scaffoldKey.currentState?.openDrawer(),
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
                            Expanded(
                              child: LocationSearchWidget(
                                onLocationSelected: _onLocationSelected,
                                currentUserLocation: currentUserPosition,
                                onClear: _clearSearchRoutes,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Test button (remove in production)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 100,
                  left: AppDimensions.pageHorizontalPadding,
                  child: FloatingActionButton(
                    heroTag: "test_ride_request",
                    backgroundColor: AppColors.success,
                    onPressed: _showTestRideRequest,
                    child: const Icon(
                      Icons.notification_add,
                      color: Colors.white,
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

                // "Go Online" button - only shown when offline and not in a ride
                if (!driverProvider.isOnline && !rideProvider.isRideAccepted)
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
                    left: 0,
                    right: 0,
                    child: LocationErrorWidget(
                      errorMessage: locationProvider.locationError,
                      onRetry: () async {
                        await locationProvider.getCurrentLocation();
                      },
                    ),
                  ),

                // Ride action buttons (shown when ride is accepted)
                // Placed here to be on top of the map but below the online sheet
                if (rideProvider.isRideAccepted)
                  RiderDetailsBottomSheet(
                    rideRequest: rideProvider.currentRideRequest!,
                    onNavigate: _navigateToPickup,
                    onArrived: () => rideProvider.arriveAtPickup(),
                    onStartRide: () => rideProvider.startRide(),
                    onCompleteRide: () => rideProvider.completeRide(),
                    isEnRouteToPickup:
                        rideProvider.rideStatus == RideStatus.enRouteToPickup,
                    isAtPickup:
                        rideProvider.rideStatus == RideStatus.arrivedAtPickup,
                    isRideStarted:
                        rideProvider.rideStatus == RideStatus.rideStarted,
                  ),
                if (driverProvider.isOnline && !rideProvider.isRideAccepted)
                  OnlineDriverBottomSheet(
                    controller: _onlineSheetController,
                    onToggleOnlineStatus: _toggleOnlineStatus,
                  ),
              ],
            );
          },
        ),
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
