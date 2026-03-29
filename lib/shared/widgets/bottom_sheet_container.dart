import 'package:flutter/material.dart';

/// Standard dark bottom sheet wrapper used across the app.
/// Provides rounded top corners, themed surface background, and drag handle.
class BottomSheetContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const BottomSheetContainer({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final surface = Theme.of(context).colorScheme.surface;

    return Container(
      padding: padding ??
          EdgeInsets.only(left: 24, right: 24, top: 24, bottom: bottom + 24),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
