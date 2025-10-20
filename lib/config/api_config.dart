class ApiConfig {
  // Base URLs - Update this IP address to your backend server's IP
  // IMPORTANT: Replace 'YOUR_BACKEND_IP' with the actual IP address of your backend device
  // Example: 'http://192.168.1.100:8081/user-service/api/v1'
  static const String baseIp =
      '192.168.8.111'; // Update this to match your backend IP

  // Use baseIp consistently
  static const String userServiceBaseUrl =
      'http://$baseIp:8081/user-service/api/v1';
  static const String rideServiceBaseUrl =
      'http://$baseIp:8082/ride-service/api/v1';
  // Scheduling service (for scheduled rides)
  static const String schedulingServiceBaseUrl =
      'http://$baseIp:8085/scheduling-service/api';
  static const String webSocketUrl = 'http://$baseIp:8082';

  static const String authBaseUrl = '$userServiceBaseUrl/auth';
  static const String driversBaseUrl = '$userServiceBaseUrl/drivers';
    static const String ridersBaseUrl = '$userServiceBaseUrl/riders';

  // Timeout configurations (increased for network latency and document processing)
  static const Duration connectTimeout = Duration(seconds: 45);
  static const Duration receiveTimeout = Duration(
    seconds: 120,
  ); // Increased for document uploads
  static const Duration sendTimeout = Duration(
    seconds: 90,
  ); // Increased for file uploads

  // Authentication Endpoints
  static const String driverRegister = '$driversBaseUrl/register';
  static const String driverLogin = '$driversBaseUrl/login';
  static const String verifyToken = '$authBaseUrl/verify-token';
  static const String refreshToken = '$authBaseUrl/refresh';
  static const String logout = '$authBaseUrl/logout';
  static const String validateToken = '$authBaseUrl/validate';

  // Driver Profile Completion Endpoint
  static String completeProfile(String driverId) =>
      '$driversBaseUrl/$driverId/complete-profile';

  // Driver Profile Endpoints
  static String getDriverProfile(String driverId) =>
      '$driversBaseUrl/$driverId';
  static String updateDriverProfile(String driverId) =>
      '$driversBaseUrl/$driverId/profile';

  // Vehicle management Endpoints
  static String registerVehicle(String driverId) =>
      '$driversBaseUrl/$driverId/vehicles';
  static String getDriverVehicles(String driverId) =>
      '$driversBaseUrl/$driverId/vehicles';
  static String getVehicleById(String driverId, String vehicleId) =>
      '$driversBaseUrl/$driverId/vehicles/$vehicleId';
  static String setPrimaryVehicle(String driverId, String vehicleId) =>
      '$driversBaseUrl/$driverId/vehicles/$vehicleId/set-primary';

  // Set vehicle types
  static String setPrimaryVehicleType(String driverId) =>
      '$driversBaseUrl/$driverId/primary-vehicle/vehicle-type';

  static String setSecondaryVehicleType(String driverId, String vehicleId) =>
      '$driversBaseUrl/$driverId/vehicles/$vehicleId/vehicle-type';

  // get all the vehicle types in the system
  static const String getVehicleTypes = '$driversBaseUrl/vehicle-types';

  // Personal Document Upload Endpoints (Driver-specific)
  static String uploadSelfie(String driverId) =>
      '$driversBaseUrl/$driverId/documents/selfie';
  static String uploadDrivingLicense(String driverId) =>
      '$driversBaseUrl/$driverId/documents/driving-license';

  // Vehicle Document Upload Endpoints (Vehicle-specific)
  static String uploadRevenueLicense(String driverId, String vehicleId) =>
      '$driversBaseUrl/$driverId/vehicles/$vehicleId/documents/revenue-license';
  static String uploadVehicleRegistration(String driverId, String vehicleId) =>
      '$driversBaseUrl/$driverId/vehicles/$vehicleId/documents/vehicle-registration';
  static String uploadVehicleInsurance(String driverId, String vehicleId) =>
      '$driversBaseUrl/$driverId/vehicles/$vehicleId/documents/vehicle-insurance';

  // Document status endpoints
  static String getDocumentStatus(String driverId) =>
      '$driversBaseUrl/$driverId/documents/status';
  static String getProcessingStatus(String driverId) =>
      '$driversBaseUrl/$driverId/processing-status';

  // Driver Status Endpoints
  static String updateAvailability(String driverId) =>
      '$driversBaseUrl/$driverId/availability';
  static const String pendingDocuments = '$driversBaseUrl/pending-documents';
  static const String pendingVerification =
      '$driversBaseUrl/pending-verification';
  static const String availableDrivers = '$driversBaseUrl/available';

  // Ride Management
  static const String requestRide = '$rideServiceBaseUrl/rides/request';
  static String acceptRide(String rideId) =>
      '$rideServiceBaseUrl/rides/$rideId/accept';
  static String startRide(String rideId) =>
      '$rideServiceBaseUrl/rides/$rideId/start';
  static String completeRide(String rideId) =>
      '$rideServiceBaseUrl/rides/$rideId/complete';
  static String cancelRide(String rideId) =>
      '$rideServiceBaseUrl/rides/$rideId/cancel';
  static String rateRide(String rideId) =>
      '$rideServiceBaseUrl/rides/$rideId/rate';

  // Driver Location & Availability
  static String updateDriverLocation(String driverId) =>
      '$rideServiceBaseUrl/drivers/$driverId/location';
  static String updateDriverAvailability(String driverId) =>
      '$rideServiceBaseUrl/drivers/$driverId/availability';
  static String getDriverLocation(String driverId) =>
      '$rideServiceBaseUrl/drivers/$driverId/location';
  static const String getNearbyDrivers = '$rideServiceBaseUrl/drivers/nearby';
  static String removeDriverLocation(String driverId) =>
      '$rideServiceBaseUrl/drivers/$driverId/location';
  static String driverHeartbeat(String driverId) =>
      '$rideServiceBaseUrl/drivers/$driverId/heartbeat';

  // Ride History & Status
  static String getDriverRides(String driverId) =>
      '$rideServiceBaseUrl/rides/driver/$driverId';
  static String getActiveRides(String userId) =>
      '$rideServiceBaseUrl/rides/active/$userId';

  // Payment management
  static String getDriverPayments(String driverId) =>
      '$rideServiceBaseUrl/payments/driver/$driverId';
  static String getDriverEarnings(String driverId) =>
      '$rideServiceBaseUrl/payments/driver/$driverId/earnings';

  // Scheduled rides (scheduling-service)
  static String getNearbyScheduledRides({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) =>
      '$schedulingServiceBaseUrl/scheduled-rides/nearby?latitude=$latitude&longitude=$longitude&radiusKm=$radiusKm';

  static String getNearbyDropoffRides({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) =>
      '$schedulingServiceBaseUrl/scheduled-rides/nearby-dropoff?latitude=$latitude&longitude=$longitude&radiusKm=$radiusKm';

  static String routeMatch() =>
      '$schedulingServiceBaseUrl/scheduled-rides/route-match';

  static String assignDriverToScheduledRide({
    required String rideId,
    required String driverId,
  }) =>
      '$schedulingServiceBaseUrl/scheduled-rides/$rideId/assign-driver/$driverId';

  static String removeDriverFromScheduledRide(String rideId) =>
      '$schedulingServiceBaseUrl/scheduled-rides/$rideId/remove-driver';

  // Card details (user-service)
  static String getDriverCard(String driverId) =>
      '$driversBaseUrl/$driverId/card';
  static String getRiderCard(String riderId) =>
      '$ridersBaseUrl/$riderId/card';

  // Pub-sub Ride system
  static String subscribeDriver(String driverId) =>
      '$rideServiceBaseUrl/pubsub/drivers/$driverId/subscribe';
  static String unsubscribeDriver(String driverId) =>
      '$rideServiceBaseUrl/pubsub/drivers/$driverId/unsubscribe';
  static String updatePubSubDriverLocation(String driverId) =>
      '$rideServiceBaseUrl/pubsub/drivers/$driverId/location';
  static String acceptRideRequest(String requestId) =>
      '$rideServiceBaseUrl/pubsub/ride-requests/$requestId/accept';
  static String rejectRideRequest(String requestId) =>
      '$rideServiceBaseUrl/pubsub/ride-requests/$requestId/reject';

  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };

  static Map<String, String> get multipartHeaders => {
    'Accept': 'application/json',
  };

  static Map<String, String> getMultipartAuthHeaders(String token) => {
    ...multipartHeaders,
    'Authorization': 'Bearer $token',
  };

  // Get JWT headers for authenticated requests
  static Map<String, String> getJWTHeaders(String accessToken) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  // Get multipart headers with JWT
  static Map<String, String> getJWTMultipartHeaders(String accessToken) {
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }
}

// Driver-specific endpoints class
class DriverEndpoints {
  // Registration & Authentication
  static const String register = ApiConfig.driverRegister;
  static const String login = ApiConfig.driverLogin;

  // Profile Management
  static String profile(String driverId) =>
      ApiConfig.getDriverProfile(driverId);
  static String updateProfile(String driverId) =>
      ApiConfig.updateDriverProfile(driverId);

  // Vehicle Management
  static String registerVehicle(String driverId) =>
      ApiConfig.registerVehicle(driverId);
  static String getVehicles(String driverId) =>
      ApiConfig.getDriverVehicles(driverId);
  static String getVehicle(String driverId, String vehicleId) =>
      ApiConfig.getVehicleById(driverId, vehicleId);
  static String setPrimary(String driverId, String vehicleId) =>
      ApiConfig.setPrimaryVehicle(driverId, vehicleId);
  static const String vehicleTypes = ApiConfig.getVehicleTypes;

  // Personal Document Uploads
  static String selfie(String driverId) => ApiConfig.uploadSelfie(driverId);
  static String drivingLicense(String driverId) =>
      ApiConfig.uploadDrivingLicense(driverId);

  // Vehicle Document Uploads
  static String revenueLicense(String driverId, String vehicleId) =>
      ApiConfig.uploadRevenueLicense(driverId, vehicleId);
  static String vehicleRegistration(String driverId, String vehicleId) =>
      ApiConfig.uploadVehicleRegistration(driverId, vehicleId);
  static String vehicleInsurance(String driverId, String vehicleId) =>
      ApiConfig.uploadVehicleInsurance(driverId, vehicleId);

  // Driver Operations
  static String availability(String driverId) =>
      ApiConfig.updateAvailability(driverId);
  static const String pendingDocs = ApiConfig.pendingDocuments;
  static const String pendingVerification = ApiConfig.pendingVerification;
  static const String available = ApiConfig.availableDrivers;

  // Ride Management
  static String acceptRide(String rideId) => ApiConfig.acceptRide(rideId);
  static String startRide(String rideId) => ApiConfig.startRide(rideId);
  static String completeRide(String rideId) => ApiConfig.completeRide(rideId);
  static String cancelRide(String rideId) => ApiConfig.cancelRide(rideId);
  static String rateRide(String rideId) => ApiConfig.rateRide(rideId);

  // Location & Availability
  static String updateLocation(String driverId) =>
      ApiConfig.updateDriverLocation(driverId);
  static String updateAvailability(String driverId) =>
      ApiConfig.updateDriverAvailability(driverId);
  static String getLocation(String driverId) =>
      ApiConfig.getDriverLocation(driverId);
  static String removeLocation(String driverId) =>
      ApiConfig.removeDriverLocation(driverId);
  static String heartbeat(String driverId) =>
      ApiConfig.driverHeartbeat(driverId);

  // Ride History
  static String rideHistory(String driverId) =>
      ApiConfig.getDriverRides(driverId);
  static String activeRides(String driverId) =>
      ApiConfig.getActiveRides(driverId);

  // Earnings & Payments
  static String payments(String driverId) =>
      ApiConfig.getDriverPayments(driverId);
  static String earnings(String driverId) =>
      ApiConfig.getDriverEarnings(driverId);

  // PubSub System
  static String subscribe(String driverId) =>
      ApiConfig.subscribeDriver(driverId);
  static String unsubscribe(String driverId) =>
      ApiConfig.unsubscribeDriver(driverId);
  static String pubSubLocation(String driverId) =>
      ApiConfig.updatePubSubDriverLocation(driverId);
  static String acceptRideRequest(String requestId) =>
      ApiConfig.acceptRideRequest(requestId);
  static String rejectRideRequest(String requestId) =>
      ApiConfig.rejectRideRequest(requestId);
}

// Driver profile completion steps
class DriverProfileSteps {
  static const List<String> onboardingSteps = [
    'basic_info',
    'selfie_upload',
    'driving_license',
    'revenue_license',
    'vehicle_registration',
    'vehicle_insurance',
    'face_verification',
    'document_verification',
    'profile_extraction',
    'final_approval',
  ];

  static const Map<String, String> stepTitles = {
    'basic_info': 'Complete Your Profile',
    'selfie_upload': 'Upload Selfie',
    'driving_license': 'Driving License',
    'revenue_license': 'Revenue License',
    'vehicle_registration': 'Vehicle Registration',
    'vehicle_insurance': 'Vehicle Insurance',
    'face_verification': 'Face Verification',
    'document_verification': 'Document Review',
    'profile_extraction': 'Profile Processing',
    'final_approval': 'Final Approval',
  };

  static const Map<String, String> stepDescriptions = {
    'basic_info': 'Add your personal and contact details',
    'selfie_upload': 'Upload a clear selfie for verification',
    'driving_license': 'Upload your valid driving license',
    'revenue_license': 'Upload your revenue license document',
    'vehicle_registration': 'Upload vehicle registration certificate',
    'vehicle_insurance': 'Upload vehicle insurance document',
    'face_verification': 'AI verification in progress',
    'document_verification': 'Documents under review by our team',
    'profile_extraction': 'Extracting information from documents',
    'final_approval': 'Waiting for final approval',
  };

  static const Map<String, int> stepProgress = {
    'basic_info': 10,
    'selfie_upload': 20,
    'driving_license': 35,
    'revenue_license': 50,
    'vehicle_registration': 65,
    'vehicle_insurance': 80,
    'face_verification': 85,
    'document_verification': 90,
    'profile_extraction': 95,
    'final_approval': 100,
  };
}

// Document types for validation
class DocumentTypes {
  // Personal Documents
  static const String selfie = 'SELFIE';
  static const String drivingLicense = 'DRIVING_LICENSE';

  // Vehicle Documents (per vehicle)
  static const String revenueLicense = 'REVENUE_LICENSE';
  static const String vehicleRegistration = 'VEHICLE_REGISTRATION';
  static const String vehicleInsurance = 'VEHICLE_INSURANCE';

  static const List<String> personalDocuments = [selfie, drivingLicense];

  static const List<String> vehicleDocuments = [
    revenueLicense,
    vehicleRegistration,
    vehicleInsurance,
  ];

  static const List<String> allRequiredDocuments = [
    ...personalDocuments,
    ...vehicleDocuments,
  ];

  static const Map<String, String> documentNames = {
    selfie: 'Selfie Photo',
    drivingLicense: 'Driving License',
    revenueLicense: 'Revenue License',
    vehicleRegistration: 'Vehicle Registration',
    vehicleInsurance: 'Vehicle Insurance',
  };

  static const Map<String, String> documentInstructions = {
    selfie: 'Take a clear selfie in good lighting',
    drivingLicense: 'Upload both front and back of your driving license',
    revenueLicense:
        'Upload your valid revenue license document for this vehicle',
    vehicleRegistration:
        'Upload vehicle registration certificate for this vehicle',
    vehicleInsurance:
        'Upload current vehicle insurance document for this vehicle',
  };

  static bool isPersonalDocument(String documentType) {
    return personalDocuments.contains(documentType);
  }

  static bool isVehicleDocument(String documentType) {
    return vehicleDocuments.contains(documentType);
  }
}

// Verification status constants
class VerificationStatus {
  // Face verification statuses
  static const String faceVerificationPending = 'FACE_PENDING';
  static const String faceVerificationInProgress = 'FACE_IN_PROGRESS';
  static const String faceVerificationVerified = 'FACE_VERIFIED';
  static const String faceVerificationFailed = 'FACE_FAILED';
  static const String faceVerificationManualReview = 'FACE_MANUAL_REVIEW';

  // Document verification statuses
  static const String documentVerificationPending = 'DOC_PENDING';
  static const String documentVerificationInProgress = 'DOC_IN_PROGRESS';
  static const String documentVerificationVerified = 'DOC_VERIFIED';
  static const String documentVerificationRejected = 'DOC_REJECTED';

  // Profile extraction statuses
  static const String profileExtractionPending = 'PROFILE_PENDING';
  static const String profileExtractionInProgress = 'PROFILE_IN_PROGRESS';
  static const String profileExtractionCompleted = 'PROFILE_COMPLETED';
  static const String profileExtractionFailed = 'PROFILE_FAILED';

  static const Map<String, String> statusMessages = {
    faceVerificationPending: 'Face verification pending',
    faceVerificationInProgress: 'Face verification in progress',
    faceVerificationVerified: 'Face verification completed',
    faceVerificationFailed: 'Face verification failed - please re-upload',
    faceVerificationManualReview: 'Under manual review by support team',

    documentVerificationPending: 'Documents pending review',
    documentVerificationInProgress: 'Documents under review',
    documentVerificationVerified: 'Documents verified',
    documentVerificationRejected: 'Documents rejected - please re-upload',

    profileExtractionPending: 'Profile extraction pending',
    profileExtractionInProgress: 'Processing your documents',
    profileExtractionCompleted: 'Profile information extracted',
    profileExtractionFailed: 'Profile extraction failed',
  };
}

// Driver availability status
class DriverAvailabilityStatus {
  static const String online = 'ONLINE';
  static const String offline = 'OFFLINE';
  static const String busy = 'BUSY';
  static const String break_ = 'BREAK';

  static const Map<String, String> statusNames = {
    online: 'Online',
    offline: 'Offline',
    busy: 'Busy',
    break_: 'On Break',
  };

  static const Map<String, String> statusDescriptions = {
    online: 'Available to accept rides',
    offline: 'Not accepting rides',
    busy: 'Currently on a ride',
    break_: 'Taking a break',
  };
}
