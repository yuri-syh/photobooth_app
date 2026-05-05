import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/ai_prompt_service.dart';
import 'gallery_screen.dart';

class PromptScreen extends StatefulWidget {
  final String imagePath;
  final double selectedRatio;

  const PromptScreen({
    super.key,
    required this.imagePath,
    this.selectedRatio = 3 / 4,
  });

  @override
  State<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  final Color primaryColor = const Color(0xFFC290E4);
  final Color highlightPink = const Color(0xFFE94B77);

  String _selectedCountry = 'japan';
  bool _showStyleSelector = true;
  bool _showEditor = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AIPromptService>(context, listen: false)
          .setOriginalPhoto(widget.imagePath);
    });
  }

  Future<void> _createDestinationPhoto(String styleKey) async {
    final service = Provider.of<AIPromptService>(context, listen: false);
    await service.createDestinationPhoto(styleKey);

    setState(() {
      _showStyleSelector = false;
      _showEditor = true;
    });
  }

  Future<void> _remerge() async {
    final service = Provider.of<AIPromptService>(context, listen: false);
    await service.remergeWithCurrentTransform();
  }

  /// 💾 SAVE TO GALLERY (with ratio!)
  Future<void> _saveToGallery() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final service = Provider.of<AIPromptService>(context, listen: false);
      final sourcePath = service.finalMergedPath;

      if (sourcePath == null) {
        _showSnackBar('❌ No image to save', Colors.red);
        return;
      }

      // Get app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final galleryDir = Directory('${appDir.path}/gallery');

      if (!await galleryDir.exists()) {
        await galleryDir.create(recursive: true);
      }

      final fileName = 'nanobanana_${DateTime.now().millisecondsSinceEpoch}.png';
      final newPath = '${galleryDir.path}/$fileName';

      // Copy file to gallery folder
      await File(sourcePath).copy(newPath);

      // Save to SharedPreferences WITH RATIO (format: "path|ratio")
      final prefs = await SharedPreferences.getInstance();
      List<String> gallery = prefs.getStringList('gallery_photos') ?? [];

      // Store path and ratio together
      String entry = '$newPath|${widget.selectedRatio}';
      gallery.add(entry);

      await prefs.setStringList('gallery_photos', gallery);

      _showSnackBar('✅ Saved to Gallery!', Colors.green);

    } catch (e) {
      debugPrint('Gallery save error: $e');
      _showSnackBar('❌ Failed to save: $e', Colors.red);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// 🔄 TRY ANOTHER (Reset and go back to style selector)
  void _tryAnother() {
    final service = Provider.of<AIPromptService>(context, listen: false);
    service.clearGeneratedImage();

    setState(() {
      _showStyleSelector = true;
      _showEditor = false;
    });
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.dmSans()),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _goToGallery() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GalleryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E3FE),
      body: Stack(
        children: [
          const Positioned.fill(child: GridBackground()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "✈️ Travel Photo Booth",
                          style: GoogleFonts.dmSerifDisplay(fontSize: 24),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.photo_library_rounded, color: primaryColor),
                        onPressed: _goToGallery,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // PREVIEW AREA with correct ratio
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: widget.selectedRatio, // Use passed ratio!
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white, width: 8),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Consumer<AIPromptService>(
                            builder: (context, service, child) {
                              if (service.isGenerating) {
                                return Container(
                                  color: Colors.black87,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(color: primaryColor),
                                      const SizedBox(height: 20),
                                      Text(
                                        'Generating Aesthetic Scene...',
                                        style: GoogleFonts.dmSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'AI is working on your background',
                                        style: TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final imagePath = service.finalMergedPath
                                  ?? service.removedBgPath
                                  ?? widget.imagePath;

                              return kIsWeb
                                  ? Image.network(
                                imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, color: Colors.white),
                              )
                                  : Image.file(
                                File(imagePath),
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CONTROLS AREA
                  Consumer<AIPromptService>(
                    builder: (context, service, child) {
                      if (service.isGenerating) return const SizedBox.shrink();

                      if (_showEditor && service.hasFinalImage) {
                        return _buildEditorControls(service);
                      }

                      if (_showStyleSelector) {
                        return _buildCountrySelector(service);
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // Loading overlay when saving
          if (_isSaving)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditorControls(AIPromptService service) {
    return Column(
      children: [
        // Position/Size Editor
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🎮 Customize Your Pose',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 10),
              _buildSliderRow('Horizontal', service.photoOffsetX, (val) {
                service.setPhotoOffset(val, service.photoOffsetY);
                _remerge();
              }),
              _buildSliderRow('Vertical', service.photoOffsetY, (val) {
                service.setPhotoOffset(service.photoOffsetX, val);
                _remerge();
              }),
              _buildSliderRow('Size', service.photoScale, (val) {
                service.setPhotoScale(val);
                _remerge();
              }, min: 0.1, max: 1.5),
              Center(
                child: TextButton(
                  onPressed: () {
                    service.resetPhotoTransform();
                    _remerge();
                  },
                  child: Text('Reset Position', style: TextStyle(color: primaryColor)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Action Buttons Row
        Row(
          children: [
            // Save to Gallery Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveToGallery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(Icons.photo_library, color: Colors.white, size: 20),
                label: Text(
                  'Save to Gallery',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        const SizedBox(height: 8),
        // Try Another Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isSaving ? null : _tryAnother,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(14),
              side: BorderSide(color: primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            icon: Icon(Icons.refresh_rounded, color: primaryColor, size: 20),
            label: Text(
              'Try Another',
              style: GoogleFonts.dmSans(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountrySelector(AIPromptService service) {
    final countries = {
      'japan': '🇯🇵 Japan',
      'korea': '🇰🇷 Korea',
      'thailand': '🇹🇭 Thailand',
      'france': '🇫🇷 France',
      'italy': '🇮🇹 Italy',
      'usa': '🇺🇸 USA',
      'greece': '🇬🇷 Greece',
      'maldives': '🇲🇻 Maldives',
      'switzerland': '🇨🇭 Switzerland',
      'uae': '🇦🇪 UAE',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedCountry,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
          items: countries.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (val) => setState(() => _selectedCountry = val!),
        ),
        const SizedBox(height: 12),
        Text(
          'Choose a scene to generate:',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AIPromptService.allDestinations[_selectedCountry]!
              .entries
              .map((e) => ActionChip(
            label: Text(e.value),
            onPressed: () => _createDestinationPhoto(e.key),
          ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSliderRow(
      String label,
      double value,
      ValueChanged<double> onChanged, {
        double min = -1.0,
        double max = 1.0,
      }) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 12))),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            activeColor: primaryColor,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class GridBackground extends StatelessWidget {
  const GridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter());
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC290E4).withOpacity(0.1)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}