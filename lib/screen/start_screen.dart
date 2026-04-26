import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'capture_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E3FE),
      body: Stack(
        children: [
          // Background Grid Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Your",
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft highlight behind "Aesthetic"
                        Transform.translate(
                          offset: const Offset(0, 15),
                          child: Container(
                            width: 180,
                            height: 25,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE1EA).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        Text(
                          "Aesthetic",
                          style: GoogleFonts.grandHotel(
                            fontSize: 85,
                            color: const Color(0xFFE94B77),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Photobooth",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                        height: 0.9,
                      ),
                    ),
                    Text(
                      "Experience",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                        height: 0.9,
                      ),
                    ),
                    const SizedBox(height: 35),
                    Text(
                      "Capture moments using your camera and choose from beautiful backgrounds to create your own photo strips.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 60),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC290E4),
                        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black26,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CaptureScreen(totalSlots: 1),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.camera, color: Colors.white, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            "Start the Booth",
                            style: GoogleFonts.dmSerifDisplay(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.04)
      ..strokeWidth = 1.0;

    const double step = 30.0;

    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
