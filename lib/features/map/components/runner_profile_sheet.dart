import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/run_stat_chip.dart';
import '../../../shared/widgets/bottom_sheet_container.dart';

class RunnerProfile {
  final String id;
  final String name;
  final String avatarUrl;
  final String pace;
  final String distance;
  final String time;
  final int totalRuns;

  const RunnerProfile({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.pace,
    required this.distance,
    required this.time,
    required this.totalRuns,
  });
}

const runnerProfiles = {
  'runner_1': RunnerProfile(
    id: 'runner_1',
    name: 'Alex',
    avatarUrl: 'https://i.pravatar.cc/150?img=11',
    pace: "5'12\" /km",
    distance: '3.2 km',
    time: '16:38',
    totalRuns: 42,
  ),
  'runner_2': RunnerProfile(
    id: 'runner_2',
    name: 'Sam',
    avatarUrl: 'https://i.pravatar.cc/150?img=32',
    pace: "6'04\" /km",
    distance: '2.8 km',
    time: '17:00',
    totalRuns: 28,
  ),
  'runner_3': RunnerProfile(
    id: 'runner_3',
    name: 'Mia',
    avatarUrl: 'https://i.pravatar.cc/150?img=47',
    pace: "4'55\" /km",
    distance: '3.5 km',
    time: '17:13',
    totalRuns: 67,
  ),
  'runner_4': RunnerProfile(
    id: 'runner_4',
    name: 'Tom',
    avatarUrl: 'https://i.pravatar.cc/150?img=60',
    pace: "5'30\" /km",
    distance: '3.0 km',
    time: '16:30',
    totalRuns: 15,
  ),
};

class RunnerProfileSheet extends StatelessWidget {
  final RunnerProfile runner;

  const RunnerProfileSheet({super.key, required this.runner});

  static void show(BuildContext context, String runnerId) {
    final profile = runnerProfiles[runnerId];
    if (profile == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => RunnerProfileSheet(runner: profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar + name
          Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: AppColors.accent, width: 2),
                  ),
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundImage: NetworkImage(runner.avatarUrl),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    runner.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.circle, color: AppColors.accent, size: 10),
                      SizedBox(width: 6),
                      Text(
                        'Running now',
                        style: TextStyle(color: AppColors.accent, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Today's run stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Run",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RunStatChip(label: 'Distance', value: runner.distance),
                    RunStatChip(label: 'Time', value: runner.time),
                    RunStatChip(label: 'Pace', value: runner.pace),
                    RunStatChip(
                        label: 'Total Runs', value: '${runner.totalRuns}'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
