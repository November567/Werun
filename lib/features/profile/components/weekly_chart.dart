import 'package:flutter/material.dart';

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          24,
          (index) => Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(width: 2, height: 60, color: Colors.grey.shade700),
                const SizedBox(height: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: index == 23
                        ? Colors.greenAccent
                        : Colors.greenAccent.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
