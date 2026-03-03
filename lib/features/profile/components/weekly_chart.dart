import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class WeeklyChart extends StatefulWidget {
  const WeeklyChart({super.key});

  @override
  State<WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<WeeklyChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final int maxPoints = 20;
  final List<double> data = List.generate(20, (_) => 0);
  Timer? _timer;
  final Random random = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _startStreaming();
  }

  void _startStreaming() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        data.removeAt(0);
        data.add(random.nextDouble() * 100); // 0-100 km
      });

      _controller.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  double get maxValue {
    return 100; // Fixed max value for consistency
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Activity in Dec",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Y-axis labels
                    SizedBox(
                      width: 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "100 km",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                          const Text(
                            "50 km",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                          const Text(
                            "0 km",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Chart
                    Expanded(
                      child: CustomPaint(
                        painter: _BarChartPainter(
                          data: data,
                          progress: _controller.value,
                          maxValue: maxValue,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "Dec",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> data;
  final double progress;
  final double maxValue;

  _BarChartPainter({
    required this.data,
    required this.progress,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid lines (horizontal)
    final gridPaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1;

    // 100 km line
    canvas.drawLine(
      Offset(0, 0),
      Offset(size.width, 0),
      gridPaint,
    );

    // 50 km line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      gridPaint,
    );

    // Draw vertical grid lines between bars
    final barWidth = size.width / data.length;
    final gridLinePaint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 0.5;

    for (int i = 0; i <= data.length; i++) {
      final x = i * barWidth;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridLinePaint,
      );
    }

    // Draw bars
    final barPaint = Paint()
      ..color = const Color(0xFF00FF5F)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = i * barWidth + barWidth * 0.2;
      final barWidthActual = barWidth * 0.6;

      final animatedValue =
          i == data.length - 1 ? data[i] * progress : data[i];
      final height = (animatedValue / maxValue) * size.height;

      final rect = Rect.fromLTWH(
        x,
        size.height - height,
        barWidthActual,
        height,
      );

      canvas.drawRect(rect, barPaint);

      // Draw dots at the top of each bar
      final dotPaint = Paint()
        ..color = const Color(0xFF00FF5F)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x + barWidthActual / 2, size.height - height),
        4,
        dotPaint,
      );
    }

    // Draw right label "0 km"
    final textPainter = TextPainter(
      text: const TextSpan(
        text: "0 km",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 11,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(size.width + 8, size.height - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}