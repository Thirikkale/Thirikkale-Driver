import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_driver/core/provider/auth_provider.dart';
import 'package:thirikkale_driver/core/utils/navigation_utils.dart';
import 'package:thirikkale_driver/core/utils/snackbar_helper.dart';
import 'package:thirikkale_driver/features/authentication/screens/document_upload_screen.dart';
import 'package:thirikkale_driver/features/authentication/screens/name_registration_screen.dart';
import 'package:thirikkale_driver/features/authentication/widgets/otp_input_row.dart';
import 'package:thirikkale_driver/features/authentication/widgets/sign_navigation_button_row.dart';
import 'package:thirikkale_driver/widgets/common/custom_appbar.dart';
import 'package:thirikkale_driver/widgets/custom_modern_loading_overlay.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  late Timer _timer;
  int _start = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    setState(() {
      _canResend = false;
      _start = 30;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var c in _otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // Resend OTP
  void _resendOtp() {
    if (!_canResend) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.sendOTP(
      phoneNumber: widget.phoneNumber,
      onCodeSent: (newVerificationId, resendToken) {
        // Check if widget is still mounted before using context
        if (!mounted) return;

        SnackbarHelper.showSuccessSnackBar(
          context,
          "New OTP sent successfully!",
        );
        // Update the state with the new verificationId
        setState(() {});
        startTimer(); // Restart the timer
      },
      onVerificationFailed: (error) {
        // Check if widget is still mounted before using context
        if (!mounted) return;

        SnackbarHelper.showErrorSnackBar(
          context,
          error.message ?? "Failed to send OTP",
        );
      },
    );
  }

  // Check if all OTP fields are filled
  bool get _isFormValid {
    return _otpControllers.every((controller) => controller.text.isNotEmpty);
  }

  // Get OTP code from controllers
  String get _otpCode {
    return _otpControllers.map((controller) => controller.text).join();
  }

  // Verify OTP
  void _verifyOTP() async {
    if (!_isFormValid) {
      SnackbarHelper.showErrorSnackBar(
        context,
        "Please enter the complete verification code",
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // First verify the OTP
    final verified = await authProvider.verifyOTP(
      widget.verificationId,
      _otpCode,
    );

    // Check if widget is still mounted before using context
    if (!mounted) return;

    if (verified) {
      // Now check user registration status
      final statusResult = await authProvider.checkUserRegistrationStatus();

      // Check if widget is still mounted before using context
      if (!mounted) return;

      if (statusResult['success'] == true) {
        if (statusResult['isAutoLogin'] == true) {
          // Existing user with complete profile
          final firstName = authProvider.firstName ?? 'Driver';

          SnackbarHelper.showSuccessSnackBar(
            context,
            'Welcome back, $firstName!',
          );

          Navigator.of(context).pushAndRemoveUntil(
            NoAnimationPageRoute(
              builder: (context) => DocumentUploadScreen(firstName: firstName),
            ),
            (route) => false,
          );
        } else {
          // New user OR existing user without complete profile
          final hasCompleteProfile = statusResult['hasCompleteProfile'] == true;

          if (hasCompleteProfile) {
            // User has names but might need to complete other steps
            print("\n\n\n6Inside of the Has Complete Profile\n");
            final firstName = authProvider.firstName ?? 'Driver';

            SnackbarHelper.showSuccessSnackBar(
              context,
              'Welcome back, $firstName!',
            );

            Navigator.of(context).push(
              NoAnimationPageRoute(
                builder:
                    (context) => DocumentUploadScreen(firstName: firstName),
              ),
            );
          } else {
            // User needs to complete profile (set names)
            SnackbarHelper.showSuccessSnackBar(
              context,
              'Phone verified successfully!',
            );

            Navigator.of(context).push(
              NoAnimationPageRoute(
                builder: (context) => const NameRegistrationScreen(),
              ),
            );
          }
        }
      } else {
        SnackbarHelper.showErrorSnackBar(
          context,
          statusResult['error'] ?? 'Failed to check registration status',
        );
      }
    } else {
      SnackbarHelper.showErrorSnackBar(
        context,
        authProvider.errorMessage ?? 'Invalid verification code',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return ModernLoadingOverlay(
          isLoading: authProvider.isLoading,
          message: "Verifying OTP...",
          style: LoadingStyle.dots,

          child: Scaffold(
            appBar: CustomAppBar(
              centerWidget: Image.asset(
                'assets/icons/thirikkale_driver_appbar_logo.png',
                height: 50.0,
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Enter the 6-digit code sent via\nSMS to ${widget.phoneNumber}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),

                  const SizedBox(height: 32),

                  // OTP fields
                  OtpInputRow(
                    controllers: _otpControllers,
                    onChanged: (value, index) {
                      setState(() {}); // Update UI when text changes
                    },
                  ),
                  const SizedBox(height: 24),

                  // Resend OTP Timer and Button
                  Center(
                    child:
                        _canResend
                            ? TextButton(
                              onPressed: _resendOtp,
                              child: const Text('Resend Code'),
                            )
                            : Text(
                              'Resend code in 00:${_start.toString().padLeft(2, '0')}',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                  ),

                  const Spacer(),

                  // Navigation buttons
                  SignNavigationButtonRow(
                    onBack: () => Navigator.pop(context),
                    onNext: _isFormValid ? _verifyOTP : null,
                    nextEnabled: _isFormValid && !authProvider.isLoading,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
