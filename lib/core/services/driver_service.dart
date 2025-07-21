import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:thirikkale_driver/config/api_config.dart';

class DriverService {
  // Register driver with Firebase token
  Future<Map<String, dynamic>> registerDriver({
    required String firebaseToken,
    String? firstName,
    String? lastName,
    String? vehicleType,
  }) async {
    try {
      print('🚀 Starting driver registration/login...');
      print('📍 Endpoint: ${ApiConfig.driverRegister}');
      print('🎫 Token length: ${firebaseToken.length}');

      final requestBody = {
        'firebaseIdToken': firebaseToken,
        'platform': 'MOBILE_APP',
      };

      // Only add these fields if provided (for new registrations)
      if (firstName != null) requestBody['firstName'] = firstName;
      if (lastName != null) requestBody['lastName'] = lastName;
      if (vehicleType != null) requestBody['vehicleType'] = vehicleType;

      print('📤 Request body: $requestBody');

      final response = await http
          .post(
            Uri.parse(ApiConfig.driverRegister),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode(requestBody),
          )
          .timeout(ApiConfig.connectTimeout);

      print('📨 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      print('\n\n⭐⭐Response Data: $responseData⭐⭐\n');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Detect if this is a new registration or auto-login
        bool isNewRegistration = _isNewRegistration(responseData);

        return {
          'success': true,
          'data': responseData,
          'isNewRegistration': isNewRegistration,
          'isAutoLogin': !isNewRegistration,
          'driverId': responseData['userId'], // Use userId as driverId
          'message':
              responseData['message'] ??
              (isNewRegistration ? 'Registration successful' : 'Welcome back!'),
        };
      } else {
        // Handle error cases
        String errorMessage = _getErrorMessage(
          response.statusCode,
          responseData,
        );

        return {
          'success': false,
          'error': errorMessage,
          'statusCode': response.statusCode,
          'details': responseData,
        };
      }
    } catch (e) {
      print('❌ Registration/Login error: $e');
      return {
        'success': false,
        'error': 'Registration failed: $e',
        'type': 'unknown_error',
      };
    }
  }

  bool _isNewRegistration(Map<String, dynamic> responseData) {
    // Check for indicators of new registration
    if (responseData.containsKey('isNewRegistration')) {
      return responseData['isNewRegistration'] == true;
    }

    // Check if user has incomplete profile (no firstName/lastName for auto-login)
    final hasCompleteProfile =
        responseData['firstName'] != null && responseData['lastName'] != null;

    // If user has complete profile, it's likely auto-login
    // If not, it's new registration
    return !hasCompleteProfile;
  }

  // Helper method for error messages
  String _getErrorMessage(int statusCode, Map<String, dynamic> responseData) {
    switch (statusCode) {
      case 400:
        if (responseData['validationErrors'] != null) {
          final validationErrors = responseData['validationErrors'];
          final errorMessages = <String>[];
          validationErrors.forEach((field, message) {
            errorMessages.add('$field: $message');
          });
          return 'Validation failed: ${errorMessages.join(', ')}';
        }
        return responseData['message'] ?? 'Invalid request data';
      case 401:
        return 'Authentication failed. Please verify your phone number again.';
      case 403:
        return 'Access denied. Please check your permissions.';
      case 409:
        return 'Phone number already registered with different account.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return responseData['message'] ??
            responseData['error'] ??
            'Registration failed';
    }
  }

