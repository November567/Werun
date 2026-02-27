import 'package:flutter/material.dart';
import 'dart:math';

class WeeklyChart extends StatefulWidget {
  final List<double> weeklyKm;

  const WeeklyChart({super.key, this.weeklyKm = const [2, 5, 0, 7, 4, 6, 3]});

  @override
  State<WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<WeeklyChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  double get maxKm {
    final m = widget.weeklyKm.reduce(max);
    return m == 0 ? 1 : m;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _ChartPainter(
              data: widget.weeklyKm,
              progress: _animation.value,
              maxKm: maxKm,
            ),
          );
        },
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// CHART PAINTER
////////////////////////////////////////////////////////////

class _ChartPainter extends CustomPainter {
  final List<double> data;
  final double progress;
  final double maxKm;

  _ChartPainter({
    required this.data,
    required this.progress,
    required this.maxKm,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double widthPerItem = size.width / (data.length - 1);

    /// Gradient Line
    final linePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00FF94), Color(0xFF00C853)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    /// Gradient Fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF00FF94).withValues(alpha: 0.35),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = i * widthPerItem;
      final y =
          size.height - ((data[i] / maxKm) * size.height * 0.75 * progress);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    /// Draw dots + km text
    final dotPaint = Paint()..color = const Color(0xFF00FF94);

    for (int i = 0; i < data.length; i++) {
      final x = i * widthPerItem;
      final y =
          size.height - ((data[i] / maxKm) * size.height * 0.75 * progress);

      canvas.drawCircle(Offset(x, y), 4, dotPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: "${data[i].toInt()} km",
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, Offset(x - 16, y - 22));
    }

    /// Draw Y-axis labels (0 km และ max km)
    final labelPainterTop = TextPainter(
      text: TextSpan(
        text: "${maxKm.toInt()} km",
        style: const TextStyle(color: Colors.white38, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    labelPainterTop.paint(canvas, const Offset(0, 0));

    final labelPainterBottom = TextPainter(
      text: const TextSpan(
        text: "0 km",
        style: TextStyle(color: Colors.white38, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    labelPainterBottom.paint(canvas, Offset(0, size.height - 14));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
