import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class AIPromptService extends ChangeNotifier {
  static const String _removeBgApiKey = '';

  String? _originalPhotoPath;
  String? _removedBgPath;
  String? _generatedBgPath;
  String? _finalMergedPath;
  bool _isGenerating = false;
  String? _errorMessage;

  double _photoScale = 0.75;
  double _photoOffsetX = 0.0;
  double _photoOffsetY = 0.3;

  String? get originalPhotoPath => _originalPhotoPath;
  String? get removedBgPath => _removedBgPath;
  String? get generatedBgPath => _generatedBgPath;
  String? get finalMergedPath => _finalMergedPath;
  bool get isGenerating => _isGenerating;
  String? get errorMessage => _errorMessage;
  bool get hasFinalImage => _finalMergedPath != null;

  double get photoScale => _photoScale;
  double get photoOffsetX => _photoOffsetX;
  double get photoOffsetY => _photoOffsetY;

  void setOriginalPhoto(String path) {
    _originalPhotoPath = path;
    _removedBgPath = null;
    _generatedBgPath = null;
    _finalMergedPath = null;
    _errorMessage = null;
    _photoScale = 0.75;
    _photoOffsetX = 0.0;
    _photoOffsetY = 0.3;
    notifyListeners();
  }

  static const Map<String, Map<String, String>> allDestinations = {
    'japan': {
      'cherry_blossom': '🌸 Cherry Blossom',
      'tokyo_night': '🌃 Tokyo Night',
      'temple': '⛩️ Temple',
      'bamboo_forest': '🎋 Bamboo Forest',
      'mount_fuji': '🗻 Mount Fuji',
      'autumn_kyoto': '🍁 Autumn Kyoto',
      'snow_monkey': '🐒 Snow Monkey',
      'torii_gate': '⛩️ Torii Gates',
    },
    'korea': {
      'gyeongbokgung': '🏯 Gyeongbokgung',
      'seoul_night': '🌃 Seoul Night',
      'jeju_island': '🌊 Jeju Island',
      'cherry_blossom_kr': '🌸 Jinhae Cherry',
      'bukchon': '🏘️ Bukchon',
      'nami_island': '🌲 Nami Island',
      'lotte_tower': '🏢 Lotte Tower',
      'autumn_naejang': '🍁 Naejangsan',
    },
    'thailand': {
      'wat_arun': '🛕 Wat Arun',
      'phi_phi': '🏝️ Phi Phi Island',
      'chiang_mai': '🐘 Chiang Mai',
      'floating_market': '🛶 Floating Market',
      'full_moon': '🌕 Full Moon Party',
      'grand_palace': '👑 Grand Palace',
      'railay_beach': '🏖️ Railay Beach',
      'doi_inthanon': '⛰️ Doi Inthanon',
    },
    'france': {
      'eiffel_tower': '🗼 Eiffel Tower',
      'louvre': '🎨 Louvre Museum',
      'mont_saint': '🏰 Mont Saint-Michel',
      'provence': '🌻 Provence',
      'versailles': '👑 Versailles',
      'french_alps': '🏔️ French Alps',
      'loire_valley': '🍷 Loire Valley',
      'cote_dazur': '🏖️ Côte d\'Azur',
    },
    'italy': {
      'colosseum': '🏛️ Colosseum',
      'venice': '🛶 Venice',
      'amalfi': '🌊 Amalfi Coast',
      'tuscany': '🍇 Tuscany',
      'cinque_terre': '🏘️ Cinque Terre',
      'dolomites': '⛰️ Dolomites',
      'pompeii': '🌋 Pompeii',
      'lake_como': '🏞️ Lake Como',
    },
    'usa': {
      'grand_canyon': '🏜️ Grand Canyon',
      'times_square': '🌃 Times Square',
      'golden_gate': '🌉 Golden Gate',
      'yellowstone': '🌋 Yellowstone',
      'hawaii': '🌺 Hawaii',
      'new_orleans': '🎷 New Orleans',
      'yosemite': '🏔️ Yosemite',
      'las_vegas': '🎰 Las Vegas',
    },
    'greece': {
      'santorini': '🌅 Santorini',
      'acropolis': '🏛️ Acropolis',
      'mykonos': '🏖️ Mykonos',
      'meteora': '⛰️ Meteora',
      'zakynthos': '🚢 Zakynthos',
      'delphi': '🏺 Delphi',
      'rhodes': '🏰 Rhodes',
      'navagio': '🚢 Navagio',
    },
    'maldives': {
      'overwater': '🏝️ Overwater Villa',
      'underwater': '🐠 Underwater',
      'sunset': '🌅 Sunset Beach',
      'bioluminescent': '✨ Bioluminescent',
      'sandbank': '🏖️ Sandbank',
      'coral_reef': '🪸 Coral Reef',
      'local_island': '🏘️ Local Island',
      'luxury_resort': '🏨 Luxury Resort',
    },
    'switzerland': {
      'matterhorn': '⛰️ Matterhorn',
      'interlaken': '🏔️ Interlaken',
      'lucerne': '🌉 Lucerne',
      'zermatt': '🎿 Zermatt',
      'geneva': '🌊 Geneva',
      'jungfrau': '🚂 Jungfrau',
      'grindelwald': '🏔️ Grindelwald',
      'rhine_falls': '💦 Rhine Falls',
    },
    'uae': {
      'burj_khalifa': '🏙️ Burj Khalifa',
      'desert_safari': '🐪 Desert Safari',
      'palm_jumeirah': '🌴 Palm Jumeirah',
      'sheikh_zayed': '🕌 Sheikh Zayed',
      'dubai_marina': '⛵ Dubai Marina',
      'al_ain': '🌴 Al Ain Oasis',
      'hatta': '🏔️ Hatta',
      'abu_dhabi': '🏙️ Abu Dhabi',
    },
  };

  static const Map<String, String> destinationPrompts = {
    'cherry_blossom': 'Beautiful Japanese cherry blossom garden, Mount Fuji in background, soft pink petals falling, golden hour lighting, dreamy atmosphere, photorealistic, 8k quality, suitable for photo background, no people',
    'tokyo_night': 'Tokyo city street at night, neon lights, cyberpunk atmosphere, Shibuya crossing, cinematic, photorealistic, suitable for photo background, no people',
    'temple': 'Traditional Japanese temple, zen garden, koi pond, serene landscape, morning mist, photorealistic, suitable for photo background, no people',
    'bamboo_forest': 'Kyoto Arashiyama bamboo forest, dappled sunlight, peaceful atmosphere, path through bamboo, photorealistic, suitable for photo background, no people',
    'mount_fuji': 'Stunning view of Mount Fuji, Lake Kawaguchi, reflection on water, cherry blossoms, photorealistic, suitable for photo background, no people',
    'autumn_kyoto': 'Kyoto autumn foliage, red maple leaves, traditional street, warm lighting, photorealistic, suitable for photo background, no people',
    'snow_monkey': 'Japanese hot spring onsen, snow monkey, winter scenery, steam rising, photorealistic, suitable for photo background, no people',
    'torii_gate': 'Fushimi Inari shrine, thousands of red torii gates, pathway, mystical atmosphere, photorealistic, suitable for photo background, no people',
    'gyeongbokgung': 'Gyeongbokgung Palace Seoul, traditional Korean architecture, autumn leaves, blue roof tiles, photorealistic, suitable for photo background, no people',
    'seoul_night': 'Seoul cityscape at night, N Seoul Tower, neon lights, modern skyscrapers, photorealistic, suitable for photo background, no people',
    'jeju_island': 'Jeju Island Korea, volcanic coastline, turquoise water, green fields, Hallasan mountain, photorealistic, suitable for photo background, no people',
    'cherry_blossom_kr': 'Jinhae cherry blossom festival, pink flower tunnel, romantic atmosphere, spring in Korea, photorealistic, suitable for photo background, no people',
    'bukchon': 'Bukchon Hanok Village Seoul, traditional Korean houses, narrow alleys, photorealistic, suitable for photo background, no people',
    'nami_island': 'Nami Island Korea, tree-lined path, four seasons, romantic winter snow, photorealistic, suitable for photo background, no people',
    'lotte_tower': 'Lotte World Tower Seoul, modern skyscraper, city view, sunset, photorealistic, suitable for photo background, no people',
    'autumn_naejang': 'Naejangsan National Park autumn, colorful maple trees, hiking trail, photorealistic, suitable for photo background, no people',
    'wat_arun': 'Wat Arun temple Bangkok, golden spires, Chao Phraya river, sunset, photorealistic, suitable for photo background, no people',
    'phi_phi': 'Phi Phi Islands Thailand, turquoise water, limestone cliffs, tropical paradise, photorealistic, suitable for photo background, no people',
    'chiang_mai': 'Chiang Mai Thailand, elephant sanctuary, jungle mountains, golden temple, photorealistic, suitable for photo background, no people',
    'floating_market': 'Damnoen Saduak floating market, colorful boats, tropical fruits, photorealistic, suitable for photo background, no people',
    'full_moon': 'Full Moon Party Koh Phangan, beach party, fire dancers, moonlit beach, photorealistic, suitable for photo background, no people',
    'grand_palace': 'Grand Palace Bangkok, golden architecture, ornate details, photorealistic, suitable for photo background, no people',
    'railay_beach': 'Railay Beach Krabi, limestone cliffs, crystal water, tropical beach, photorealistic, suitable for photo background, no people',
    'doi_inthanon': 'Doi Inthanon National Park, highest peak Thailand, misty mountains, pagodas, photorealistic, suitable for photo background, no people',
    'eiffel_tower': 'Eiffel Tower Paris, romantic sunset, Seine river, golden hour, photorealistic, suitable for photo background, no people',
    'louvre': 'Louvre Museum Paris, glass pyramid, classical architecture, photorealistic, suitable for photo background, no people',
    'mont_saint': 'Mont Saint-Michel France, medieval abbey, tidal island, dramatic sky, photorealistic, suitable for photo background, no people',
    'provence': 'Provence lavender fields, endless purple flowers, golden sunset, photorealistic, suitable for photo background, no people',
    'versailles': 'Palace of Versailles, Hall of Mirrors, golden opulence, baroque architecture, photorealistic, suitable for photo background, no people',
    'french_alps': 'French Alps Chamonix, snow-capped peaks, alpine meadow, photorealistic, suitable for photo background, no people',
    'loire_valley': 'Loire Valley chateaux, rolling vineyards, Renaissance castles, photorealistic, suitable for photo background, no people',
    'cote_dazur': 'French Riviera Nice, turquoise Mediterranean, colorful buildings, photorealistic, suitable for photo background, no people',
    'colosseum': 'Colosseum Rome, ancient amphitheater, golden sunset, dramatic clouds, photorealistic, suitable for photo background, no people',
    'venice': 'Venice Grand Canal, gondolas, colorful buildings, Rialto Bridge, photorealistic, suitable for photo background, no people',
    'amalfi': 'Amalfi Coast Italy, cliffside villages, turquoise sea, lemon groves, photorealistic, suitable for photo background, no people',
    'tuscany': 'Tuscany countryside, rolling hills, cypress trees, vineyard sunset, photorealistic, suitable for photo background, no people',
    'cinque_terre': 'Cinque Terre Italy, colorful cliffside houses, Mediterranean view, photorealistic, suitable for photo background, no people',
    'dolomites': 'Dolomites Italy, dramatic mountain peaks, alpine lake, sunrise, photorealistic, suitable for photo background, no people',
    'pompeii': 'Pompeii ruins, ancient Roman city, Mount Vesuvius background, photorealistic, suitable for photo background, no people',
    'lake_como': 'Lake Como Italy, elegant villas, snow-capped mountains, crystal water, photorealistic, suitable for photo background, no people',
    'grand_canyon': 'Grand Canyon Arizona, dramatic red rock formations, sunset colors, photorealistic, suitable for photo background, no people',
    'times_square': 'Times Square New York, neon billboards, bustling night, photorealistic, suitable for photo background, no people',
    'golden_gate': 'Golden Gate Bridge San Francisco, red suspension bridge, fog, photorealistic, suitable for photo background, no people',
    'yellowstone': 'Yellowstone National Park, geysers, hot springs, bison, photorealistic, suitable for photo background, no people',
    'hawaii': 'Hawaii tropical beach, palm trees, volcanic mountains, turquoise water, photorealistic, suitable for photo background, no people',
    'new_orleans': 'New Orleans French Quarter, jazz street, colorful balconies, photorealistic, suitable for photo background, no people',
    'yosemite': 'Yosemite National Park, El Capitan, waterfall, giant sequoias, photorealistic, suitable for photo background, no people',
    'las_vegas': 'Las Vegas Strip, neon lights, casino resorts, night cityscape, photorealistic, suitable for photo background, no people',
    'santorini': 'Santorini Greece, white buildings, blue domes, caldera sunset, photorealistic, suitable for photo background, no people',
    'acropolis': 'Acropolis Athens, Parthenon, ancient Greek temple, golden sunset, photorealistic, suitable for photo background, no people',
    'mykonos': 'Mykonos Greece, windmills, white-washed houses, turquoise sea, photorealistic, suitable for photo background, no people',
    'meteora': 'Meteora Greece, monasteries on rock pillars, dramatic landscape, photorealistic, suitable for photo background, no people',
    'zakynthos': 'Zakynthos Shipwreck Beach, Navagio Bay, turquoise water, photorealistic, suitable for photo background, no people',
    'delphi': 'Delphi ancient ruins, Greek theater, mountain landscape, photorealistic, suitable for photo background, no people',
    'rhodes': 'Rhodes medieval old town, castle walls, cobblestone streets, photorealistic, suitable for photo background, no people',
    'navagio': 'Navagio Beach Zakynthos, shipwreck on white sand, blue caves, photorealistic, suitable for photo background, no people',
    'overwater': 'Maldives overwater villa, crystal clear lagoon, wooden deck, tropical paradise, photorealistic, suitable for photo background, no people',
    'underwater': 'Maldives underwater scene, coral reef, tropical fish, sea turtles, photorealistic, suitable for photo background, no people',
    'sunset': 'Maldives sunset beach, golden sky, palm trees silhouette, romantic, photorealistic, suitable for photo background, no people',
    'bioluminescent': 'Maldives bioluminescent beach, glowing blue waves, starry night, magical, photorealistic, suitable for photo background, no people',
    'sandbank': 'Maldives sandbank, pure white sand, turquoise water, aerial view, photorealistic, suitable for photo background, no people',
    'coral_reef': 'Maldives coral reef, vibrant underwater garden, tropical fish, clear water, photorealistic, suitable for photo background, no people',
    'local_island': 'Maldives local island, colorful houses, traditional dhoni boats, photorealistic, suitable for photo background, no people',
    'luxury_resort': 'Maldives luxury resort, infinity pool, palm trees, turquoise lagoon, photorealistic, suitable for photo background, no people',
    'matterhorn': 'Matterhorn Switzerland, iconic pyramid peak, Zermatt village, sunrise, photorealistic, suitable for photo background, no people',
    'interlaken': 'Interlaken Switzerland, turquoise lakes, snow mountains, paragliding, photorealistic, suitable for photo background, no people',
    'lucerne': 'Lucerne Chapel Bridge, medieval wooden bridge, lake, mountains, photorealistic, suitable for photo background, no people',
    'zermatt': 'Zermatt ski resort, Matterhorn view, snowy village, cozy chalets, photorealistic, suitable for photo background, no people',
    'geneva': 'Geneva Lake Jet d\'Eau, Swiss Alps backdrop, elegant city, photorealistic, suitable for photo background, no people',
    'jungfrau': 'Jungfraujoch Top of Europe, snowy peaks, glacier, train, photorealistic, suitable for photo background, no people',
    'grindelwald': 'Grindelwald Switzerland, Eiger north face, alpine meadow, photorealistic, suitable for photo background, no people',
    'rhine_falls': 'Rhine Falls Switzerland, largest waterfall Europe, misty, photorealistic, suitable for photo background, no people',
    'burj_khalifa': 'Burj Khalifa Dubai, tallest building, fountain show, night lights, photorealistic, suitable for photo background, no people',
    'desert_safari': 'Dubai desert safari, golden sand dunes, camel caravan, sunset, photorealistic, suitable for photo background, no people',
    'palm_jumeirah': 'Palm Jumeirah Dubai, artificial island, Atlantis hotel, aerial view, photorealistic, suitable for photo background, no people',
    'sheikh_zayed': 'Sheikh Zayed Grand Mosque Abu Dhabi, white marble, golden domes, reflection pool, photorealistic, suitable for photo background, no people',
    'dubai_marina': 'Dubai Marina, skyscrapers, yacht harbor, night lights, photorealistic, suitable for photo background, no people',
    'al_ain': 'Al Ain Oasis UAE, date palm groves, traditional falaj irrigation, photorealistic, suitable for photo background, no people',
    'hatta': 'Hatta Mountains UAE, rocky terrain, turquoise dam, kayaking, photorealistic, suitable for photo background, no people',
    'abu_dhabi': 'Abu Dhabi skyline, modern architecture, Corniche beach, photorealistic, suitable for photo background, no people',
  };

  void setPhotoScale(double scale) {
    _photoScale = scale.clamp(0.1, 2.0);
    notifyListeners();
  }

  void setPhotoOffset(double dx, double dy) {
    _photoOffsetX = dx.clamp(-1.0, 1.0);
    _photoOffsetY = dy.clamp(-1.0, 1.0);
    notifyListeners();
  }

  void resetPhotoTransform() {
    _photoScale = 0.75;
    _photoOffsetX = 0.0;
    _photoOffsetY = 0.3;
    notifyListeners();
  }

  Future<void> createDestinationPhoto(String destinationKey) async {
    _isGenerating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔲 Step 1: Removing background...');
      await _removeBackground(_originalPhotoPath!);

      debugPrint('🎨 Step 2: Generating background...');
      await _generateBackground(destinationKey);

      debugPrint('🔀 Step 3: Merging images...');
      await _mergeImagesWithTransform();

      debugPrint('✅ Done! Final image: $_finalMergedPath');
    } catch (e) {
      _errorMessage = 'Error: $e';
      debugPrint('❌ Error: $e');
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> _removeBackground(String imagePath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.remove.bg/v1.0/removebg'),
    )
      ..headers['X-Api-Key'] = _removeBgApiKey
      ..files.add(http.MultipartFile.fromBytes(
        'image_file',
        bytes,
        filename: 'photo.png',
      ))
      ..fields['size'] = 'auto';

    final response = await request.send();
    final responseData = await response.stream.toBytes();

    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'nobg_${DateTime.now().millisecondsSinceEpoch}.png';
      final outputFile = File('${tempDir.path}/$fileName');
      await outputFile.writeAsBytes(responseData);

      _removedBgPath = outputFile.path;
      debugPrint('✅ Background removed: $_removedBgPath');
    } else {
      throw Exception('remove.bg failed: ${response.statusCode}');
    }
  }

  Future<void> _generateBackground(String destinationKey) async {
    final prompt = destinationPrompts[destinationKey];
    if (prompt == null) throw Exception('Invalid destination: $destinationKey');

    final encodedPrompt = Uri.encodeComponent(prompt);
    final seed = DateTime.now().millisecondsSinceEpoch;
    final imageUrl =
        'https://image.pollinations.ai/prompt/$encodedPrompt'
        '?width=1024&height=1024&nologo=true&seed=$seed&enhance=true';

    final response = await http
        .get(Uri.parse(imageUrl))
        .timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'bg_${DateTime.now().millisecondsSinceEpoch}.png';
      final outputFile = File('${tempDir.path}/$fileName');
      await outputFile.writeAsBytes(response.bodyBytes);

      _generatedBgPath = outputFile.path;
    } else {
      throw Exception('Pollinations failed: ${response.statusCode}');
    }
  }

  Future<void> _mergeImagesWithTransform() async {
    if (_removedBgPath == null || _generatedBgPath == null) {
      throw Exception('Missing images for merge');
    }

    final userBytes = await File(_removedBgPath!).readAsBytes();
    final bgBytes = await File(_generatedBgPath!).readAsBytes();

    final userImage = img.decodeImage(userBytes)!;
    final bgImage = img.decodeImage(bgBytes)!;

    final bg = img.copyResize(bgImage, width: 1024, height: 1024);

    final baseHeight = (bg.height * _photoScale).toInt();
    final baseWidth = (userImage.width * baseHeight / userImage.height).toInt();
    final userResized = img.copyResize(userImage, width: baseWidth, height: baseHeight);

    final centerX = bg.width ~/ 2;
    final centerY = bg.height ~/ 2;
    final x = centerX + (_photoOffsetX * bg.width * 0.4).toInt() - (userResized.width ~/ 2);
    final y = centerY + (_photoOffsetY * bg.height * 0.4).toInt() - (userResized.height ~/ 2);

    img.compositeImage(bg, userResized, dstX: x, dstY: y);

    final tempDir = await getTemporaryDirectory();
    final fileName = 'final_${DateTime.now().millisecondsSinceEpoch}.png';
    final finalFile = File('${tempDir.path}/$fileName');
    await finalFile.writeAsBytes(img.encodePng(bg));

    _finalMergedPath = finalFile.path;
  }

  Future<void> remergeWithCurrentTransform() async {
    if (_removedBgPath == null || _generatedBgPath == null) return;

    _isGenerating = true;
    notifyListeners();

    try {
      await _mergeImagesWithTransform();
    } catch (e) {
      _errorMessage = 'Remerge error: $e';
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<String?> saveToDownloads() async {
    try {
      final sourcePath = _finalMergedPath;
      if (sourcePath == null) return null;

      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final fileName = 'nanobanana_${DateTime.now().millisecondsSinceEpoch}.png';
      final newPath = '${directory.path}/$fileName';
      await File(sourcePath).copy(newPath);

      return newPath;
    } catch (e) {
      debugPrint('Save error: $e');
      return null;
    }
  }

  void clearGeneratedImage() {
    _removedBgPath = null;
    _generatedBgPath = null;
    _finalMergedPath = null;
    _errorMessage = null;
    resetPhotoTransform();
    notifyListeners();
  }

  void reset() {
    _originalPhotoPath = null;
    _removedBgPath = null;
    _generatedBgPath = null;
    _finalMergedPath = null;
    _isGenerating = false;
    _errorMessage = null;
    resetPhotoTransform();
    notifyListeners();
  }
}