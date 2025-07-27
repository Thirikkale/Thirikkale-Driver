import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_driver/core/provider/auth_provider.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/core/utils/snackbar_helper.dart';
import 'package:thirikkale_driver/features/authentication/models/document_item_model.dart';
import 'package:thirikkale_driver/features/authentication/models/vehicle_type_model.dart';
import 'package:thirikkale_driver/features/authentication/widgets/document_list_item.dart';
import 'package:thirikkale_driver/features/authentication/widgets/vehicle_type_selector.dart';
import 'package:thirikkale_driver/features/home/screens/driver_home_screen.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar_name.dart';

class DocumentUploadScreen extends StatefulWidget {
  final String firstName;
  const DocumentUploadScreen({super.key, required this.firstName});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final List<DocumentItem> _documents = [
    DocumentItem(
      title: 'Profile Picture',
      subtitle: 'Your photo helps riders recognize you.',
    ),
    DocumentItem(
      title: 'Driving License',
      subtitle: 'Verify your eligibility to drive.',
    ),
    DocumentItem(
      title: 'Revenue License',
      subtitle: 'Ensure your vehicle is authorized for service.',
    ),
    DocumentItem(
      title: 'Vehicle Registration',
      subtitle: 'Confirm ownership and vehicle details.',
    ),
    DocumentItem(
      title: 'Vehicle Insurance',
      subtitle: 'Required for the safety of you and your riders.',
    ),
  ];

  late final List<VehicleType> _vehicleTypes;
  late VehicleType _selectedVehicle;
  String? _primaryVehicleId;
  bool _isDriverRegistered = false;
  // ignore: unused_field
  bool _isLoadingDocumentStatus = false;

