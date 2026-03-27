import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class MediaSection extends StatefulWidget {
  final ValueChanged<String?>? onImageChanged;

  const MediaSection({Key? key, this.onImageChanged}) : super(key: key);

  @override
  State<MediaSection> createState() => _MediaSectionState();
}

class _MediaSectionState extends State<MediaSection> {
  List<String> uploadedImageUrls = [];
  int selectedImageIndex = 0;
  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;

  String? get _currentImageUrl =>
      uploadedImageUrls.isEmpty ? null : uploadedImageUrls[selectedImageIndex];

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1080,
      );
      if (file == null) return;

      setState(() => _uploading = true);

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('post_images/$fileName');

      final uploadTask = storageRef.putFile(
        File(file.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // ✅ แก้ไข: รับ snapshot แล้วดึง URL จาก snapshot.ref
      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();

      setState(() {
        uploadedImageUrls.add(url);
        selectedImageIndex = uploadedImageUrls.length - 1;
        _uploading = false;
      });

      widget.onImageChanged?.call(url);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ อัปโหลดรูปสำเร็จ'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _uploading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ อัปโหลดไม่สำเร็จ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('เลือกจากแกลเลอรี่',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title:
                  const Text('ถ่ายรูป', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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
          // Header
          const Text(
            'Add Media',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),

          // Main image preview + buttons
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: _showPickerSheet,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[800],
                        border: Border.all(
                          color: _currentImageUrl != null
                              ? Colors.green
                              : Colors.grey[700]!,
                          width: 1.5,
                        ),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: _currentImageUrl != null
                          ? Image.network(
                              _currentImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.broken_image,
                                color: Colors.grey[600],
                                size: 48,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    color: Colors.grey[500], size: 36),
                                const SizedBox(height: 6),
                                Text('เพิ่มรูป',
                                    style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 11)),
                              ],
                            ),
                    ),
                  ),
                  // ปุ่ม + / loading
                  Positioned(
                    top: 45,
                    left: 45,
                    child: GestureDetector(
                      onTap: _uploading ? null : _showPickerSheet,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4)
                          ],
                        ),
                        padding: const EdgeInsets.all(6),
                        child: _uploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : Icon(
                                _currentImageUrl != null
                                    ? Icons.edit
                                    : Icons.add,
                                color: Colors.black,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),

              // Media option buttons
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMediaOption(
                      icon: Icons.camera_alt,
                      label: 'Take Photo',
                      onTap: () => _pickAndUploadImage(ImageSource.camera),
                    ),
                    _buildMediaOption(
                      icon: Icons.image,
                      label: 'Gallery',
                      onTap: () => _pickAndUploadImage(ImageSource.gallery),
                    ),
                    _buildMediaOption(
                      icon: Icons.videocam,
                      label: 'Short Video',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Short video not yet implemented')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // แสดง thumbnail list เฉพาะเมื่อมีรูปที่อัปโหลดแล้ว
          if (uploadedImageUrls.isNotEmpty) ...[
            const SizedBox(height: 20),
            Divider(color: Colors.grey[800], height: 1),
            const SizedBox(height: 16),
            const Text(
              'รูปที่เพิ่ม',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: uploadedImageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final isSelected = selectedImageIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedImageIndex = index);
                      widget.onImageChanged
                          ?.call(uploadedImageUrls[index]);
                    },
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Colors.green
                              : Colors.grey[700]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Image.network(
                        uploadedImageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                            Icons.broken_image,
                            color: Colors.grey[600]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
      onTap: _uploading ? null : onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: _uploading ? Colors.grey[800] : Colors.grey[700],
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon,
                color: _uploading ? Colors.grey[600] : Colors.white,
                size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: _uploading ? Colors.grey[600] : Colors.white,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}