import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'capture_screen.dart';

void main() {
  runApp(const PhotoBoothApp());
}

class PhotoBoothApp extends StatelessWidget {
  const PhotoBoothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC290E4);
    const Color secondaryColor = Color(0xFFEFD9FE);
    const Color surfaceColor = Color(0xFFF3E3FE);
    const Color darkText = Color(0xFF1A1A1A);
    const Color highlightPink = Color(0xFFE94B77);

    return Scaffold(
      backgroundColor: surfaceColor,
      body: Stack(
        children: [
          const Positioned.fill(
            child: GridBackgroundPainter(),
          ),

          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 78),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- TYPOGRAPHY ---
                    Text(
                      "Your",
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 65,
                        color: darkText,
                        height: 1.0,
                      ),
                    ),

                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, 15),
                          child: Container(
                            height: 18,
                            width: 240,
                            decoration: BoxDecoration(
                              color: secondaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        Text(
                          "Aesthetic",
                          style: GoogleFonts.grandHotel(
                            fontSize: 75,
                            color: highlightPink,
                          ),
                        ),
                      ],
                    ),

                    Text(
                      "Photobooth",
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 55,
                        color: darkText,
                        height: 1.0,
                      ),
                    ),

                    Text(
                      "Experience",
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 55,
                        color: darkText,
                        height: 1.0,
                      ),
                    ),

                    const SizedBox(height: 35),

                    // --- DESCRIPTION ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Capture moments using your camera and choose from beautiful backgrounds to create your own photo strips.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.instrumentSans(
                          fontSize: 18,
                          color: darkText.withOpacity(0.7),
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // --- BUTTON ---
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: 25,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CaptureScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.camera_rounded, color: Colors.white),
                        label: const Text(
                          "Start the Booth",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
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

class GridBackgroundPainter extends StatelessWidget {
  const GridBackgroundPainter({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC290E4).withOpacity(0.12)
      ..strokeWidth = 1.0;

    const double gap = 25.0;

    // Vertical Lines
    for (double i = 0; i < size.width; i += gap) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    // Horizontal Lines
    for (double i = 0; i < size.height; i += gap) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}