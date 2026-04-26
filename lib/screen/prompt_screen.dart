import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';

class PromptScreen extends StatefulWidget {
  final String imagePath;
  final double selectedRatio; // Tinatanggap ang ratio from CaptureScreen

  const PromptScreen({
    super.key,
    required this.imagePath,
    this.selectedRatio = 3 / 4, // Default ratio
  });

  @override
  State<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  final TextEditingController _promptController = TextEditingController();
  bool _isGenerating = false;
  bool _isGenerated = false;

  // Colors
  final Color primaryColor = const Color(0xFFC290E4);
  final Color highlightPink = const Color(0xFFE94B77);

  void _generateAIImage() async {
    if (_promptController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a prompt first!")),
      );
      return;
    }
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _isGenerating = false;
        _isGenerated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E3FE),
      resizeToAvoidBottomInset: false, // Iwas overflow sa keyboard
      body: Stack(
        children: [
          // 1. Grid Background
          const Positioned.fill(child: GridBackgroundPainter()),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Enhance with AI",
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 26,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- DYNAMIC PREVIEW BOX  ---
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: widget.selectedRatio, // Eto yung ratio mula sa Capture
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(30),
                            // Solid White Border
                            border: Border.all(color: Colors.white, width: 8),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: kIsWeb
                                ? Image.network(widget.imagePath, fit: BoxFit.cover)
                                : Image.file(File(widget.imagePath), fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- CONTROLS SECTION ---
                  if (!_isGenerated) ...[
                    TextField(
                      controller: _promptController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: "Describe your vibe...",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isGenerating ? null : _generateAIImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        ),
                        child: _isGenerating
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                            : const Text(
                          "Generate",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Success State
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.download_rounded, color: Colors.white),
                            SizedBox(width: 12),
                            Text("Download PNG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () => setState(() => _isGenerated = false),
                        child: Text(
                          "Try another prompt",
                          style: TextStyle(color: highlightPink, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- GRID PAINTER ---
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
    const double gap = 30.0;
    for (double i = 0; i < size.width; i += gap) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += gap) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}