import 'package:flutter/material.dart';

class TagsSection extends StatefulWidget {
  final List<String> tags;
  final Function(List<String>) onTagsChanged;
  final String description;
  final Function(String) onDescriptionChanged;
  final String selectedPrivacy;
  final Function(String) onPrivacyChanged;

  const TagsSection({
    Key? key,
    required this.tags,
    required this.onTagsChanged,
    required this.description,
    required this.onDescriptionChanged,
    required this.selectedPrivacy,
    required this.onPrivacyChanged,
  }) : super(key: key);

  @override
  State<TagsSection> createState() => _TagsSectionState();
}

class _TagsSectionState extends State<TagsSection> {
  late TextEditingController _tagController;
  String newTag = '';
  bool _shareDescription = false;

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController();
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  void _removeTag(String tag) {
    widget.onTagsChanged(
      widget.tags.where((t) => t != tag).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description TextField - พิมพ์ได้
          TextField(
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'แบ่งความรู้สึกเกี่ยวกับรอบนี้...',
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(0),
            ),
            maxLines: 1,
            onChanged: (value) {
              widget.onDescriptionChanged(value);
            },
          ),
          const SizedBox(height: 16),

          // Tags Row + Toggle Switch
          Row(
            children: [
              const Text(
                'Tags',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...widget.tags.map((tag) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tag,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => _removeTag(tag),
                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Toggle Switch - เล็กลง
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: _shareDescription,
                  onChanged: (value) {
                    setState(() {
                      _shareDescription = value;
                    });
                  },
                  activeColor: Colors.white,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Privacy Section
          const Text(
            'Set Privacy',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),

          // Privacy Options - Horizontal
          Row(
            children: [
              _buildPrivacyOption('Public', 'public'),
              const SizedBox(width: 12),
              _buildPrivacyOption('Followers', 'followers'),
              const SizedBox(width: 12),
              _buildPrivacyOption('Private', 'private'),
            ],
          ),
          const SizedBox(height: 16),

          // Location Info
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'อุทยานสวนเกษตร มข.',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyOption(String label, String value) {
    bool isSelected = widget.selectedPrivacy == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onPrivacyChanged(value),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.transparent : Colors.grey[800],
            border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}