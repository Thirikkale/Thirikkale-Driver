import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirikkale_driver/core/services/auth_service.dart';
import 'package:thirikkale_driver/core/services/driver_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DriverService _driverService = DriverService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isPhoneVerified = false;
  String? _verifiedPhoneNumber;
  String? _idToken;
  String? _firebaseUid;
  String? _driverId;
  String? _accessToken;
  String? _refreshToken;
  String? _userId;
  String? _tokenType;
  DateTime? _tokenExpiresAt;
  String? _firstName;
  String? _lastName;
  String? _selectedVehicleType;
  bool _isLoggedIn = false;
  String? _userType;
  String? _profilePictureUrl;
  double? _rating;
  String? _primaryVehicleId;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPhoneVerified => _isPhoneVerified;
  String? get verifiedPhoneNumber => _verifiedPhoneNumber;
  String? get idToken => _idToken;
  String? get firebaseUid => _firebaseUid;
  String? get driverId => _driverId;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get userId => _userId;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get selectedVehicleType => _selectedVehicleType;
  String? get userType => _userType;
  String? get profilePictureUrl => _profilePictureUrl;
  double? get rating => _rating;
  String? get primaryVehicleId => _primaryVehicleId;

  bool get hasValidJWTToken {
    if (_accessToken == null || _tokenExpiresAt == null) return false;
    return _tokenExpiresAt!.isAfter(
      DateTime.now().add(const Duration(minutes: 1)),
    );
  }

  // Add getter for login status
  bool get isLoggedIn => _isLoggedIn && hasValidJWTToken;

  // Get full name helper
  String get fullName {
    if (_firstName != null && _lastName != null) {
      return '$_firstName $_lastName';
    } else if (_firstName != null) {
      return _firstName!;
    }
    return 'Driver';
  }

  // Get display phone number
  String get displayPhoneNumber {
    if (_verifiedPhoneNumber != null) {
      return _verifiedPhoneNumber!;
    }
    return 'Not provided';
  }

  // Initialize AuthProvider - call this in main.dart
  Future<void> initialize() async {
    await _loadStoredTokens();

    // If we have valid tokens, try to refresh them
    if (_refreshToken != null && !hasValidJWTToken) {
      print('🔄 Attempting to refresh stored tokens...');
      await _refreshAccessToken();
    }

    notifyListeners();
  }

  // Check whether user has already loggedIn
  Future<bool> tryAutoLogin() async {
    print('Attempting auto-login');
    await _loadStoredTokens();

    // Check if a token was successfully loaded and is not expired/invalid
    final validToken = await getCurrentToken();

    if (validToken != null) {
      print('✅ Auto-login successful. Valid token found.');
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } else {
      print('❌ Auto-login failed. Token is invalid or missing.');
      // Ensure we clean up any partial/invalid data
      await _clearJWTTokens();
      return false;
    }
  }

  // Send OTP for phone verification
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException error) onVerificationFailed,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendOTP(
        phoneNumber: phoneNumber,
        codeSent: (verificationId, resendToken) {
          onCodeSent(verificationId, resendToken);
        },
        verificationFailed: (error) {
          _setError(error.message ?? 'Phone verification failed');
          onVerificationFailed(error);
        },
        verificationCompleted: (credential) {
          // Auto-verification completed
          _isPhoneVerified = true;
          _verifiedPhoneNumber = phoneNumber;
          notifyListeners();
        },
      );
    } catch (e) {
      _setError(e.toString());
      onVerificationFailed(
        FirebaseAuthException(code: 'unknown', message: e.toString()),
      );
    } finally {
      _setLoading(false);
    }
  }

  // Verify OTP code and get token
  Future<bool> verifyOTP(String verificationId, String code) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.verifyOTPAndGetToken(
        verificationId,
        code,
      );

      if (result['success'] == true) {
        // Store token information
        _idToken = result['idToken'];
        _firebaseUid = result['uid'];
        _isPhoneVerified = true;

        // If the phone number wasn't set earlier, set it now
        if (_verifiedPhoneNumber == null && result['phoneNumber'] != null) {
          _verifiedPhoneNumber = result['phoneNumber'];
        }

        // Print token for development purposes only (remove in production)
        print('Firebase ID Token: $_idToken');

        return true;
      } else {
        _setError(result['error'] ?? 'Verification failed');
        return false;
      }
    } catch (e) {
      _setError('Invalid verification code. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Set user name
  void setUserName(String firstName, String lastName) {
    _firstName = firstName;
    _lastName = lastName;
    notifyListeners();
  }

  // Set vehicle type
  void setVehicleType(String vehicleType) {
    _selectedVehicleType = vehicleType;
    notifyListeners();
  }

  // Enhanced registration method
  Future<bool> registerDriverWithBackend() async {
    // This now just calls the complete registration
    return await completeDriverRegistration();
  }

  // Check user after phone number verification
  Future<Map<String, dynamic>> checkUserRegistrationStatus() async {
    if (_idToken == null) {
      return {'success': false, 'error': 'No authentication token available'};
    }

    _setLoading(true);
    _clearError();

    try {
      print('🔍 Checking user registration status...');

      final result = await _driverService.registerDriver(
        firebaseToken: _idToken!,
        // Don't send name/vehicle for status check
      );

      if (result['success'] == true) {
        final responseData = result['data'];
        print('Response Data: $responseData');
        await _storeJWTTokens(responseData);

        _driverId = responseData['userId'];
        _isLoggedIn = true;

        // Store user info if available
        if (responseData['firstName'] != null) {
          _firstName = responseData['firstName'];
        }
        if (responseData['lastName'] != null) {
          _lastName = responseData['lastName'];
        }
        if (responseData['phoneNumber'] != null) {
          _verifiedPhoneNumber = responseData['phoneNumber'];
        }

        print('✅ User status checked successfully');
        print('🆔 User ID: $_userId');
        print('👤 Name: $_firstName $_lastName');
        print('🔄 Is New Registration: ${result['isNewRegistration']}');
        print('🔄 Is Auto Login: ${result['isAutoLogin']}');

        return {
          'success': true,
          'isNewRegistration': result['isNewRegistration'],
          'isAutoLogin': result['isAutoLogin'],
          'hasCompleteProfile': _firstName == 'Driver' && _lastName != 'User',
          'data': responseData,
        };
      } else {
        _setError(result['error'] ?? 'Failed to check registration status');
        return result;
      }
    } catch (e) {
      _setError('Status check error: $e');
      return {'success': false, 'error': 'Status check failed: $e'};
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> completeDriverProfile({
    required String firstName,
    required String lastName,
  }) async {
    // Check if user is logged in with JWT tokens
    if (_userId == null) {
      _setError('User not logged in');
      return false;
    }

    // Get current valid JWT token
    final jwtToken = await getCurrentToken();
    if (jwtToken == null) {
      _setError('Session expired. Please login again.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      print('🚀 Starting profile completion...');
      print('🆔 User ID: $_userId');
      print('👤 Name: $firstName $lastName');
      print('🎫 Using JWT Token: ${jwtToken.substring(0, 20)}...');

      final result = await _driverService.completeDriverProfile(
        driverId: _userId!,
        firstName: firstName,
        lastName: lastName,
        jwtToken: jwtToken,
      );

      if (result['success'] == true) {
        // Update local state with the new names
        _firstName = firstName;
        _lastName = lastName;

        // Save updated information to local storage
        await _saveTokensToStorage();

        print('✅ Driver profile completed successfully');
        print('👤 Updated Name: $_firstName $_lastName');

        notifyListeners();
        return true;
      } else {
        final errorMessage = result['error'] ?? 'Profile completion failed';

        // Handle token expiry or authentication errors
        if (result['statusCode'] == 401 || result['statusCode'] == 403) {
          _setError('Session expired. Please login again.');
          // Clear JWT tokens and logout
          await logout();
        } else {
          _setError(errorMessage);
        }
        return false;
      }
    } catch (e) {
      _setError('Profile completion error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> completeDriverRegistrationWithNames({
    required String firstName,
    required String lastName,
    String? vehicleType,
  }) async {
    if (_idToken == null) {
      _setError('No authentication token available');
      return false;
    }

    // Store the names in the provider
    _firstName = firstName;
    _lastName = lastName;

    // Use default vehicle type if not provided (will be set later in document upload)
    if (vehicleType != null) {
      _selectedVehicleType = vehicleType;
    }

    _setLoading(true);
    _clearError();

    try {
      print('🚀 Completing driver registration with names...');
      print('👤 Name: $firstName $lastName');
      print('🎫 Firebase Token: ${_idToken?.substring(0, 20)}...');

      final result = await _driverService.registerDriver(
        firebaseToken: _idToken!,
        firstName: firstName,
        lastName: lastName,
        vehicleType:
            _selectedVehicleType, // This can be null, will be set later
      );

      if (result['success'] == true) {
        final responseData = result['data'];
        await _storeJWTTokens(responseData);

        _driverId = responseData['userId'];
        _isLoggedIn = true;

        print('✅ Driver registration with names completed successfully');
        print('🆔 User ID: $_userId');
        print('👤 Registered Name: $_firstName $_lastName');

        return true;
      } else {
        _setError(result['error'] ?? 'Registration with names failed');
        return false;
      }
    } catch (e) {
      _setError('Registration error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getDocumentStatus(String driverId) async {
    try {
      // Make sure we have an access token
      if (_accessToken == null || _accessToken!.isEmpty) {
        throw Exception('No access token available');
      }

      // Call the AuthService method
      final result = await _driverService.getDocumentStatus(
        driverId,
        _accessToken!,
      );

      if (result['success'] == true) {
        print('✅ Document status fetched successfully');
        return result['data'] ?? {};
      } else {
        print('❌ Failed to fetch document status: ${result['error']}');
        throw Exception(result['error'] ?? 'Failed to fetch document status');
      }
    } catch (e) {
      print('❌ Error in AuthProvider.getDocumentStatus: $e');
      // Set error message for UI
      _setError('Failed to load document status');
      rethrow;
    }
  }

  // Update existing registration method for completing new user registration
  Future<bool> completeDriverRegistration() async {
    if (_idToken == null ||
        _firstName == null ||
        _lastName == null ||
        _selectedVehicleType == null) {
      _setError('Missing required information for registration completion');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      print('🚀 Completing driver registration...');

      final result = await _driverService.registerDriver(
        firebaseToken: _idToken!,
        firstName: _firstName!,
        lastName: _lastName!,
        vehicleType: _selectedVehicleType!,
      );

      if (result['success'] == true) {
        final responseData = result['data'];
        await _storeJWTTokens(responseData);

        _driverId = responseData['userId'];
        _isLoggedIn = true;

        print('✅ Driver registration completed successfully');
        return true;
      } else {
        _setError(result['error'] ?? 'Registration completion failed');
        return false;
      }
    } catch (e) {
      _setError('Registration completion error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register a vehicle and set as a primary vehicle
  Future<String?> registerAndSetPrimaryVehicle(String vehicleType) async {
    final token = await getCurrentToken();
    if (token == null || _userId == null) {
      _setError('Session expired. Please login again.');
      return null;
    }

    _setLoading(true);
    try {
      // Step 1: Register the vehicle
      final regResult = await _driverService.registerVehicle(
        driverId: _userId!,
        vehicleType: vehicleType,
        jwtToken: token,
      );

      if (regResult['success'] != true) {
        _setError(regResult['error'] ?? 'Failed to register vehicle.');
        return null;
      }

      final newVehicleId = regResult['data']['vehicleId'];
      if (newVehicleId == null) {
        _setError('Could not get vehicle ID from server.');
        return null;
      }

      // Step 2: Set the new vehicle as primary
      final setResult = await _driverService.setPrimaryVehicle(
        driverId: _userId!,
        vehicleId: newVehicleId,
        jwtToken: token,
      );

      if (setResult['success'] != true) {
        _setError(setResult['error'] ?? 'Failed to set primary vehicle.');
        // Even if this fails, we still have the vehicle ID
        return newVehicleId;
      }

      // Store the primary vehicle ID and save it
      _primaryVehicleId = newVehicleId;
      await _saveTokensToStorage(); // Your existing method to save state

      print('✅ Primary vehicle setup complete. Vehicle ID: $_primaryVehicleId');
      return _primaryVehicleId;
    } catch (e) {
      _setError('An error occurred during vehicle setup: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Upload document
  Future<bool> uploadDocument({
    required String documentType,
    required String imagePath,
    String? vehicleId,
  }) async {
    // Check if user is logged in with JWT tokens
    if (_userId == null) {
      _setError('User not logged in');
      return false;
    }

    // Get current valid JWT token
    final jwtToken = await getCurrentToken();
    if (jwtToken == null) {
      _setError('Session expired. Please login again.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      print('📤 Starting document upload...');
      print('🆔 User ID: $_userId');
      print('📄 Document Type: $documentType');
      print('🎫 Using JWT Token: ${jwtToken.substring(0, 20)}...');

      final result = await _driverService.uploadDocument(
        driverId: _userId!, // Use userId from JWT response
        documentType: documentType,
        imageFile: File(imagePath),
        jwtToken: jwtToken, // Use JWT token
        vehicleId: vehicleId,
      );

      if (result['success'] == true) {
        print('✅ Document uploaded successfully: $documentType');
        return true;
      } else {
        final errorMessage = result['error'] ?? 'Upload failed';

        // Handle token expiry or authentication errors
        if (result['statusCode'] == 401 || result['statusCode'] == 403) {
          _setError('Session expired. Please login again.');
          // Clear JWT tokens and logout
          await logout();
        } else {
          _setError(errorMessage);
        }
        return false;
      }
    } catch (e) {
      _setError('Upload error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update vehicle type for the current driver
  Future<bool> updatePrimaryVehicleType(String vehicleType) async {
    final token = await getCurrentToken();
    if (token == null || _userId == null) {
      _setError('Session expired');
      return false;
    }

    _setLoading(true);
    try {
      final result = await _driverService.updatePrimaryVehicleType(
        driverId: _userId!,
        vehicleType: vehicleType,
        jwtToken: token,
      );

      if (result['success'] == true) {
        // Also update the local state
        _selectedVehicleType = vehicleType;
        await _saveTokensToStorage();
        notifyListeners();
        return true;
      } else {
        _setError(result['error'] ?? 'Failed to update vehicle type');
        return false;
      }
    } catch (e) {
      _setError('An error occurred: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchDriverProfile() async {
    if (_userId == null) return;

    final token = await getCurrentToken();
    if (token == null) return;

    try {
      // Call your backend API to get full driver profile
      final result = await _driverService.getDriverProfile(
        driverId: _userId!,
        jwtToken: token,
      );

      if (result['success'] == true) {
        final profile = result['data'];

        // Update profile data
        _profilePictureUrl = profile['profilePictureUrl'];
        _rating = profile['rating']?.toDouble();

        // Save updated data
        await _saveTokensToStorage();
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error fetching driver profile: $e');
    }
  }

  // Helper method to update vehicle type and sync with backend
  Future<void> setAndUpdateVehicleType(String vehicleType) async {
    // First set it locally (for immediate UI update)
    setVehicleType(vehicleType);

    // Then sync with backend
    final success = await updatePrimaryVehicleType(vehicleType);

    if (!success) {
      // If backend update failed, you might want to revert or show error
      print('⚠️ Vehicle type set locally but failed to sync with backend');
    }
  }

  // Store JWT tokens with persistence
  Future<void> _storeJWTTokens(Map<String, dynamic> data) async {
    try {
      _accessToken = data['accessToken'];
      _refreshToken = data['refreshToken'];
      _userId = data['userId'];
      _tokenType = data['tokenType'] ?? 'Bearer';
      _userType = data['userType'];

      // Calculate expiry time
      final expiresIn = data['expiresIn'] ?? 3600;
      _tokenExpiresAt = DateTime.now().add(Duration(seconds: expiresIn));

      // Update user info
      _firstName = data['firstName'] ?? _firstName;
      _lastName = data['lastName'] ?? _lastName;
      _verifiedPhoneNumber = data['phoneNumber'] ?? _verifiedPhoneNumber;

      // Persist to local storage
      await _saveTokensToStorage();

      print('✅ JWT tokens stored and persisted');
      notifyListeners();
    } catch (e) {
      print('❌ Error storing JWT tokens: $e');
    }
  }

  // Save tokens to SharedPreferences
  Future<void> _saveTokensToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final tokenData = {
        'accessToken': _accessToken,
        'refreshToken': _refreshToken,
        'userId': _userId,
        'tokenType': _tokenType,
        'userType': _userType,
        'tokenExpiresAt': _tokenExpiresAt?.millisecondsSinceEpoch,
        'firstName': _firstName,
        'lastName': _lastName,
        'phoneNumber': _verifiedPhoneNumber,
        'driverId': _driverId,
        'selectedVehicleType': _selectedVehicleType,
        'profilePictureUrl': _profilePictureUrl,
        'rating': _rating,
        'primaryVehicleId': _primaryVehicleId,
      };

      await prefs.setString('jwt_tokens', jsonEncode(tokenData));
      print('💾 Tokens saved to local storage');
    } catch (e) {
      print('❌ Error saving tokens to storage: $e');
    }
  }

  // Load tokens from SharedPreferences
  Future<void> _loadStoredTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenString = prefs.getString('jwt_tokens');

      if (tokenString != null) {
        final tokenData = jsonDecode(tokenString);

        _accessToken = tokenData['accessToken'];
        _refreshToken = tokenData['refreshToken'];
        _userId = tokenData['userId'];
        _tokenType = tokenData['tokenType'];
        _userType = tokenData['userType'];
        _firstName = tokenData['firstName'];
        _lastName = tokenData['lastName'];
        _verifiedPhoneNumber = tokenData['phoneNumber'];
        _driverId = tokenData['driverId'];
        _selectedVehicleType = tokenData['selectedVehicleType'];
        _profilePictureUrl = tokenData['profilePictureUrl'];
        _rating = tokenData['rating']?.toDouble();
        _primaryVehicleId = tokenData['primaryVehicleId'];

        if (tokenData['tokenExpiresAt'] != null) {
          _tokenExpiresAt = DateTime.fromMillisecondsSinceEpoch(
            tokenData['tokenExpiresAt'],
          );
        }

        _isLoggedIn = _accessToken != null;

        print('📱 Loaded stored tokens');
        print('🎫 Access Token: ${_accessToken?.substring(0, 20)}...');
        print('⏰ Expires at: $_tokenExpiresAt');
        print('✅ Valid: $hasValidJWTToken');
      }
    } catch (e) {
      print('❌ Error loading stored tokens: $e');
    }
  }

  // Get current valid token (with auto-refresh)
  Future<String?> getCurrentToken() async {
    if (_accessToken == null) {
      print('❌ No access token available');
      return null;
    }

    // Check if token needs refresh (5 minutes before expiry)
    if (_tokenExpiresAt != null &&
        _tokenExpiresAt!.isBefore(
          DateTime.now().add(const Duration(minutes: 5)),
        )) {
      print('🔄 Token expiring soon, refreshing...');

      final refreshed = await _refreshAccessToken();
      if (!refreshed) {
        print('❌ Token refresh failed, user needs to login again');
        await logout();
        return null;
      }
    }

    return _accessToken;
  }

  // Refresh access token
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) {
      print('❌ No refresh token available');
      return false;
    }

    try {
      print('🔄 Refreshing access token...');

      final result = await _authService.refreshToken(_refreshToken!);

      if (result['success'] == true) {
        await _storeJWTTokens(result['data']);
        print('✅ Token refreshed successfully');
        return true;
      } else {
        print('❌ Token refresh failed: ${result['error']}');
        await _clearJWTTokens();
        return false;
      }
    } catch (e) {
      print('❌ Token refresh error: $e');
      await _clearJWTTokens();
      return false;
    }
  }

  // Clear JWT tokens
  Future<void> _clearJWTTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _tokenType = null;
    _tokenExpiresAt = null;
    _userType = null;
    _isLoggedIn = false;

    // Clear from storage
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_tokens');
    } catch (e) {
      print('❌ Error clearing tokens from storage: $e');
    }

    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    try {
      // Call backend logout if we have a token
      if (_accessToken != null) {
        await _authService.logout(_accessToken!);
      }
    } catch (e) {
      print('❌ Logout API call failed: $e');
    } finally {
      // Always clear local state
      await _clearJWTTokens();
      await _authService.signOut(); // Firebase signout
      resetVerification();
      print('✅ Logged out successfully');
    }
  }

  // Check authentication status
  Future<bool> checkAuthStatus() async {
    if (!_isLoggedIn || !hasValidJWTToken) {
      return false;
    }

    // Validate token with backend
    try {
      final token = await getCurrentToken();
      if (token == null) return false;

      // You can add a token validation API call here if needed
      return true;
    } catch (e) {
      print('❌ Auth status check failed: $e');
      return false;
    }
  }

  // Set verified phone number
  void setVerifiedPhoneNumber(String phoneNumber) {
    _verifiedPhoneNumber = phoneNumber;
    notifyListeners();
  }

  // Reset verification status
  void resetVerification() {
    _isPhoneVerified = false;
    _verifiedPhoneNumber = null;
    _idToken = null;
    _firebaseUid = null;
    _clearError();
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error manually
  void clearError() {
    _clearError();
  }
}
