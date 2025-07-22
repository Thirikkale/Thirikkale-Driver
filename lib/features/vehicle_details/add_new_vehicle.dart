import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:thirikkale_driver/core/provider/auth_provider.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/core/utils/snackbar_helper.dart';
import 'package:thirikkale_driver/features/authentication/models/document_item_model.dart';
import 'package:thirikkale_driver/features/authentication/models/vehicle_type_model.dart';
import 'package:thirikkale_driver/features/authentication/widgets/document_list_item.dart';
import 'package:thirikkale_driver/features/authentication/widgets/vehicle_type_selector.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar_name.dart';

class AddNewVehicle extends StatefulWidget {
  @override
  State<AddNewVehicle> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<AddNewVehicle> {
  final List<DocumentItem> _documents = [
    DocumentItem(
      title: 'Revenue License',
      subtitle: 'Prove your vehicle is authorized for service.',
    ),
    DocumentItem(
      title: 'Vehicle Registration',
      subtitle: 'Confirm ownership and vehicle details.',
    ),
    DocumentItem(
      title: 'Vehicle Insurance',
      subtitle: 'For the safety of you and your riders.',
    ),
  ];

  late final List<VehicleType> _vehicleTypes;
  late VehicleType _selectedVehicle;
  bool _isDriverRegistered = false;

  @override
  void initState() {
    super.initState();
    _vehicleTypes = [
      VehicleType(
        name: 'Tuk',
        imagePath: 'assets/vehicle/tuktuk_photo.jpg',
        minAge: 21,
        minVehicleYear: 2000,
      ),
      VehicleType(
        name: 'Ride',
        imagePath: 'assets/vehicle/bike_photo.jpg',
        minAge: 18,
        minVehicleYear: 2000,
      ),
      VehicleType(
        name: 'Rush',
        imagePath: 'assets/vehicle/car_photo.jpg',
        minAge: 18,
        minVehicleYear: 2000,
      ),
      VehicleType(
        name: 'Prime Ride',
        imagePath: 'assets/vehicle/car_photo.jpg',
        minAge: 20,
        minVehicleYear: 2010,
      ),
      VehicleType(
        name: 'Squad',
        imagePath: 'assets/vehicle/car_photo.jpg',
        minAge: 21,
        minVehicleYear: 2005,
      ),
    ];
    _selectedVehicle = _vehicleTypes.first;

    // Register driver when screen loads
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final authProvider = Provider.of<AuthProvider>(context, listen: false);

    //   if (authProvider.isLoggedIn && authProvider.userId != null) {
    //     // User is already logged in (auto-login scenario)
    //     setState(() {
    //       _isDriverRegistered = true;
    //     });
    //     print('✅ User already logged in, ready for document upload');
    //   } else {
    //     // New user, complete registration
    //     _registerDriverWithBackend();
    //   }
    // });
  }

  // Future<void> _registerDriverWithBackend() async {
  //   final authProvider = Provider.of<AuthProvider>(context, listen: false);

  //   // Set vehicle type before registration
  //   authProvider.setVehicleType(_selectedVehicle.name);

  //   // Check if user is already logged in (auto-login scenario)
  //   if (authProvider.isLoggedIn && authProvider.userId != null) {
  //     print('✅ User already logged in, skipping registration');
  //     if (mounted) {
  //       setState(() {
  //         _isDriverRegistered = true;
  //       });
  //     }
  //     return;
  //   }

  //   // Complete registration for new users
  //   final success = await authProvider.completeDriverRegistration();

  //   // Check if widget is still mounted before using context
  //   if (!mounted) return;

  //   if (success) {
  //     setState(() {
  //       _isDriverRegistered = true;
  //     });
  //     SnackbarHelper.showSuccessSnackBar(
  //       context,
  //       'Registration completed! Please upload your documents.',
  //     );
  //   } else {
  //     SnackbarHelper.showErrorSnackBar(
  //       context,
  //       authProvider.errorMessage ?? 'Registration failed',
  //     );
  //   }
  // }

  int get _completedSteps => _documents.where((d) => d.isCompleted).length;
  bool get _allStepsCompleted => _completedSteps == _documents.length;

  void _toggleDocumentStatus(int index) {
    if (!mounted) return;
    setState(() {
      _documents[index].isCompleted = !_documents[index].isCompleted;
    });
  }

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
      appBar: CustomAppBar(
        centerWidget: Image.asset(
          'assets/icons/thirikkale_driver_appbar_logo.png',
          height: 50.0,
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.only(bottom:24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pageHorizontalPadding,
              ),
              child: Text('Select vehicle type', style: AppTextStyles.heading2),
            ),
            const SizedBox(height: 8),

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
                    // final authProvider = Provider.of<AuthProvider>(
                    //   context,
                    //   listen: false,
                    // );
                    // authProvider.setVehicleType(newValue.name);
                  }
                },
              ),
            ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pageHorizontalPadding,
              ),
              child: Text('Upload documents', style: AppTextStyles.heading2),
            ),
            // const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _documents.length,
                itemBuilder: (context, index) {
                  return DocumentListItem(
                    document: _documents[index],
                    onTap: () => _toggleDocumentStatus(index),
                    onDocumentCompleted: _markDocumentAsCompleted,
                  );
                },
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddNewVehicle()),
                      ),
                  style: AppButtonStyles.primaryButton,
                  child: Text("Add vehicle"),
                ),
              ),
            ),

            // Padding(
            //   padding: const EdgeInsets.symmetric(
            //     horizontal: AppDimensions.pageHorizontalPadding,
            //   ),
            //   child: Consumer<AuthProvider>(
            //     builder: (context, authProvider, child) {
            //       if (authProvider.isLoading) {
            //         return const Center(child: CircularProgressIndicator());
            //       }

            //       return SizedBox(
            //         width: double.infinity,
            //         child: ElevatedButton(
            //           style: AppButtonStyles.primaryButton,
            //           onPressed:
            //               _allStepsCompleted && _isDriverRegistered
            //                   ? _handleContinue
            //                   : null,
            //           child: const Text('Continue'),
            //         ),
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
