import 'package:flutter/material.dart';
import 'package:thirikkale_driver/core/utils/app_dimensions.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
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

  @override
  void initState() {
    super.initState();
    _vehicleTypes = [
      VehicleType(name: 'Tuk', imagePath: 'assets/icons/vehicles/tuk.png', minAge: 21, minVehicleYear: 2000),
      VehicleType(name: 'Ride', imagePath: 'assets/icons/vehicles/ride.png', minAge: 18, minVehicleYear: 2000),
      VehicleType(name: 'Rush', imagePath: 'assets/icons/vehicles/rush.png', minAge: 18, minVehicleYear: 2000),
      VehicleType(name: 'Prime Ride', imagePath: 'assets/icons/vehicles/primeRide.png', minAge: 20, minVehicleYear: 2010),
      VehicleType(name: 'Squad', imagePath: 'assets/icons/vehicles/squad.png', minAge: 21, minVehicleYear: 2005),
    ];
    _selectedVehicle = _vehicleTypes.first;
  }

  int get _completedSteps => _documents.where((d) => d.isCompleted).length;
  bool get _allStepsCompleted => _completedSteps == _documents.length;

  void _toggleDocumentStatus(int index) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbarName(title: 'Sigining up for', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.pageVerticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                 padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pageHorizontalPadding),
                child: VehicleTypeSelector(
                  selectedVehicle: _selectedVehicle,
                  vehicleTypes: _vehicleTypes,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedVehicle = newValue;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pageHorizontalPadding),
                child: Text(
                  'Welcome, ${widget.firstName}',
                  style: AppTextStyles.heading1,                
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pageHorizontalPadding),
                child: Text(
                  _allStepsCompleted
                      ? "You're all set and ready to drive!"
                      : 'Complete ${_documents.length - _completedSteps} more steps to start earning.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: _allStepsCompleted ? AppColors.success : AppColors.textSecondary,
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
                      onTap: () => _toggleDocumentStatus(index),
                      onDocumentCompleted: _markDocumentAsCompleted,
                    );
                  },
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pageHorizontalPadding),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppButtonStyles.primaryButton,
                    onPressed:
                        _allStepsCompleted
                            ? () {
                              // Handle continue action
                            }
                            : null,
                    child: const Text('Continue'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
