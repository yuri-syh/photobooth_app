import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Color selectedBackgroundColor = Colors.black;

  final List<Color> backgroundColors = [
    Colors.black,
    const Color(0xFFF3E3FE),
    const Color(0xFFE94B77),
    const Color(0xFFC290E4),
    const Color(0xFFFFD1DF),
    Colors.white,
    Colors.blueGrey,
    Colors.indigoAccent,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FF),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Preview Area
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: selectedBackgroundColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.photo_library_outlined, color: Colors.white38, size: 60),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Editor Panel
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                border: Border.all(color: const Color(0xFFFFD1DF), width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFFE94B77),
                    unselectedLabelColor: Colors.black26,
                    indicatorColor: const Color(0xFFE94B77),
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    tabs: const [
                      Tab(text: "FILTERS"),
                      Tab(text: "BACKGROUNDS"),
                      Tab(text: "FRAMES"),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    height: 100,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Filters Placeholder
                        const Center(child: Text("Filters coming soon!")),
                        // Background Colors Selection
                        ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: backgroundColors.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 15),
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedBackgroundColor = backgroundColors[index];
                              });
                            },
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: backgroundColors[index],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedBackgroundColor == backgroundColors[index]
                                      ? const Color(0xFFE94B77)
                                      : Colors.grey.withOpacity(0.3),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: selectedBackgroundColor == backgroundColors[index]
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          ),
                        ),
                        // Frames Placeholder
                        const Center(child: Text("Frames coming soon!")),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),

                  // Centered Download PNG Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE94B77),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Download", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text("PNG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(width: 15),
                          Icon(Icons.file_download_outlined, size: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
