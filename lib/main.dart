import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/ai_prompt_service.dart';
import 'screen/start_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AIPromptService(),
      child: const PhotoBoothApp(),
    ),
  );
}

class PhotoBoothApp extends StatelessWidget {
  const PhotoBoothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.dmSerifDisplayTextTheme(),
      ),
      home: const StartScreen(),
    );
  }
}
