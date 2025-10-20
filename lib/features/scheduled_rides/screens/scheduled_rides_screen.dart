import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_driver/core/provider/auth_provider.dart';
import 'package:thirikkale_driver/core/provider/location_provider.dart';
import 'package:thirikkale_driver/core/provider/scheduled_rides_provider.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/features/scheduled_rides/models/scheduled_ride.dart';

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
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) => _RideTile(ride: items[i], showUnassign: true),
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
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => _RideTile(ride: items[i], showAssign: true),
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
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => _RideTile(ride: items[i], showAssign: true),
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

class _RideTile extends StatelessWidget {
  final ScheduledRide ride;
  final bool showAssign;
  final bool showUnassign;
  const _RideTile({required this.ride, this.showAssign = false, this.showUnassign = false});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return ListTile(
      title: Text('${ride.pickupAddress} → ${ride.dropoffAddress}', maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text('Time: ${ride.scheduledTime} • ${ride.rideType ?? ''} ${ride.vehicleType ?? ''}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showAssign)
            IconButton(
              icon: const Icon(Icons.add_task, color: AppColors.success),
              onPressed: () async {
                final driverId = auth.userId ?? auth.driverId; // stored user id
                if (driverId == null) return;
                final ok = await context.read<ScheduledRidesProvider>().assignDriver(
                  ride: ride,
                  driverId: driverId,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Assigned to ride' : 'Failed to assign')),
                );
              },
            ),
          if (showUnassign)
            IconButton(
              icon: const Icon(Icons.remove_circle, color: AppColors.error),
              onPressed: () async {
                final ok = await context.read<ScheduledRidesProvider>()
                    .removeDriver(rideId: ride.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Removed from ride' : 'Failed to remove')),
                );
              },
            ),
        ],
      ),
    );
  }
}
