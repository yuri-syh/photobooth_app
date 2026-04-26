import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screen/start_screen.dart';

void main() {
  runApp(const PhotoBoothApp());
}

class PhotoBoothApp extends StatelessWidget {
  const PhotoBoothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Global font setup para iwas error sa screens
        textTheme: GoogleFonts.dmSerifDisplayTextTheme(),
      ),
      home: const StartScreen(),
    );
  }
}