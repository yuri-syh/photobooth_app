import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PromptScreen extends StatefulWidget {
  const PromptScreen({super.key});

  @override
  State<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  final TextEditingController _promptController = TextEditingController();
  bool _isGenerating = false;
  bool _isGenerated = false;

  void _generateAIImage() async {
    setState(() {
      _isGenerating = true;
    });

    // Simulate AI generation delay
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
      backgroundColor: const Color(0xFFF3E3FE), // Violet background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFC290E4)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Magic Generation",
          style: GoogleFonts.dmSerifDisplay(color: const Color(0xFF1A1A1A)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Describe your style",
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 24, 
                color: const Color(0xFFE94B77), // Pink for contrast
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Our AI will transform your photo based on your prompt.",
              style: TextStyle(color: Colors.black.withOpacity(0.5)),
            ),
            const SizedBox(height: 30),
            
            // Preview Box
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFC290E4).withOpacity(0.5), 
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE94B77).withOpacity(0.1),
                      blurRadius: 15,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(27),
                  child: _isGenerating
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: Color(0xFFE94B77)),
                            const SizedBox(height: 20),
                            Text(
                              "Generating Magic...",
                              style: TextStyle(color: const Color(0xFFC290E4), fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      : _isGenerated
                          ? const Center(child: Icon(Icons.auto_awesome, size: 80, color: Color(0xFFE94B77)))
                          : const Center(child: Icon(Icons.photo_outlined, size: 80, color: Color(0xFFF3E3FE))),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            if (!_isGenerated) ...[
              // Prompt Input Box
              TextField(
                controller: _promptController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Example: Retro 90s aesthetic, dreamy lighting, soft pink tones...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: const Color(0xFFC290E4).withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: const Color(0xFFC290E4).withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFFE94B77), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // Generate Button (Combined Colors)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC290E4), Color(0xFFE94B77)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE94B77).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _generateAIImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                  child: const Text(
                    "Generate AI Photo ✨",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ] else ...[
              // Download Button (Combined Colors)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE94B77), Color(0xFFC290E4)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC290E4).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("AI Photo saved to Gallery!")),
                    );
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_rounded, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        "Download PNG",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isGenerated = false;
                      _promptController.clear();
                    });
                  },
                  child: const Text(
                    "Try another prompt", 
                    style: TextStyle(color: Color(0xFFE94B77), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