  Future<Map<String, dynamic>> completeDriverProfile({
    required String driverId,
    required String firstName,
    required String lastName,
    required String jwtToken,
  }) async {
    try {
      print('🚀 Starting driver profile completion...');
      print('🆔 Driver ID: $driverId');
      print('👤 Name: $firstName $lastName');

      final url = ApiConfig.completeProfile(driverId);

      final headers = {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final body = jsonEncode({'firstName': firstName, 'lastName': lastName});

      print('🌐 Request URL: $url');
      print('📤 Request Body: $body');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        return {
          'success': true,
          'data': responseData,
          'message': 'Profile completed successfully',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Session expired. Please login again.',
          'statusCode': response.statusCode,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Driver not found',
          'statusCode': response.statusCode,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Profile completion failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Driver profile completion error: $e');
      return {
        'success': false,
        'error': 'Network error: Failed to complete profile',
      };
    }
  }

  Future<Map<String, dynamic>> uploadDocument({
    required String driverId,
    required String documentType,
    required File imageFile,
    required String jwtToken,
  }) async {
    try {
      print('📤 Uploading document: $documentType for driver: $driverId');

      String endpoint = _getDocumentEndpoint(driverId, documentType);
      print('📍 Upload endpoint: $endpoint');

      // Validate file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file not found');
      }

      // Check file size
      final fileSize = await imageFile.length();
      print('📏 File size: ${fileSize} bytes');

      if (fileSize == 0) {
        throw Exception('Image file is empty');
      }

      var request = http.MultipartRequest('POST', Uri.parse(endpoint));

      // Set proper headers for multipart upload with JWT
      request.headers.addAll({
        'Authorization': 'Bearer $jwtToken',
        'Accept': 'application/json',
        // Don't set Content-Type for multipart requests - let http package handle it
      });

      print('📤 Upload headers: ${request.headers}');

      // Determine MIME type based on file extension
      String fileName = path.basename(imageFile.path);
      String mimeType = 'image/jpeg'; // Default

      if (fileName.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      } else if (fileName.toLowerCase().endsWith('.jpg') ||
          fileName.toLowerCase().endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      }

      print('📁 File name: $fileName');
      print('🎭 MIME type: $mimeType');

      // Add file with proper MIME type
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // This should match your backend's expected field name
          imageFile.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      );

      // Add form fields that your backend might expect
      request.fields['documentType'] = _mapDocumentType(documentType);
      request.fields['driverId'] = driverId;

      print('📄 Form fields: ${request.fields}');

      // Send request with timeout
      var streamedResponse = await request.send().timeout(
        ApiConfig.sendTimeout,
      );
      var response = await http.Response.fromStream(streamedResponse);

      print('📨 Upload response status: ${response.statusCode}');
      print('📄 Upload response body: ${response.body}');

      // Handle response
      if (response.body.isEmpty) {
        // Some APIs return empty body on success
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return {'success': true, 'message': 'Document uploaded successfully'};
        } else {
          return {
            'success': false,
            'error': 'Upload failed with status ${response.statusCode}',
            'statusCode': response.statusCode,
          };
        }
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': responseData,
          'message':
              responseData['message'] ?? 'Document uploaded successfully',
        };
      } else {
        String errorMessage = 'Upload failed';

        if (response.statusCode == 400) {
          if (responseData['validationErrors'] != null) {
            final validationErrors = responseData['validationErrors'];
            final errorMessages = <String>[];

            validationErrors.forEach((field, message) {
              errorMessages.add('$field: $message');
            });

            errorMessage =
                'Upload validation failed: ${errorMessages.join(', ')}';
          } else if (responseData['message'] != null) {
            errorMessage = responseData['message'];
          } else {
            errorMessage = 'Invalid file format. Only image files are allowed.';
          }
        } else if (response.statusCode == 401) {
          errorMessage = 'Authentication failed. Session expired.';
        } else if (response.statusCode == 403) {
          errorMessage = 'Access denied. Driver not found or invalid token.';
        } else if (response.statusCode == 413) {
          errorMessage = 'File too large. Please choose a smaller image.';
        } else if (response.statusCode == 415) {
          errorMessage =
              'Unsupported file type. Please upload a valid image file.';
        } else if (response.statusCode >= 500) {
          errorMessage = 'Server error during upload. Please try again.';
        } else {
          errorMessage =
              responseData['message'] ??
              responseData['error'] ??
              'Upload failed';
        }

        return {
          'success': false,
          'error': errorMessage,
          'statusCode': response.statusCode,
          'details': responseData,
        };
      }
    } on TimeoutException catch (e) {
      print('❌ Upload timeout: $e');
      return {
        'success': false,
        'error': 'Upload timed out. Please try again with a smaller image.',
        'type': 'timeout_error',
      };
    } on SocketException catch (e) {
      print('❌ Upload network error: $e');
      return {
        'success': false,
        'error': 'Network connection failed during upload.',
        'type': 'network_error',
      };
    } on FormatException catch (e) {
      print('❌ Upload JSON parsing error: $e');
      return {
        'success': false,
        'error': 'Invalid response from server during upload.',
        'type': 'parse_error',
      };
    } catch (e) {
      print('❌ Upload error: $e');
      return {
        'success': false,
        'error': 'Upload failed: $e',
        'type': 'unknown_error',
      };
    }
  }

  // Helper method to get document endpoint
  String _getDocumentEndpoint(String driverId, String documentType) {
    switch (documentType) {
      case 'profile_picture':
        return ApiConfig.uploadSelfie(driverId);
      case 'driving_license':
        return ApiConfig.uploadDrivingLicense(driverId);
      case 'revenue_license':
        return ApiConfig.uploadRevenueLicense(driverId);
      case 'vehicle_registration':
        return ApiConfig.uploadVehicleRegistration(driverId);
      case 'vehicle_insurance':
        return ApiConfig.uploadVehicleInsurance(driverId);
      default:
        throw Exception('Unknown document type: $documentType');
    }
  }

  // Helper method to map document types to backend expected values
  String _mapDocumentType(String documentType) {
    switch (documentType) {
      case 'profile_picture':
        return 'SELFIE';
      case 'driving_license':
        return 'DRIVING_LICENSE';
      case 'revenue_license':
        return 'REVENUE_LICENSE';
      case 'vehicle_registration':
        return 'VEHICLE_REGISTRATION';
      case 'vehicle_insurance':
        return 'VEHICLE_INSURANCE';
      default:
        return documentType.toUpperCase();
    }
  }

  // Also update other methods that use tokens
  Future<Map<String, dynamic>> getDriverProfile({
    required String driverId,
    required String jwtToken, // Changed from firebaseToken
  }) async {
    try {
      print('📱 Getting driver profile for: $driverId');

      final response = await http
          .get(
            Uri.parse(ApiConfig.getDriverProfile(driverId)),
            headers: {
              ...ApiConfig.defaultHeaders,
              'Authorization': 'Bearer $jwtToken',
            },
          )
          .timeout(ApiConfig.receiveTimeout);

      print('📨 Profile response status: ${response.statusCode}');
      print('📄 Profile response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'error': responseData['message'] ?? 'Failed to get profile',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Profile error: $e');
      return {'success': false, 'error': 'Failed to get profile: $e'};
    }
  }

  // Get driver verification status
  Future<Map<String, dynamic>> getVerificationStatus({
    required String driverId,
    required String jwtToken, // Changed from firebaseToken
  }) async {
    try {
      print('🔍 Getting verification status for: $driverId');

      final response = await http
          .get(
            Uri.parse(ApiConfig.getVerificationStatus(driverId)),
            headers: {
              ...ApiConfig.defaultHeaders,
              'Authorization': 'Bearer $jwtToken',
            },
          )
          .timeout(ApiConfig.receiveTimeout);

      print('📨 Verification status response: ${response.statusCode}');
      print('📄 Verification response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'error':
              responseData['message'] ?? 'Failed to get verification status',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Verification error: $e');
      return {
        'success': false,
        'error': 'Failed to get verification status: $e',
      };
    }
  }

  // Get document status for a driver
  Future<Map<String, dynamic>> getDocumentStatus(
    String driverId,
    String accessToken,
  ) async {
    try {
      print('📄 Fetching document status for driver: $driverId');

      final response = await http
          .get(
            Uri.parse(ApiConfig.getDocumentStatus(driverId)),
            headers: {
              ...ApiConfig.defaultHeaders,
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 30));

      print('📨 Document status response status: ${response.statusCode}');
      print('📄 Document status response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Return the document status data
        return {
          'success': true,
          'data':
              responseData['data'] ??
              responseData, // Handle different response structures
        };
      } else {
        return {
          'success': false,
          'error': responseData['message'] ?? 'Failed to fetch document status',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Document status fetch error: $e');
      return {'success': false, 'error': 'Failed to fetch document status: $e'};
    }
  }
}
