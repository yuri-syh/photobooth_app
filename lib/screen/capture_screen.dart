import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'prompt_screen.dart';
import 'gallery_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  String? capturedImagePath;
  double _selectedAspectRatio = 3 / 4;

  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;

  final Color primaryColor = const Color(0xFFC290E4);
  final Color surfaceColor = const Color(0xFFF3E3FE);
  final Color ultraLightSurface = const Color(0xFFFBF4FF);
  final Color highlightPink = const Color(0xFFE94B77);
  final Color darkText = const Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _loadSavedRatio();
    _setupCamera();
  }

  /// 📐 Load saved ratio from previous session
  Future<void> _loadSavedRatio() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRatio = prefs.getDouble('selected_aspect_ratio');
    if (savedRatio != null) {
      setState(() => _selectedAspectRatio = savedRatio);
    }
  }

  /// 📐 Save selected ratio
  Future<void> _saveRatio(double ratio) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('selected_aspect_ratio', ratio);
  }

  Future<void> _setupCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;
      await _initCameraController(_cameras[_selectedCameraIndex]);
    } catch (e) {
      debugPrint("Camera Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera Error: $e')),
        );
      }
    }
  }

  Future<void> _initCameraController(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint("Initialization Error: $e");
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    setState(() => _isInitialized = false);
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _initCameraController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile image = await _controller!.takePicture();
      setState(() => capturedImagePath = image.path);
    } catch (e) {
      debugPrint("Capture Error: $e");
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
      backgroundColor: surfaceColor,
      body: Stack(
        children: [
          const Positioned.fill(child: GridBackgroundPainter()),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text("Capture", style: GoogleFonts.dmSerifDisplay(fontSize: 28, color: darkText)),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: AspectRatio(
                        aspectRatio: _selectedAspectRatio,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white, width: 8),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (capturedImagePath == null)
                                  _isInitialized && _controller != null
                                      ? FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: _controller!.value.previewSize!.height,
                                      height: _controller!.value.previewSize!.width,
                                      child: CameraPreview(_controller!),
                                    ),
                                  )
                                      : const Center(
                                    child: CircularProgressIndicator(color: Colors.white),
                                  )
                                else
                                  kIsWeb
                                      ? Image.network(capturedImagePath!, fit: BoxFit.cover)
                                      : Image.file(File(capturedImagePath!), fit: BoxFit.cover),
                                _buildGridOverlay(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ultraLightSurface,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: primaryColor, width: 2.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDashedRatioButton("1:1", 1 / 1),
                      _buildDashedRatioButton("3:4", 3 / 4),
                      _buildDashedRatioButton("9:16", 9 / 16),
                      _buildDashedRatioButton("Fit", 0.7),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildIconButton(Icons.photo_library_rounded, onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GalleryScreen()),
                        );
                      }),
                      GestureDetector(
                        onTap: () async {
                          if (capturedImagePath == null) {
                            await _takePicture();
                          } else {
                            // Save ratio before navigating
                            await _saveRatio(_selectedAspectRatio);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PromptScreen(
                                  imagePath: capturedImagePath!,
                                  selectedRatio: _selectedAspectRatio,
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: highlightPink.withOpacity(0.4), width: 3),
                          ),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: capturedImagePath == null ? primaryColor : highlightPink,
                            child: Icon(
                              capturedImagePath == null ? Icons.camera : Icons.check,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      _buildIconButton(
                        capturedImagePath == null ? Icons.flip_camera_ios_outlined : Icons.refresh_rounded,
                        onTap: () {
                          if (capturedImagePath == null) {
                            _flipCamera();
                          } else {
                            setState(() => capturedImagePath = null);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedRatioButton(String label, double ratio) {
    bool isSelected = _selectedAspectRatio == ratio;
    bool isDisabled = capturedImagePath != null;

    return GestureDetector(
      onTap: () {
        if (!isDisabled) {
          setState(() => _selectedAspectRatio = ratio);
          _saveRatio(ratio); // Save when selected
        }
      },
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1.0,
        child: DottedBorder(
          color: primaryColor,
          strokeWidth: isSelected ? 3 : 1.5,
          dashPattern: isSelected ? const [1, 0] : const [6, 3],
          borderType: BorderType.RRect,
          radius: const Radius.circular(15),
          child: Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.dmSerifDisplay(fontSize: 16, color: primaryColor),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridOverlay() {
    return IgnorePointer(
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, {VoidCallback? onTap}) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: primaryColor, size: 26),
        onPressed: onTap,
      ),
    );
  }
}

class GridBackgroundPainter extends StatelessWidget {
  const GridBackgroundPainter({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter());
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC290E4).withOpacity(0.12)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 30.0) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 30.0) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}