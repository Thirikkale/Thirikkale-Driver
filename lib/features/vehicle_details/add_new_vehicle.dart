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
import 'package:thirikkale_driver/widgets/common/custom_input_field_lable.dart';

class AddNewVehicle extends StatefulWidget {
  const AddNewVehicle({super.key});

  @override
  State<AddNewVehicle> createState() => _AddNewVehicleState();
}

class _AddNewVehicleState extends State<AddNewVehicle> {
  final _registrationNumberController = TextEditingController();
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
  // bool _isLoadingStatus = false;

  // State to manage the UI flow
  bool _vehicleCreated = false;
  String? _newVehicleId;

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
    ];
    _selectedVehicle = _vehicleTypes.first;
  }

  @override
  void dispose() {
    _registrationNumberController.dispose();
    super.dispose();
  }

  // Future<void> _refreshDocumentStatus() async {
  //   if (_newVehicleId == null)
  //     return; // Can't refresh if we don't have a vehicle ID

  //   setState(() {
  //     _isLoadingStatus = true;
  //   });

  //   try {
  //     final authProvider = Provider.of<AuthProvider>(context, listen: false);
  //     // This gets the status for the entire driver profile
  //     final statusData = await authProvider.getDocumentStatus(
  //       authProvider.userId!,
  //     );

  //     if (mounted) {
  //       _updateVehicleDocumentStatus(statusData);
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       SnackbarHelper.showErrorSnackBar(
  //         context,
  //         'Failed to refresh document status.',
  //       );
  //     }
  //     print('Error refreshing document status: $e');
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isLoadingStatus = false;
  //       });
  //     }
  //   }
  // }

  // // This function parses the full driver status to find this specific vehicle's status
  // void _updateVehicleDocumentStatus(Map<String, dynamic> fullStatus) {
  //   setState(() {
  //     // The backend response might have a top-level 'vehicles' array
  //     final vehiclesList = fullStatus['vehicles'] as List<dynamic>?;
  //     if (vehiclesList == null) {
  //       print('❌ No "vehicles" list found in status response');
  //       return;
  //     }

  //     // Find the specific vehicle in the list by its ID
  //     final vehicleData =
  //         vehiclesList.firstWhere(
  //               (v) =>
  //                   v is Map<String, dynamic> &&
  //                   v['vehicleId'] == _newVehicleId,
  //               orElse: () => null,
  //             )
  //             as Map<String, dynamic>?;

  //     if (vehicleData == null) {
  //       print(
  //         '❌ Could not find vehicle with ID $_newVehicleId in status response',
  //       );
  //       return;
  //     }

  //     final documents = vehicleData['documents'] as Map<String, dynamic>?;
  //     if (documents == null) {
  //       print('❌ No "documents" map found for vehicle ID $_newVehicleId');
  //       return;
  //     }

  //     // Now, update the local _documents list based on this vehicle's status
  //     for (int i = 0; i < _documents.length; i++) {
  //       final document = _documents[i];
  //       bool isCompleted = false;

  //       switch (document.title) {
  //         case 'Revenue License':
  //           final docStatus =
  //               documents['revenueLicense'] as Map<String, dynamic>?;
  //           isCompleted = docStatus?['uploaded'] == true;
  //           break;
  //         case 'Vehicle Registration':
  //           final docStatus =
  //               documents['vehicleRegistration'] as Map<String, dynamic>?;
  //           isCompleted = docStatus?['uploaded'] == true;
  //           break;
  //         case 'Vehicle Insurance':
  //           final docStatus =
  //               documents['vehicleInsurance'] as Map<String, dynamic>?;
  //           isCompleted = docStatus?['uploaded'] == true;
  //           break;
  //       }
  //       _documents[i].isCompleted = isCompleted;
  //     }
  //   });
  // }

  // This is a local helper to update the UI instantly after an upload,
  // before the full refresh from the backend completes.
  void _markDocumentAsCompleted(String documentTitle) {
    setState(() {
      final index = _documents.indexWhere((doc) => doc.title == documentTitle);
      if (index != -1) {
        _documents[index].isCompleted = true;
      }
    });
  }

  Future<void> _createVehicle() async {
    final registrationNumber = _registrationNumberController.text.trim();
    if (registrationNumber.isEmpty) {
      SnackbarHelper.showErrorSnackBar(
        context,
        'Please enter a vehicle registration number.',
      );
      return;
    }

    print('Registration Number: ${registrationNumber}');

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final backendVehicleType = _mapVehicleTypeForBackend(_selectedVehicle.name);

    // Assuming you have a method like this in your AuthProvider
    final newVehicleId = await authProvider.registerNewVehicle(
      backendVehicleType,
      registrationNumber,
    );

    if (mounted) {
      if (newVehicleId != null) {
        setState(() {
          _newVehicleId = newVehicleId;
          _vehicleCreated = true;
        });
        SnackbarHelper.showSuccessSnackBar(
          context,
          'Vehicle created! You can now upload documents.',
        );
      } else {
        SnackbarHelper.showErrorSnackBar(
          context,
          authProvider.errorMessage ?? 'Failed to create vehicle.',
        );
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbarName(
        title: "Add Another Vehicle",
        showBackButton: true,
      ),
      body: Padding(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Vehicle Details', style: AppTextStyles.heading2),
                  const SizedBox(height: 16),
                  VehicleTypeSelector(
                    selectedVehicle: _selectedVehicle,
                    vehicleTypes: _vehicleTypes,
                    onChanged: (newValue) {
                      if (newValue != null && !_vehicleCreated) {
                        setState(() => _selectedVehicle = newValue);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomInputFieldLabel(
                    label: "Vehicle Registration Number",
                    controller: _registrationNumberController,
                    hintText: 'e.g., CBA-1234',
                    borderRadius: BorderRadius.circular(8),
                    enabled: !_vehicleCreated,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // This section is conditional
            if (_vehicleCreated)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.pageHorizontalPadding,
                      ),
                      child: Text(
                        'Upload Documents',
                        style: AppTextStyles.heading2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _documents.length,
                        itemBuilder: (context, index) {
                          return DocumentListItem(
                            document: _documents[index],
                            primaryVehicleId: _newVehicleId,
                            onDocumentCompleted: _markDocumentAsCompleted,
                            onRefreshStatus: () {},
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.pageHorizontalPadding,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: AppButtonStyles.primaryButton,
                          child: const Text("Done"),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pageHorizontalPadding,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _createVehicle,
                    style: AppButtonStyles.primaryButton,
                    child: const Text("Save and Continue"),
                  ),
                ),
              ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
