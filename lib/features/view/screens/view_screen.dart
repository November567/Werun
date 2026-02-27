import 'package:flutter/material.dart';
import '../components/view_grid_item.dart';

class ViewScreen extends StatefulWidget {
  const ViewScreen({super.key});

  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _allItems = [
    {"title": "girl portrait", "url": "https://picsum.photos/400?1"},
    {"title": "cat cute", "url": "https://picsum.photos/400?2"},
    {"title": "car luxury", "url": "https://picsum.photos/400?3"},
    {"title": "mountain view", "url": "https://picsum.photos/400?4"},
    {"title": "dog puppy", "url": "https://picsum.photos/400?5"},
    {"title": "anime art", "url": "https://picsum.photos/400?6"},
    {"title": "city night", "url": "https://picsum.photos/400?7"},
    {"title": "food sushi", "url": "https://picsum.photos/400?8"},
    {"title": "travel beach", "url": "https://picsum.photos/400?9"},
    {"title": "fashion model", "url": "https://picsum.photos/400?10"},
    {"title": "fitness gym", "url": "https://picsum.photos/400?11"},
    {"title": "sunset sky", "url": "https://picsum.photos/400?12"},
  ];

  List<Map<String, String>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = _allItems;

    _searchController.addListener(() {
      _filterSearch(_searchController.text);
    });
  }

  void _filterSearch(String query) {
    final results = _allItems.where((item) {
      final title = item["title"]!.toLowerCase();
      return title.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredItems = results;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 SEARCH BAR
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "ค้นหา",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // 🟩 GRID
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _filteredItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return ViewGridItem(imageUrl: _filteredItems[index]["url"]!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
