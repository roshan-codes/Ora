import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class WavyDial extends StatelessWidget {
  final double size;

  const WavyDial({
    super.key,
    this.size = 230,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _WavyDialPainter(),
          ),
          // Center content
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1h 15m',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Remaining',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
              SizedBox(height: 14),
              Text(
                '1 hrs',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'To complete drying',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WavyDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = (size.width / 2) - 16;

    // Angles for the wavy arc (approx 7:30 to 12:45)
    // 0 is 3 o'clock, 0.5*pi is 6 o'clock, pi is 9 o'clock, 1.5*pi is 12 o'clock
    const startAngle = 2.30; // ~7:30 position
    const endAngle = 5.00; // ~12:45 position

    // 1. Draw the smooth white track on the right/bottom
    final whiteTrackPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    final whiteShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Span for the white track: from endAngle to startAngle (clockwise)
    const whiteArcStart = endAngle + 0.14;
    const whiteArcSweep = (2 * math.pi + startAngle - 0.14) - whiteArcStart;

    final rect = Rect.fromCircle(center: center, radius: baseRadius);
    canvas.drawArc(rect, whiteArcStart, whiteArcSweep, false, whiteShadowPaint);
    canvas.drawArc(rect, whiteArcStart, whiteArcSweep, false, whiteTrackPaint);

    // 2. Draw the wavy orange line
    final orangePaint = Paint()
      ..color = AppColors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final orangePath = Path();
    const steps = 140;
    const waveCycles = 8.0;
    const waveAmplitude = 5.5;

    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final angle = startAngle + t * (endAngle - startAngle);
      // Sinusoidal displacement from base radius
      final r = baseRadius + waveAmplitude * math.sin(t * waveCycles * 2 * math.pi);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        orangePath.moveTo(x, y);
      } else {
        orangePath.lineTo(x, y);
      }
    }

    canvas.drawPath(orangePath, orangePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
