import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_driver/core/provider/auth_provider.dart';
import 'package:thirikkale_driver/core/provider/location_provider.dart';
import 'package:thirikkale_driver/core/provider/scheduled_rides_provider.dart';
import 'package:thirikkale_driver/core/utils/snackbar_helper.dart';
import 'package:thirikkale_driver/features/scheduled_rides/widgets/scheduled_ride_card.dart';

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
      if (_tabController.index == 1) {
        final loc = context.read<LocationProvider>();
        context.read<ScheduledRidesProvider>().fetchNearby(loc);
      } else if (_tabController.index == 0) {
        final loc = context.read<LocationProvider>();
        final auth = context.read<AuthProvider>();
        final driverId = auth.driverId;
        if (driverId != null) {
          context.read<ScheduledRidesProvider>().fetchAccepted(loc, driverId);
        }
      }
    });
    // prefetch nearby once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = context.read<LocationProvider>();
      final auth = context.read<AuthProvider>();
      final driverId = auth.driverId;
      context.read<ScheduledRidesProvider>().fetchNearby(loc);
      if (driverId != null) {
        context.read<ScheduledRidesProvider>().fetchAccepted(loc, driverId);
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

class _AcceptedTab extends StatelessWidget {
  const _AcceptedTab();

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
          itemBuilder: (_, i) => ScheduledRideCard(
            ride: items[i],
            showUnassignButton: true,
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
  final _formKey = GlobalKey<FormState>();
  final _pickupLatCtrl = TextEditingController(text: '7.0419627');
  final _pickupLngCtrl = TextEditingController(text: '79.8893706');
  final _dropLatCtrl = TextEditingController(text: '6.936070099999999');
  final _dropLngCtrl = TextEditingController(text: '79.84504969999999');

  @override
  void dispose() {
    _pickupLatCtrl.dispose();
    _pickupLngCtrl.dispose();
    _dropLatCtrl.dispose();
    _dropLngCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                Row(children: [
                  Expanded(child: _numField(_pickupLatCtrl, label: 'Pickup lat')),
                  const SizedBox(width: 12),
                  Expanded(child: _numField(_pickupLngCtrl, label: 'Pickup lng')),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _numField(_dropLatCtrl, label: 'Drop lat')),
                  const SizedBox(width: 12),
                  Expanded(child: _numField(_dropLngCtrl, label: 'Drop lng')),
                ]),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      final p = context.read<ScheduledRidesProvider>();
                      p.searchRoute(
                        pickupLat: double.parse(_pickupLatCtrl.text),
                        pickupLng: double.parse(_pickupLngCtrl.text),
                        dropLat: double.parse(_dropLatCtrl.text),
                        dropLng: double.parse(_dropLngCtrl.text),
                      );
                    },
                    child: const Text('Search path'),
                  ),
                ),
              ],
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

  Widget _numField(TextEditingController c, {required String label}) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter number' : null,
    );
  }
}


