import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class MediaSection extends StatefulWidget {
  final ValueChanged<String>? onImageChanged;

  const MediaSection({Key? key, this.onImageChanged}) : super(key: key);

  @override
  State<MediaSection> createState() => _MediaSectionState();
}

class _MediaSectionState extends State<MediaSection> {
  List<String> images = [
    'https://www.kku.ac.th/wp-content/uploads/2023/12/IMG_0832-scaled.jpg',
    'https://www.kku.ac.th/wp-content/uploads/2023/12/IMG_0832-scaled.jpg',
  ];
  
  String selectedOverlay = 'map'; // 'map' or 'stats'
  int selectedImageIndex = 0;
  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(source: source, imageQuality: 80);
      if (file == null) return;

      setState(() {
        _uploading = true;
      });

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('post_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      await storageRef.putFile(File(file.path));
      final url = await storageRef.getDownloadURL();

      setState(() {
        images.add(url);
        selectedImageIndex = images.length - 1;
        _uploading = false;
      });
      
      widget.onImageChanged?.call(url);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Image uploaded successfully')),
      );
    } catch (e) {
      setState(() {
        _uploading = false;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Media Header
          const Text(
            'Add Media',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),

          // Row: Selected Image + Media Options
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Selected Image with + Button
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[800],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Image.network(
                      images[selectedImageIndex],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.image, color: Colors.grey[600], size: 48);
                      },
                    ),
                  ),
                  // Plus Button - กลางรูป
                  Positioned(
                    top: 50,
                    left: 50,
                    child: GestureDetector(
                      onTap: () {
                        _pickAndUploadImage(ImageSource.gallery);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: _uploading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(
                                Icons.add,
                                color: Colors.black,
                                size: 24,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),

              // Media Options (Horizontal - Centered)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMediaOption(
                          icon: Icons.camera_alt,
                          label: 'Take Photo',
                          onTap: () {
                            _pickAndUploadImage(ImageSource.camera);
                          },
                        ),
                        _buildMediaOption(
                          icon: Icons.image,
                          label: 'Gallery',
                          onTap: () {
                            _pickAndUploadImage(ImageSource.gallery);
                          },
                        ),
                        _buildMediaOption(
                          icon: Icons.videocam,
                          label: 'Short Video',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Short video not yet implemented')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Divider
          Divider(color: Colors.grey[800], height: 1),
          const SizedBox(height: 16),

          // Image Overlay Section
          Row(
            children: [
              Text(
                'Image Overlay',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                selectedOverlay == 'map' ? 'Map Overlay' : 'Stats Overlay',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Radio Button Options
          Row(
            children: [
              // Map Overlay Option
              GestureDetector(
                onTap: () => setState(() {
                  selectedOverlay = 'map';
                  selectedImageIndex = 0;
                }),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedOverlay == 'map' ? Colors.green : Colors.grey[700]!,
                          width: 2,
                        ),
                      ),
                      child: selectedOverlay == 'map'
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Map Overlay',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),

              // Stats Overlay Option
              GestureDetector(
                onTap: () => setState(() {
                  selectedOverlay = 'stats';
                  selectedImageIndex = 1;
                }),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedOverlay == 'stats' ? Colors.green : Colors.grey[700]!,
                          width: 2,
                        ),
                      ),
                      child: selectedOverlay == 'stats'
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Stats Overlay',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Image Preview Horizontal Scroll
          SizedBox(
            height: 100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  images.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(right: index < images.length - 1 ? 12 : 0),
                    child: _buildImagePreview(
                      images[index],
                      'Image ${index + 1}',
                      isSelected: selectedImageIndex == index,
                      onTap: () {
                        setState(() {
                          selectedImageIndex = index;
                          if (index == 0) {
                            selectedOverlay = 'map';
                          } else {
                            selectedOverlay = 'stats';
                          }
                        });
                        widget.onImageChanged?.call(images[index]);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[700],
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(
    String imageUrl,
    String label, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey[700]!,
            width: isSelected ? 2 : 1,
          ),
          color: Colors.grey[800],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.image, color: Colors.grey[600], size: 32);
              },
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}