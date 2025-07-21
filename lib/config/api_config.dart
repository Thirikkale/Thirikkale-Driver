class ApiConfig {
  // Base URLs - Update this IP address to your backend server's IP
  // IMPORTANT: Replace 'YOUR_BACKEND_IP' with the actual IP address of your backend device
  // Example: 'http://192.168.1.100:8081/user-service/api/v1'
  static const String baseUrl = 'http://10.41.12.69:8081/user-service/api/v1';
  static const String authBaseUrl = '$baseUrl/auth';
  static const String driversBaseUrl = '$baseUrl/drivers';

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

  // Set Vehicle Type
  static String updateVehicleType(String driverId) =>
      '$driversBaseUrl/$driverId/vehicle-type';

  // Document Upload Endpoints
  static String uploadSelfie(String driverId) =>
      '$driversBaseUrl/$driverId/documents/selfie';
  static String uploadDrivingLicense(String driverId) =>
      '$driversBaseUrl/$driverId/documents/driving-license';
  static String uploadRevenueLicense(String driverId) =>
      '$driversBaseUrl/$driverId/documents/revenue-license';
  static String uploadVehicleRegistration(String driverId) =>
      '$driversBaseUrl/$driverId/documents/vehicle-registration';
  static String uploadVehicleInsurance(String driverId) =>
      '$driversBaseUrl/$driverId/documents/vehicle-insurance';

  // Document status endpoints
  static String getDocumentStatus(String driverId) =>
      '$driversBaseUrl/$driverId/documents/status';
  static String getVerificationStatus(String driverId) =>
      '$driversBaseUrl/$driverId/verification/status';

  // Driver Status Endpoints
  static String updateAvailability(String driverId) =>
      '$driversBaseUrl/$driverId/availability';
  static const String pendingDocuments = '$driversBaseUrl/pending-documents';
  static const String pendingVerification =
      '$driversBaseUrl/pending-verification';
  static const String availableDrivers = '$driversBaseUrl/available';

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

  // Document Uploads
  static String selfie(String driverId) => ApiConfig.uploadSelfie(driverId);
  static String drivingLicense(String driverId) =>
      ApiConfig.uploadDrivingLicense(driverId);
  static String revenueLicense(String driverId) =>
      ApiConfig.uploadRevenueLicense(driverId);
  static String vehicleRegistration(String driverId) =>
      ApiConfig.uploadVehicleRegistration(driverId);
  static String vehicleInsurance(String driverId) =>
      ApiConfig.uploadVehicleInsurance(driverId);

  // Driver Operations
  static String availability(String driverId) =>
      ApiConfig.updateAvailability(driverId);
  static const String pendingDocs = ApiConfig.pendingDocuments;
  static const String pendingVerification = ApiConfig.pendingVerification;
  static const String available = ApiConfig.availableDrivers;
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
  static const String selfie = 'SELFIE';
  static const String drivingLicense = 'DRIVING_LICENSE';
  static const String revenueLicense = 'REVENUE_LICENSE';
  static const String vehicleRegistration = 'VEHICLE_REGISTRATION';
  static const String vehicleInsurance = 'VEHICLE_INSURANCE';

  static const List<String> requiredDocuments = [
    selfie,
    drivingLicense,
    revenueLicense,
    vehicleRegistration,
    vehicleInsurance,
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
    revenueLicense: 'Upload your valid revenue license document',
    vehicleRegistration: 'Upload vehicle registration certificate',
    vehicleInsurance: 'Upload current vehicle insurance document',
  };
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
