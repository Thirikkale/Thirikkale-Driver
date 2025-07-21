import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:thirikkale_driver/core/provider/auth_provider.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';
import 'package:thirikkale_driver/core/utils/snackbar_helper.dart';
import 'package:thirikkale_driver/widgets/custom_modern_loading_overlay.dart';

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
      case 'vehicle_insurance':
        return 'Take Insurance Photo';
      case 'vehicle_registration':
        return 'Take Registration Photo';
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
      case 'vehicle_insurance':
        return 'Place your insurance certificate within the rectangle\nEnsure policy details are clearly visible';
      case 'vehicle_registration':
        return 'Place your registration document within the rectangle\nEnsure all vehicle details are clearly visible';
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
      // Take picture with proper format
      final XFile photo = await _controller!.takePicture();

      print('📸 Photo taken: ${photo.path}');
      print('📏 File size: ${await File(photo.path).length()} bytes');

      // Check if the file exists and is valid
      final file = File(photo.path);
      if (!await file.exists()) {
        throw Exception('Photo file not found');
      }

      // Show preview and upload
      await _showPhotoPreview(photo);
    } catch (e) {
      print('❌ Error taking picture: $e');
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      print('📤 Starting upload process...');
      print('📁 Original file: ${photo.path}');

      // Convert XFile to File and ensure proper image format
      final File imageFile = File(photo.path);

      // Validate file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file not found');
      }

      // Check file size (limit to 10MB)
      final fileSize = await imageFile.length();
      print(
        '📏 File size: ${fileSize} bytes (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)',
      );

      if (fileSize > 10 * 1024 * 1024) {
        // 10MB limit
        throw Exception('File too large. Please choose a smaller image.');
      }

      // Ensure the file has a proper image extension
      String fileName = path.basename(imageFile.path);
      if (!fileName.toLowerCase().endsWith('.jpg') &&
          !fileName.toLowerCase().endsWith('.jpeg') &&
          !fileName.toLowerCase().endsWith('.png')) {
        // Rename file with .jpg extension
        final directory = path.dirname(imageFile.path);
        final newPath = path.join(
          directory,
          '${path.basenameWithoutExtension(fileName)}.jpg',
        );
        final newFile = await imageFile.copy(newPath);

        print('📝 Renamed file: $newPath');

        // Use the renamed file for upload
        final success = await authProvider.uploadDocument(
          documentType: widget.documentType,
          imagePath: newFile.path,
        );

        await _handleUploadResult(success, authProvider);
      } else {
        // File already has proper extension
        final success = await authProvider.uploadDocument(
          documentType: widget.documentType,
          imagePath: imageFile.path,
        );

        await _handleUploadResult(success, authProvider);
      }
    } catch (e) {
      print('❌ Upload error: $e');
      if (mounted) {
        SnackbarHelper.showErrorSnackBar(context, "Upload failed: $e");
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleUploadResult(
    bool success,
    AuthProvider authProvider,
  ) async {
    if (success) {
      // Success - return to document screen with success
      Navigator.of(context).pop(true);
      if (mounted) {
        SnackbarHelper.showSuccessSnackBar(
          context,
          "Document uploaded successfully!",
        );
      }
    } else {
      if (mounted) {
        SnackbarHelper.showErrorSnackBar(
          context,
          authProvider.errorMessage ??
              "Failed to upload document. Please try again.",
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
    return ModernLoadingOverlay(
      isLoading: _isLoading,
      message: "Uploading...",
      style: LoadingStyle.circular,

      child: Scaffold(
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
                        child: CustomPaint(
                          painter: RevenueLicenseGuidePainter(),
                        ),
                      ),

                    if (widget.documentType == 'vehicle_insurance')
                      Positioned.fill(
                        child: CustomPaint(painter: DocumentGuidePainter()),
                      ),

                    if (widget.documentType == 'vehicle_registration')
                      Positioned.fill(
                        child: CustomPaint(
                          painter: VehicleRegistrationDocPainter(),
                        ),
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
                              margin: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
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
                                  child: const Icon(
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
      center: Offset(size.width / 2, size.height / 2 - 60),
      width: size.width * 0.7,
      height: size.height * 0.52,
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

// Add this new painter class for A4 documents
class VehicleRegistrationDocPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // A4 aspect ratio is 1:1.414 (width:height)
    final aspectRatio = 1 / 1.414; // 0.707
    final rectWidth = size.width * 0.75; // Larger width for A4
    final rectHeight =
        rectWidth / aspectRatio; // Calculate height based on A4 ratio

    // Ensure the rectangle fits within the screen
    final maxHeight = size.height * 0.7;
    final finalHeight = rectHeight > maxHeight ? maxHeight : rectHeight;
    final finalWidth = finalHeight * aspectRatio;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 50),
      width: finalWidth,
      height: finalHeight,
    );

    canvas.drawRect(rect, paint);

    // Draw corner brackets
    final bracketLength = 35.0; // Larger brackets for A4 document
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

    // // Add A4 size label
    // final textPainter = TextPainter(
    //   text: const TextSpan(
    //     text: 'A4 Size',
    //     style: TextStyle(
    //       color: Colors.white,
    //       fontSize: 12,
    //       fontWeight: FontWeight.w500,
    //     ),
    //   ),
    //   textDirection: TextDirection.ltr,
    // );

    // textPainter.layout();
    // textPainter.paint(
    //   canvas,
    //   Offset(rect.center.dx - textPainter.width / 2, rect.bottom + 10),
    // );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
