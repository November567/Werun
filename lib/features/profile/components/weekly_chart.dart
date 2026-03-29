import 'package:flutter/material.dart';

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({super.key});

  @override
  Widget build(BuildContext context) {
    final heights = [0.4, 0.65, 0.9, 0.3, 0.75, 0.5, 0.45];
    final days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 🔹 Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Weekly Performance",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "LAST 7 DAYS",
                style: TextStyle(color: Colors.cyan, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 🔹 Chart Bars
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(heights.length, (index) {
                final h = heights[index];

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 120 * h,
                    decoration: BoxDecoration(
                      color: index == 2
                          ? Colors
                                .lime // WED
                          : index == 4
                          ? Colors
                                .cyan // FRI
                          : Colors.grey[800],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                      boxShadow: index == 2
                          ? [
                              BoxShadow(
                                color: Colors.lime.withValues(alpha: 0.4),
                                blurRadius: 10,
                              ),
                            ]
                          : [],
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 10),

          // 🔹 Days Label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(days.length, (index) {
              return Expanded(
                child: Center(
                  child: Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: index == 2 ? Colors.lime : Colors.grey,
                      fontWeight: index == 2
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////
/// 🔻 RECENT RUNS
//////////////////////////////////////////////////////////

class RecentRuns extends StatelessWidget {
  const RecentRuns({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        // 🔹 Header
        Text(
          "Recent Runs",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        SizedBox(height: 12),

        RunCard(
          title: "Midnight Sprint",
          subtitle: "Yesterday • 12.4 km",
          time: "52:14",
        ),

        SizedBox(height: 10),

        RunCard(
          title: "Morning Recovery",
          subtitle: "Oct 12 • 5.2 km",
          time: "28:40",
        ),
      ],
    );
  }
}

//////////////////////////////////////////////////////////
/// 🔻 RUN CARD
//////////////////////////////////////////////////////////

class RunCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;

  const RunCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 🔹 Image Placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.map, color: Colors.grey),
          ),

          const SizedBox(width: 12),

          // 🔹 Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // 🔹 Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  color: Colors.lime,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Total Time",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
