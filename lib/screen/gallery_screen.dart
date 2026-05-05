import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Map<String, dynamic>> savedImages = []; // Now stores path + ratio
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSavedImages();
  }

  Future<void> _loadSavedImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> gallery = prefs.getStringList('gallery_photos') ?? [];
      double savedRatio = prefs.getDouble('selected_aspect_ratio') ?? 3 / 4;

      // Parse stored data (format: "path|ratio")
      List<Map<String, dynamic>> parsedImages = [];
      for (var item in gallery) {
        List<String> parts = item.split('|');
        String path = parts[0];
        double ratio = parts.length > 1 ? double.parse(parts[1]) : savedRatio;

        if (File(path).existsSync()) {
          parsedImages.add({
            'path': path,
            'ratio': ratio,
          });
        }
      }

      // Update if some files were deleted externally
      if (parsedImages.length != gallery.length) {
        List<String> updatedGallery = parsedImages
            .map((img) => '${img['path']}|${img['ratio']}')
            .toList();
        await prefs.setStringList('gallery_photos', updatedGallery);
      }

      setState(() {
        savedImages = parsedImages;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Load gallery error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteImage(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = savedImages[index]['path'];

      // Delete file
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }

      setState(() {
        savedImages.removeAt(index);
      });

      // Save updated list
      List<String> updatedGallery = savedImages
          .map((img) => '${img['path']}|${img['ratio']}')
          .toList();
      await prefs.setStringList('gallery_photos', updatedGallery);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Photo deleted'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Delete error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Delete failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _downloadImage(int index) async {
    try {
      final path = savedImages[index]['path'];

      // Request permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          _showSnackBar('❌ Storage permission denied', Colors.orange);
          return;
        }
      }

      if (Platform.isAndroid) {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        final originalName = path.split('/').last;
        final newPath = '${downloadsDir.path}/$originalName';
        await File(path).copy(newPath);

        _showSnackBar('✅ Downloaded to Downloads!', Colors.green);
      } else {
        _showSnackBar('✅ File at: $path', Colors.green);
      }
    } catch (e) {
      debugPrint('Download error: $e');
      _showSnackBar('❌ Download failed: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.dmSans()),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Photo?', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
        content: Text('This action cannot be undone.', style: GoogleFonts.dmSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.dmSans(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteImage(index);
            },
            child: Text('Delete', style: GoogleFonts.dmSans(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear All Photos?', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
        content: Text('All ${savedImages.length} photos will be permanently deleted.', style: GoogleFonts.dmSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.dmSans(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();

              for (var img in savedImages) {
                try {
                  final file = File(img['path']);
                  if (await file.exists()) await file.delete();
                } catch (e) {
                  debugPrint('Delete error: $e');
                }
              }

              setState(() => savedImages.clear());
              await prefs.setStringList('gallery_photos', []);
              _showSnackBar('🗑️ All photos cleared', Colors.red);
            },
            child: Text('Clear All', style: GoogleFonts.dmSans(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(int index) {
    final ratio = savedImages[index]['ratio'] as double;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: AspectRatio(
              aspectRatio: ratio, // Use saved ratio!
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: kIsWeb
                    ? Image.network(
                  savedImages[index]['path'],
                  fit: BoxFit.cover,
                )
                    : Image.file(
                  File(savedImages[index]['path']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E3FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFC290E4)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Gallery",
          style: GoogleFonts.dmSerifDisplay(
            color: const Color(0xFF1A1A1A),
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          if (savedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Color(0xFFC290E4)),
              onPressed: _showClearAllDialog,
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC290E4)))
          : savedImages.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _loadSavedImages,
        color: const Color(0xFFC290E4),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: GridView.builder(
            itemCount: savedImages.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              // Dynamic childAspectRatio based on average or use a fixed
              childAspectRatio: 0.75, // Default, individual items use their own ratio
            ),
            itemBuilder: (context, index) {
              final ratio = savedImages[index]['ratio'] as double;

              return Hero(
                tag: 'gallery_image_$index',
                child: GestureDetector(
                  onTap: () => _showImagePreview(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC290E4).withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        children: [
                          // Image with correct ratio
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: ratio,
                              child: kIsWeb
                                  ? Image.network(
                                savedImages[index]['path'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholder(),
                              )
                                  : Image.file(
                                File(savedImages[index]['path']),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholder(),
                              ),
                            ),
                          ),
                          // Info bar with ratio indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Ratio badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3E3FE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getRatioLabel(ratio),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 10,
                                      color: const Color(0xFFC290E4),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // Action buttons
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _downloadImage(index),
                                      child: Icon(
                                        Icons.download_rounded,
                                        color: const Color(0xFFC290E4),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () => _showDeleteDialog(index),
                                      child: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red.withOpacity(0.7),
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getRatioLabel(double ratio) {
    if ((ratio - 1.0).abs() < 0.1) return "1:1";
    if ((ratio - 0.75).abs() < 0.1) return "3:4";
    if ((ratio - 0.56).abs() < 0.1) return "9:16";
    if ((ratio - 0.7).abs() < 0.1) return "Fit";
    return ratio.toStringAsFixed(2);
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Icons.broken_image,
        size: 50,
        color: Color(0xFFF3E3FE),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: const Color(0xFFC290E4).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No photos yet',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 20,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a photo and save it to see it here!',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}