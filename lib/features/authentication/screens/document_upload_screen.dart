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
        // User is already logged in (auto-login scenario)
        print('✅ User already logged in, loading document status');
        setState(() {
          _isDriverRegistered = true;
        });

        // Load existing document status from backend
        _loadDocumentStatus();
      } else {
        // New user, complete registration
        print('🆕 New user, completing registration');
        _registerDriverWithBackend();
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

  Future<void> _registerDriverWithBackend() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Set vehicle type before registration
    authProvider.setVehicleType(_selectedVehicle.name);

    // Check if user is already logged in (auto-login scenario)
    if (authProvider.isLoggedIn && authProvider.userId != null) {
      print('✅ User already logged in, skipping registration');
      if (mounted) {
        setState(() {
          _isDriverRegistered = true;
        });
      }
      return;
    }

    // Complete registration for new users
    final success = await authProvider.completeDriverRegistration();

    // Check if widget is still mounted before using context
    if (!mounted) return;

    if (success) {
      setState(() {
        _isDriverRegistered = true;
      });
      SnackbarHelper.showSuccessSnackBar(
        context,
        'Registration completed! Please upload your documents.',
      );
    } else {
      SnackbarHelper.showErrorSnackBar(
        context,
        authProvider.errorMessage ?? 'Registration failed',
      );
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

  void _handleContinue() {
    if (!_allStepsCompleted) return;

    if (!mounted) return;

    // Navigate to driver home screen
    // Replace this with your actual driver home screen navigation
    SnackbarHelper.showSuccessSnackBar(
      context,
      'All documents uploaded! Welcome to Thirikkale Driver!',
    );

    // Example navigation (replace with your actual home screen):
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
    //   (route) => false,
    // );
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
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedVehicle = newValue;
                      });
                      // Update vehicle type in provider
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      authProvider.setVehicleType(newValue.name);
                    }
                  },
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
                      onTap: () {},
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
