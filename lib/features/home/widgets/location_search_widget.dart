import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thirikkale_driver/core/services/places_api_service.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:uuid/uuid.dart';

class LocationSearchWidget extends StatefulWidget {
  final Function(String locationName, LatLng location) onLocationSelected;
  final LatLng? currentUserLocation;

  const LocationSearchWidget({
    super.key,
    required this.onLocationSelected,
    this.currentUserLocation,
  });

  @override
  State<LocationSearchWidget> createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends State<LocationSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  Timer? _debounceTimer;
  List<Map<String, dynamic>> _predictions = [];
  bool _isSearching = false;
  String? _sessionToken;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _focusNode.removeListener(_handleFocusChange);
    _searchController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus && _sessionToken == null) {
      _sessionToken = const Uuid().v4();
    }
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_searchController.text.trim().length > 2) {
        _fetchPredictions();
      } else {
        _removeOverlay();
      }
    });
  }

  void _showOverlay() {
    _overlayEntry ??= _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder:
          (context) => Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 5),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _predictions.length,
                  itemBuilder: (context, index) {
                    final prediction = _predictions[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.location_on,
                        color: AppColors.primaryBlue,
                      ),
                      title: Text(
                        prediction['description'] ?? 'No description',
                      ),
                      onTap: () => _onPredictionTapped(prediction),
                    );
                  },
                ),
              ),
            ),
          ),
    );
  }

  Future<void> _fetchPredictions() async {
    setState(() => _isSearching = true);
    try {
      final result = await PlacesApiService.getPlacePredictions(
        _searchController.text,
        sessionToken: _sessionToken,
        latitude: widget.currentUserLocation?.latitude,
        longitude: widget.currentUserLocation?.longitude,
      );
      if (mounted) {
        setState(() => _predictions = result);
        if (_predictions.isNotEmpty) {
          _removeOverlay();
          _showOverlay();
        } else {
          _removeOverlay();
        }
      }
    } catch (e) {
      debugPrint('Prediction fetch error: $e');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _onPredictionTapped(Map<String, dynamic> prediction) async {
    final placeId = prediction['place_id'] as String?;
    if (placeId == null) return;
    _focusNode.unfocus();
    _removeOverlay();

    try {
      final details = await PlacesApiService.getPlaceDetails(
        placeId,
        _sessionToken,
      );
      if (details != null) {
        final lat = details['geometry']?['location']?['lat'];
        final lng = details['geometry']?['location']?['lng'];
        final name =
            details['name'] ?? prediction['description'] ?? 'Unknown Place';
        if (lat != null && lng != null) {
          widget.onLocationSelected(name, LatLng(lat, lng));
          _searchController.text = name;
          _sessionToken = null;
        }
      }
    } catch (e) {
      debugPrint('Place details error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
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
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search for a place...',
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textSecondary,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            suffixIcon:
                _isSearching
                    ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                    : _searchController.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _removeOverlay();
                        _sessionToken = null;
                      },
                    )
                    : null,
          ),
        ),
      ),
    );
  }
}
