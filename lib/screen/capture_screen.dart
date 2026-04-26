import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'prompt_screen.dart';
import 'gallery_screen.dart';

class CaptureScreen extends StatefulWidget {
  final int totalSlots;

  const CaptureScreen({super.key, this.totalSlots = 1});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  int currentCapture = 0;
  double _selectedAspectRatio = 3 / 4;

  void _updateAspectRatio(double ratio) {
    setState(() {
      _selectedAspectRatio = ratio;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E3FE),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Capture",
                      style: GoogleFonts.dmSerifDisplay(fontSize: 24, color: const Color(0xFF1A1A1A)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Main Preview Area (Camera)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AspectRatio(
                  aspectRatio: _selectedAspectRatio,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white, width: 8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC290E4).withValues(alpha: 0.2),
                          blurRadius: 15,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(Icons.camera_alt, color: Colors.white24, size: 50),
                          ),
                          _buildGridOverlay(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Aspect Ratio Panel
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFE94B77).withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    // Aspect Ratio Label at Top of Panel
                    Text(
                      "Aspect Ratio",
                      style: GoogleFonts.grandHotel(
                        fontSize: 28,
                        color: const Color(0xFFE94B77),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Centered Ratio Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildRatioButton("3:4", 3 / 4),
                        const SizedBox(width: 15),
                        _buildRatioButton("1:1", 1 / 1),
                        const SizedBox(width: 15),
                        _buildRatioButton("9:16", 9 / 16),
                      ],
                    ),
                    const SizedBox(height: 25),
                    // Small Preview Slot with matching ratio
                    Center(
                      child: SizedBox(
                        width: 100, // Fixed small width for the slot
                        child: AspectRatio(
                          aspectRatio: _selectedAspectRatio,
                          child: Container(
                            decoration: BoxDecoration(
                              color: currentCapture == 1 ? const Color(0xFFFFE1EA) : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFC290E4),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                currentCapture == 1 ? Icons.check : Icons.camera_alt_outlined,
                                color: currentCapture == 1 ? const Color(0xFFE94B77) : const Color(0xFFC290E4),
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Bottom Controls
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Left Button: Open Gallery
                    _buildIconButton(Icons.photo_library_rounded, onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GalleryScreen()),
                      );
                    }),
                    
                    // Center Button: Shutter
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (currentCapture < 1) {
                            currentCapture++;
                          }
                        });
                        if (currentCapture == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PromptScreen()),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE94B77), width: 4),
                        ),
                        child: const CircleAvatar(
                          radius: 35,
                          backgroundColor: Color(0xFFC290E4),
                        ),
                      ),
                    ),

                    // Right Button: Flip Camera
                    _buildIconButton(Icons.flip_camera_ios_outlined, onTap: () {
                      // Logic for flip camera
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatioButton(String label, double ratio) {
    bool isSelected = _selectedAspectRatio == ratio;
    return GestureDetector(
      onTap: () => _updateAspectRatio(ratio),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC290E4) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE94B77).withValues(alpha: 0.5)),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFFC290E4).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFFE94B77),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildGridOverlay() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(child: Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2)))))),
            Expanded(child: Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2)))))),
            Expanded(child: Container()),
          ],
        ),
        Row(
          children: [
            Expanded(child: Container(decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.2)))))),
            Expanded(child: Container(decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.2)))))),
            Expanded(child: Container()),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFFE94B77), size: 30),
        onPressed: onTap,
      ),
    );
  }
}
