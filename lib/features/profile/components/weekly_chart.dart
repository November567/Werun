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
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      setState(() {
        data.removeAt(0);
        data.add(random.nextDouble() * 6); // 0-6 km
      });

      _controller.forward(from: 0); // เล่น animation ใหม่
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  double get maxValue {
    final m = data.reduce(max);
    return m == 0 ? 1 : m;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "This week",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _StreamingChartPainter(
                    data: data,
                    progress: _controller.value,
                    maxValue: maxValue,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////

class _StreamingChartPainter extends CustomPainter {
  final List<double> data;
  final double progress;
  final double maxValue;

  _StreamingChartPainter({
    required this.data,
    required this.progress,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final widthPerItem = size.width / (data.length - 1);

    /// GRID LINES
    final gridPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;

    for (int i = 0; i < data.length; i++) {
      final x = i * widthPerItem;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    /// LINE PAINT (เขียวเรืองแสง)
    final linePaint = Paint()
      ..color = const Color(0xFF00FF5F)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    for (int i = 0; i < data.length; i++) {
      final x = i * widthPerItem;

      final animatedValue = i == data.length - 1 ? data[i] * progress : data[i];

      final y = size.height - ((animatedValue / maxValue) * size.height * 0.8);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    /// DOTS
    for (int i = 0; i < data.length; i++) {
      final x = i * widthPerItem;
      final y = size.height - ((data[i] / maxValue) * size.height * 0.8);

      final isLast = i == data.length - 1;

      final dotPaint = Paint()..color = const Color(0xFF00FF5F);

      canvas.drawCircle(Offset(x, y), isLast ? 6 : 4, dotPaint);
    }

    /// 0 km top right
    final textPainter = TextPainter(
      text: const TextSpan(
        text: "0 km",
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(size.width - textPainter.width, 0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
