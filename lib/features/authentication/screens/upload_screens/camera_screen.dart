import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/core/utils/snackbar_helper.dart';

class CameraScreen extends StatefulWidget {
  final String documentType;

  const CameraScreen({super.key, required this.documentType});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  String _getScreenTitle() {
    switch (widget.documentType) {
      case 'profile_picture':
        return 'Take Profile Photo';
      case 'driving_license':
        return 'Take License Photo';
      case 'revenue_license':
        return 'Take Revenue License Photo';
      default:
        return 'Take Photo';
    }
  }

  String _getInstructionText() {
    switch (widget.documentType) {
      case 'profile_picture':
        return 'Position your face in the center circle\nLook directly at the camera';
      case 'driving_license':
        return 'Place your license within the rectangle\nEnsure all text is clearly visible';
      case 'revenue_license':
        return 'Place your revenue license within the rectangle\nEnsure the document fits completely in the frame';
      default:
        return 'Position the document within the frame';
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        CameraDescription? selectedCamera;

        if (widget.documentType == 'profile_picture') {
          // Use front camera for profile pictures
          for (final camera in _cameras!) {
            if (camera.lensDirection == CameraLensDirection.front) {
              selectedCamera = camera;
              break;
            }
          }
        } else {
          // Use back camera for documents
          for (final camera in _cameras!) {
            if (camera.lensDirection == CameraLensDirection.back) {
              selectedCamera = camera;
              break;
            }
          }
        }

        // Fallback to first available camera if preferred camera not found
        selectedCamera ??= _cameras!.first;

        _controller = CameraController(selectedCamera, ResolutionPreset.high);
        await _controller!.initialize();
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');

      if (mounted) {
        SnackbarHelper.showErrorSnackBar(
          context,
          'Unable to access front camera',
        );
      }
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final XFile photo = await _controller!.takePicture();

      // Show preview and upload
      await _showPhotoPreview(photo);
    } catch (e) {
      print('Error taking picture: $e');
      if (mounted) {
        SnackbarHelper.showErrorSnackBar(
          context,
          "Failed to take picture. Please try again.",
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showPhotoPreview(XFile photo) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => PhotoPreviewDialog(photo: photo),
    );

    if (result == true) {
      await _uploadPhoto(photo);
    }
  }

  Future<void> _uploadPhoto(XFile photo) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('YOUR_BACKEND_URL/upload/${widget.documentType}'),
      );

      // Add the file
      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));

      // Add additional fields if needed
      request.fields['document_type'] = widget.documentType;
      request.fields['user_id'] = 'USER_ID_HERE'; // Get from your auth provider

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        // Success
        Navigator.of(
          context,
        ).pop(true); // Return to document screen with success
        if (mounted) {
          SnackbarHelper.showSuccessSnackBar(
            context,
            "Photo uploaded successfully!",
          );
        }
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Upload error: $e');
      if (mounted) {
        SnackbarHelper.showErrorSnackBar(
          context,
          "Failed to upload photo. Please try again.",
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _getScreenTitle(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body:
          _isInitialized
              ? Stack(
                children: [
                  // Camera preview
                  Positioned.fill(child: CameraPreview(_controller!)),

                  // Guidelines overlay
                  if (widget.documentType == 'profile_picture')
                    Positioned.fill(
                      child: CustomPaint(painter: FaceGuidePainter()),
                    ),

                  if (widget.documentType == 'driving_license')
                    Positioned.fill(
                      child: CustomPaint(painter: DocumentGuidePainter()),
                    ),

                  if (widget.documentType == 'revenue_license')
                    Positioned.fill(
                      child: CustomPaint(painter: RevenueLicenseGuidePainter()),
                    ),

                  // Bottom controls
                  Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        if (widget.documentType == 'profile_picture')
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),

                            child: Text(
                              _getInstructionText(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(width: 60), // Spacer
                            GestureDetector(
                              onTap: _isLoading ? null : _takePicture,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color:
                                      _isLoading ? Colors.grey : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child:
                                    _isLoading
                                        ? const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.black,
                                                ),
                                          ),
                                        )
                                        : const Icon(
                                          Icons.camera_alt,
                                          size: 35,
                                          color: Colors.black,
                                        ),
                              ),
                            ),

                            const SizedBox(width: 60),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )
              : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
    );
  }
}

// Custom painter for face guide overlay
class FaceGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2 - 50);
    const radius = 175.0;

    // Draw circle guide
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Photo preview dialog
class PhotoPreviewDialog extends StatelessWidget {
  final XFile photo;

  const PhotoPreviewDialog({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 500,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              image: DecorationImage(
                image: FileImage(File(photo.path)),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Use this photo?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Retake'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: AppButtonStyles.primaryButton,
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Use Photo'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// New Painter for document guide
class DocumentGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Draw rectangle guide for documents
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.height * 0.5,
    );

    canvas.drawRect(rect, paint);

    // Draw corner brackets
    final bracketLength = 30.0;
    final bracketPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + bracketLength, rect.top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.top + bracketLength),
      bracketPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right - bracketLength, rect.top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + bracketLength),
      bracketPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + bracketLength, rect.bottom),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left, rect.bottom - bracketLength),
      bracketPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right - bracketLength, rect.bottom),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - bracketLength),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// New painter for Revenue License guide
// New painter for Revenue License guide (Square)
class RevenueLicenseGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Make it a square guide
    final squareSize = size.width * 0.65; // Square size

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 100),
      width: squareSize,
      height: squareSize, // Same width and height for square
    );

    canvas.drawRect(rect, paint);

    // Draw corner brackets
    final bracketLength = 25.0; // Smaller brackets for smaller document
    final bracketPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + bracketLength, rect.top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.top + bracketLength),
      bracketPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right - bracketLength, rect.top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + bracketLength),
      bracketPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + bracketLength, rect.bottom),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left, rect.bottom - bracketLength),
      bracketPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right - bracketLength, rect.bottom),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - bracketLength),
      bracketPaint,
    );

    // Removed dimension labels section
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