  @override
  void initState() {
    super.initState();
    _vehicleTypes = [
      VehicleType(
        name: 'Tuk',
        imagePath: 'assets/icons/vehicles/tuk.png',
        minAge: 21,
        minVehicleYear: 2000,
      ),
      VehicleType(
        name: 'Ride',
        imagePath: 'assets/icons/vehicles/ride.png',
        minAge: 18,
        minVehicleYear: 2000,
      ),
      VehicleType(
        name: 'Rush',
        imagePath: 'assets/icons/vehicles/rush.png',
        minAge: 18,
        minVehicleYear: 2000,
      ),
      VehicleType(
        name: 'Prime Ride',
        imagePath: 'assets/icons/vehicles/primeRide.png',
        minAge: 20,
        minVehicleYear: 2010,
      ),
      VehicleType(
        name: 'Squad',
        imagePath: 'assets/icons/vehicles/squad.png',
        minAge: 21,
        minVehicleYear: 2005,
      ),
    ];
    _selectedVehicle = _vehicleTypes.first;

    // Register driver when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.isLoggedIn && authProvider.userId != null) {
        // The user is logged in. Now, check if they have a vehicle.
        if (authProvider.primaryVehicleId == null) {
          // This is a new user who just set their name. Create their vehicle.
          print('🆕 New user detected. Creating primary vehicle...');
          _createPrimaryVehicle();
        } else {
          // This is a returning user who already has a vehicle.
          print('✅ Returning user. Loading document status...');
          setState(() {
            _isDriverRegistered = true;
            _primaryVehicleId = authProvider.primaryVehicleId;
          });
          _loadDocumentStatus();
        }
      } else {
        // This case should ideally not be hit if your flow is correct
        print('Auth state is not ready. Waiting...');
      }
    });
  }

  Future<void> _loadDocumentStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.userId == null) {
      print('❌ No user ID available for document status check');
      return;
    }

    setState(() {
      _isLoadingDocumentStatus = true;
    });

    try {
      final documentStatus = await authProvider.getDocumentStatus(
        authProvider.userId!,
      );

      if (!mounted) return;

      // Update document completion status based on backend response
      _updateDocumentCompletionStatus(documentStatus);
    } catch (e) {
      print('❌ Error loading document status: $e');
      // Don't show error to user as this is background loading
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDocumentStatus = false;
        });
      }
    }
  }

  void _updateDocumentCompletionStatus(Map<String, dynamic> documentStatus) {
    setState(() {
      // Check if documents field exists and extract it
      final documents = documentStatus['documents'] as Map<String, dynamic>?;

      if (documents == null) {
        print('❌ No documents field found in response');
        return;
      }

      for (int i = 0; i < _documents.length; i++) {
        final document = _documents[i];
        bool isCompleted = false;

        // Map document titles to backend field names
        switch (document.title) {
          case 'Profile Picture':
            // Check for both 'selfie' and 'profilePicture' as possible field names
            final selfieDoc = documents['selfie'] as Map<String, dynamic>?;
            final profileDoc =
                documents['profilePicture'] as Map<String, dynamic>?;
            isCompleted =
                (selfieDoc?['uploaded'] == true) ||
                (profileDoc?['uploaded'] == true);
            break;
          case 'Driving License':
            final drivingLicenseDoc =
                documents['drivingLicense'] as Map<String, dynamic>?;
            isCompleted = drivingLicenseDoc?['uploaded'] == true;
            break;
          case 'Revenue License':
            final revenueLicenseDoc =
                documents['revenueLicense'] as Map<String, dynamic>?;
            isCompleted = revenueLicenseDoc?['uploaded'] == true;
            break;
          case 'Vehicle Registration':
            final vehicleRegDoc =
                documents['vehicleRegistration'] as Map<String, dynamic>?;
            isCompleted = vehicleRegDoc?['uploaded'] == true;
            break;
          case 'Vehicle Insurance':
            final vehicleInsDoc =
                documents['vehicleInsurance'] as Map<String, dynamic>?;
            isCompleted = vehicleInsDoc?['uploaded'] == true;
            break;
        }

        _documents[i].isCompleted = isCompleted;
      }
    });

    // Log completion status for debugging
    final completedCount = _documents.where((d) => d.isCompleted).length;
    print(
      '📄 Documents loaded: $completedCount/${_documents.length} completed',
    );

    // Log individual document status for debugging
    for (final doc in _documents) {
      print('📄 ${doc.title}: ${doc.isCompleted ? "✅" : "❌"}');
    }
  }

  Future<void> _createPrimaryVehicle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final backendVehicleType = _mapVehicleTypeForBackend(_selectedVehicle.name);

    // This function now ONLY creates the vehicle.
    final newVehicleId = await authProvider.registerAndSetPrimaryVehicle(
      backendVehicleType,
    );

    if (!mounted) return;

    if (newVehicleId != null) {
      setState(() {
        _isDriverRegistered = true;
        _primaryVehicleId = newVehicleId;
      });
      SnackbarHelper.showSuccessSnackBar(
        context,
        'Vehicle registered! Please upload your documents.',
      );
    } else {
      SnackbarHelper.showErrorSnackBar(
        context,
        authProvider.errorMessage ?? 'Could not set up your vehicle.',
      );
    }
  }

  // Maps vehicle types to backend
  String _mapVehicleTypeForBackend(String displayName) {
    switch (displayName) {
      case 'Tuk':
        return 'TUK';
      case 'Ride':
        return 'RIDE';
      case 'Rush':
        return 'RUSH';
      case 'Prime Ride':
        return 'PRIME_RIDE';
      case 'Squad':
        return 'SQUAD';
      default:
        return 'OTHER';
    }
  }

  // Handle vehicle type update in dropdown (set Vehicle type for primary vehicle)
  Future<void> _handleVehicleTypeChange(VehicleType? newVehicle) async {
    if (newVehicle == null || newVehicle == _selectedVehicle) return;

    // Always update the local state for a responsive UI
    setState(() {
      _selectedVehicle = newVehicle;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final backendVehicleType = _mapVehicleTypeForBackend(newVehicle.name);

    // IMPORTANT: Only call the backend if a primary vehicle has been created.
    if (_primaryVehicleId != null) {
      print('🚗 Primary vehicle exists. Updating type on backend...');
      final success = await authProvider.updatePrimaryVehicleType(
        backendVehicleType,
      );

      if (!mounted) return;

      if (success) {
        SnackbarHelper.showSuccessSnackBar(context, 'Vehicle type updated.');
      } else {
        SnackbarHelper.showErrorSnackBar(
          context,
          authProvider.errorMessage ?? 'Update failed.',
        );
        // NOTE: You might want to revert the UI change here if the backend call fails.
      }
    } else {
      // If no primary vehicle exists yet, just update the type in the provider's local state.
      // The _registerDriverAndVehicle function will use this value when it runs.
      print('🚗 No primary vehicle yet. Setting type locally.');
      authProvider.setVehicleType(backendVehicleType);
    }
  }

  int get _completedSteps => _documents.where((d) => d.isCompleted).length;
  bool get _allStepsCompleted => _completedSteps == _documents.length;

  void _markDocumentAsCompleted(String documentTitle) {
    setState(() {
      final index = _documents.indexWhere((doc) => doc.title == documentTitle);
      if (index != -1) {
        _documents[index].isCompleted = true;
      }
    });
  }

  void _handleContinue() async {
    if (!_allStepsCompleted) return;

    if (!mounted) return;

    // Navigate to driver home screen
    try {
      // Get auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Fetch latest driver profile data from backend
      await authProvider.fetchDriverProfile();

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        SnackbarHelper.showSuccessSnackBar(
          context,
          'All documents uploaded! Welcome to Thirikkale Driver!',
        );

        // Navigate to driver home screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        SnackbarHelper.showErrorSnackBar(
          context,
          'Profile setup completed, but some data might not be synced.',
        );

        // Still navigate to home screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbarName(title: 'Sigining up for', showBackButton: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.pageVerticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pageHorizontalPadding,
                ),
                child: VehicleTypeSelector(
                  selectedVehicle: _selectedVehicle,
                  vehicleTypes: _vehicleTypes,
                  onChanged:
                      (VehicleType? newVehicle) =>
                          _handleVehicleTypeChange(newVehicle),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pageHorizontalPadding,
                ),
                child: Text(
                  'Welcome, ${widget.firstName}',
                  style: AppTextStyles.heading1,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pageHorizontalPadding,
                ),
                child: Text(
                  _allStepsCompleted
                      ? "You're all set and ready to drive!"
                      : _isDriverRegistered
                      ? 'Complete ${_documents.length - _completedSteps} more steps to start earning.'
                      : 'Setting up your account...',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color:
                        _allStepsCompleted
                            ? AppColors.success
                            : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: _documents.length,
                  itemBuilder: (context, index) {
                    return DocumentListItem(
                      document: _documents[index],
                      primaryVehicleId: _primaryVehicleId,
                      onDocumentCompleted: _markDocumentAsCompleted,
                      onRefreshStatus: _loadDocumentStatus,
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pageHorizontalPadding,
                ),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: AppButtonStyles.primaryButton,
                        onPressed:
                            _allStepsCompleted && _isDriverRegistered
                                ? _handleContinue
                                : null,
                        child: const Text('Continue'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
