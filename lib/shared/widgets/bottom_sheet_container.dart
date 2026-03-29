import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Standard dark bottom sheet wrapper used across the app.
/// Provides the rounded top corners, dark background, and drag handle.
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
    return Container(
      padding: padding ??
          EdgeInsets.only(left: 24, right: 24, top: 24, bottom: bottom + 24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
