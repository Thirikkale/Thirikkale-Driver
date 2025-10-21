import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_driver/core/provider/auth_provider.dart';
import 'package:thirikkale_driver/core/provider/location_provider.dart';
import 'package:thirikkale_driver/core/provider/scheduled_rides_provider.dart';
import 'package:thirikkale_driver/core/services/scheduled_rides_service.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/core/utils/snackbar_helper.dart';
import 'package:thirikkale_driver/features/home/widgets/location_search_widget.dart';
import 'package:thirikkale_driver/features/scheduled_rides/models/card_models.dart';
import 'package:thirikkale_driver/features/scheduled_rides/models/scheduled_ride.dart';
import 'package:thirikkale_driver/features/scheduled_rides/widgets/scheduled_ride_card.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduledRidesScreen extends StatelessWidget {
  const ScheduledRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScheduledRidesProvider(),
      child: const _ScheduledRidesView(),
    );
  }
}

class _ScheduledRidesView extends StatefulWidget {
  const _ScheduledRidesView();

  @override
  State<_ScheduledRidesView> createState() => _ScheduledRidesViewState();
}

class _ScheduledRidesViewState extends State<_ScheduledRidesView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      context.read<ScheduledRidesProvider>().setTab(_tabController.index);
      
      print('📑 Tab changed to index: ${_tabController.index}');
      
      if (_tabController.index == 1) {
        // Nearby tab
        final loc = context.read<LocationProvider>();
        context.read<ScheduledRidesProvider>().fetchNearby(loc);
      } else if (_tabController.index == 0) {
        // Accepted tab
        final auth = context.read<AuthProvider>();
        final driverId = auth.driverId;
        print('   Fetching accepted rides for driverId: $driverId');
        if (driverId != null) {
          context.read<ScheduledRidesProvider>().fetchAccepted(driverId);
        } else {
          print('⚠️ Warning: driverId is null on tab 0');
        }
      }
    });
    // prefetch nearby once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = context.read<LocationProvider>();
      final auth = context.read<AuthProvider>();
      final driverId = auth.driverId;
      
      print('🚀 ScheduledRidesScreen initializing...');
      print('   driverId: $driverId');
      print('   location: lat=${loc.currentLatitude}, lng=${loc.currentLongitude}');
      
      context.read<ScheduledRidesProvider>().fetchNearby(loc);
      if (driverId != null) {
        context.read<ScheduledRidesProvider>().fetchAccepted(driverId);
      } else {
        print('⚠️ Warning: driverId is null, cannot fetch accepted rides');
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light gray-blue background
      appBar: AppBar(
        title: const Text('Scheduled Rides'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Accepted'),
            Tab(text: 'Nearby'),
            Tab(text: 'Route Search'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AcceptedTab(),
          _NearbyTab(),
          _RouteSearchTab(),
        ],
      ),
    );
  }
}

class _AcceptedTab extends StatefulWidget {
  const _AcceptedTab();

  @override
  State<_AcceptedTab> createState() => _AcceptedTabState();
}

class _AcceptedTabState extends State<_AcceptedTab> {
  final Map<String, RiderCardModel> _riderDetailsCache = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduledRidesProvider>(
      builder: (_, provider, __) {
        if (provider.loadingAccepted) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.acceptedError != null) {
          return Center(child: Text(provider.acceptedError!));
        }
        final items = provider.accepted;
        if (items.isEmpty) {
          return const Center(child: Text('No accepted scheduled rides yet'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (_, i) => _RideCardWithRiderDetails(
            ride: items[i],
            riderDetailsCache: _riderDetailsCache,
            onStartTrip: () async {
              final ok = await provider.startTrip(rideId: items[i].id);
              if (context.mounted) {
                if (ok) {
                  SnackbarHelper.showSuccessSnackBar(context, 'Trip started! Navigating to destination...');
                  // Navigate to destination using Google Maps
                  _launchGoogleMaps(
                    items[i].dropoffLatitude,
                    items[i].dropoffLongitude,
                    items[i].dropoffAddress,
                  );
                } else {
                  SnackbarHelper.showErrorSnackBar(context, 'Failed to start trip');
                }
              }
            },
            onNavigate: () => _launchGoogleMaps(
              items[i].pickupLatitude,
              items[i].pickupLongitude,
              items[i].pickupAddress,
            ),
            onUnassign: () async {
              final ok = await provider.removeDriver(rideId: items[i].id);
              if (context.mounted) {
                if (ok) {
                  SnackbarHelper.showSuccessSnackBar(context, 'Successfully removed from ride');
                } else {
                  SnackbarHelper.showErrorSnackBar(context, 'Failed to remove from ride');
                }
              }
            },
          ),
        );
      },
    );
  }
}

