import 'package:flutter/material.dart';

/// Reusable stat display used in run stats rows.
/// Replaces the private _StatChip / _StatBox / _StatItem pattern.
class RunStatChip extends StatelessWidget {
  final String label;
  final String value;

  const RunStatChip({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
