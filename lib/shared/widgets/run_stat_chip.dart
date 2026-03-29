import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Reusable stat display used in run stats rows.
/// Replaces the private _StatChip / _StatBox / _StatItem widgets
/// that were duplicated across post_run_sheet, run_tracking_screen,
/// and runner_profile_sheet.
class RunStatChip extends StatelessWidget {
  final String label;
  final String value;

  const RunStatChip({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}
