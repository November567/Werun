import 'package:flutter/material.dart';
import '../components/createPost/run_route_card.dart';
import '../components/createPost/media_section.dart';
import '../components/createPost/tags_section.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  String selectedPrivacy = 'public'; // 'public', 'followers', 'private'
  bool shareToSuggested = false;
  String description = '';
  List<String> tags = ['Khon Kaen', 'Night Run'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
        title: const Text(
          'Create New Post',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post created successfully!')),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Text(
                  'Share',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              // Run Route Info
              RunRouteCard(),
              const SizedBox(height: 20),

              // Media Section (รวม Add Media + Image Overlay)
              MediaSection(),
              const SizedBox(height: 20),

              // Tags & Description Section (รวม Privacy ด้วย)
              TagsSection(
                tags: tags,
                onTagsChanged: (newTags) {
                  setState(() {
                    tags = newTags;
                  });
                },
                description: description,
                onDescriptionChanged: (newDescription) {
                  setState(() {
                    description = newDescription;
                  });
                },
                selectedPrivacy: selectedPrivacy,
                onPrivacyChanged: (value) {
                  setState(() {
                    selectedPrivacy = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Privacy Section - ลบออกแล้ว (รวมเข้า TagsSection)
              // PrivacySection(...)

              // Share to Suggested Checkbox + Share Button (Same row)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2a2a2a),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Checkbox(
                      value: shareToSuggested,
                      onChanged: (value) {
                        setState(() {
                          shareToSuggested = value ?? false;
                        });
                      },
                      fillColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.green;
                        }
                        return Colors.grey[700];
                      }),
                      side: BorderSide(color: Colors.grey[600]!),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Also Share to Suggested Places?',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Post created successfully!')),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: const Text(
                          'Share',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}