class _NearbyTab extends StatelessWidget {
  const _NearbyTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<ScheduledRidesProvider, LocationProvider>(
      builder: (_, provider, location, __) {
        if (provider.loadingNearby) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.nearbyError != null) {
          return Center(child: Text(provider.nearbyError!));
        }
        final items = provider.nearby;
        if (items.isEmpty) {
          return const Center(child: Text('No nearby scheduled rides'));
        }
        return RefreshIndicator(
          onRefresh: () => provider.fetchNearby(location),
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              return Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return ScheduledRideCard(
                    ride: items[i],
                    showAssignButton: true,
                    onAssign: () async {
                      final driverId = auth.userId ?? auth.driverId;
                      if (driverId == null) {
                        if (context.mounted) {
                          SnackbarHelper.showErrorSnackBar(context, 'Driver ID not found');
                        }
                        return;
                      }
                      
                      final ok = await provider.assignDriver(
                        ride: items[i],
                        driverId: driverId,
                      );
                      
                      if (context.mounted) {
                        if (ok) {
                          SnackbarHelper.showSuccessSnackBar(context, 'Successfully accepted ride!');
                        } else {
                          SnackbarHelper.showErrorSnackBar(context, 'Failed to accept ride');
                        }
                      }
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _RouteSearchTab extends StatefulWidget {
  const _RouteSearchTab();

  @override
  State<_RouteSearchTab> createState() => _RouteSearchTabState();
}

class _RouteSearchTabState extends State<_RouteSearchTab> {
  String? _pickupLocationName;
  double? _pickupLat;
  double? _pickupLng;
  
  String? _dropoffLocationName;
  double? _dropoffLat;
  double? _dropoffLng;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final currentLocation = locationProvider.currentLatitude != null &&
            locationProvider.currentLongitude != null
        ? LatLng(
            locationProvider.currentLatitude!,
            locationProvider.currentLongitude!,
          )
        : null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pickup location search
                  Row(
                    children: [
                      const Icon(Icons.trip_origin, color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Pickup Location',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LocationSearchWidget(
                    currentUserLocation: currentLocation,
                    onLocationSelected: (name, location) {
                      setState(() {
                        _pickupLocationName = name;
                        _pickupLat = location.latitude;
                        _pickupLng = location.longitude;
                      });
                    },
                    onClear: () {
                      setState(() {
                        _pickupLocationName = null;
                        _pickupLat = null;
                        _pickupLng = null;
                      });
                    },
                  ),
                  if (_pickupLocationName != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _pickupLocationName!,
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  
                  // Dropoff location search
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Dropoff Location',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LocationSearchWidget(
                    currentUserLocation: currentLocation,
                    onLocationSelected: (name, location) {
                      setState(() {
                        _dropoffLocationName = name;
                        _dropoffLat = location.latitude;
                        _dropoffLng = location.longitude;
                      });
                    },
                    onClear: () {
                      setState(() {
                        _dropoffLocationName = null;
                        _dropoffLat = null;
                        _dropoffLng = null;
                      });
                    },
                  ),
                  if (_dropoffLocationName != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.error, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _dropoffLocationName!,
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  
                  // Search button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (_pickupLat != null && _dropoffLat != null)
                          ? () {
                              final p = context.read<ScheduledRidesProvider>();
                              p.searchRoute(
                                pickupLat: _pickupLat!,
                                pickupLng: _pickupLng!,
                                dropLat: _dropoffLat!,
                                dropLng: _dropoffLng!,
                              );
                            }
                          : null,
                      icon: const Icon(Icons.search),
                      label: const Text('Search Routes'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<ScheduledRidesProvider>(
              builder: (_, provider, __) {
                if (provider.loadingRoute) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.routeError != null) {
                  return Center(child: Text(provider.routeError!));
                }
                final items = provider.routeMatches;
                if (items.isEmpty) {
                  return const Center(child: Text('No matches'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, i) {
                    return Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return ScheduledRideCard(
                          ride: items[i],
                          showAssignButton: true,
                          onAssign: () async {
                            final driverId = auth.userId ?? auth.driverId;
                            if (driverId == null) {
                              if (context.mounted) {
                                SnackbarHelper.showErrorSnackBar(context, 'Driver ID not found');
                              }
                              return;
                            }
                            
                            final ok = await provider.assignDriver(
                              ride: items[i],
                              driverId: driverId,
                            );
                            
                            if (context.mounted) {
                              if (ok) {
                                SnackbarHelper.showSuccessSnackBar(context, 'Successfully accepted ride!');
                              } else {
                                SnackbarHelper.showErrorSnackBar(context, 'Failed to accept ride');
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to launch Google Maps navigation
Future<void> _launchGoogleMaps(double lat, double lng, String address) async {
  final googleMapsUrl = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$address',
  );
  
  // Try to open Google Maps app first, fallback to browser
  final googleMapsAppUrl = Uri.parse('comgooglemaps://?daddr=$lat,$lng');
  
  try {
    // Try Google Maps app first
    if (await canLaunchUrl(googleMapsAppUrl)) {
      await launchUrl(googleMapsAppUrl);
    } else {
      // Fallback to browser
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch Google Maps';
      }
    }
  } catch (e) {
    print('❌ Error launching Google Maps: $e');
  }
}

// Widget that fetches and displays rider details for a ride
class _RideCardWithRiderDetails extends StatefulWidget {
  final ScheduledRide ride;
  final Map<String, RiderCardModel> riderDetailsCache;
  final VoidCallback onNavigate;
  final VoidCallback onStartTrip;
  final VoidCallback onUnassign;

  const _RideCardWithRiderDetails({
    required this.ride,
    required this.riderDetailsCache,
    required this.onNavigate,
    required this.onStartTrip,
    required this.onUnassign,
  });

  @override
  State<_RideCardWithRiderDetails> createState() => _RideCardWithRiderDetailsState();
}

class _RideCardWithRiderDetailsState extends State<_RideCardWithRiderDetails> {
  RiderCardModel? _riderDetails;
  bool _loadingRider = false;
  String? _riderError;

  @override
  void initState() {
    super.initState();
    _fetchRiderDetails();
  }

  Future<void> _fetchRiderDetails() async {
    // Check cache first
    if (widget.riderDetailsCache.containsKey(widget.ride.riderId)) {
      setState(() {
        _riderDetails = widget.riderDetailsCache[widget.ride.riderId];
      });
      return;
    }

    setState(() {
      _loadingRider = true;
      _riderError = null;
    });

    try {
      final service = ScheduledRidesService();
      final details = await service.getRiderCard(widget.ride.riderId);
      
      // Cache it
      widget.riderDetailsCache[widget.ride.riderId] = details;
      
      if (mounted) {
        setState(() {
          _riderDetails = details;
          _loadingRider = false;
        });
      }
    } catch (e) {
      print('❌ Error fetching rider details: $e');
      if (mounted) {
        setState(() {
          _riderError = 'Failed to load rider details';
          _loadingRider = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideStatus = widget.ride.status.toUpperCase();
    
    // Show Start Trip button only if ride status is SCHEDULED
    final showStartTrip = rideStatus == 'SCHEDULED';
    
    // Show End Trip button only if ride status is ONGOING
    final showEndTrip = rideStatus == 'ONGOING';
    
    // Show Cancel button only if ride is not ongoing (can cancel before starting)
    final showCancel = rideStatus != 'ONGOING';
    
    return ScheduledRideCard(
      ride: widget.ride,
      showNavigateButton: true,
      showStartTripButton: showStartTrip,
      showEndTripButton: showEndTrip,
      showUnassignButton: showCancel,
      riderDetails: _riderDetails,
      onNavigate: widget.onNavigate,
      onStartTrip: widget.onStartTrip,
      onEndTrip: () async {
        final provider = context.read<ScheduledRidesProvider>();
        final ok = await provider.endTrip(rideId: widget.ride.id);
        if (context.mounted) {
          if (ok) {
            SnackbarHelper.showSuccessSnackBar(context, 'Trip completed successfully!');
          } else {
            SnackbarHelper.showErrorSnackBar(context, 'Failed to end trip');
          }
        }
      },
      onUnassign: widget.onUnassign,
    );
  }
}
