import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class FitScoreGauge extends StatelessWidget {
  final int score; // 0-100
  final double size;
  final double strokeWidth;
  final bool showLabel;
  final String? label;

  const FitScoreGauge({
    super.key,
    required this.score,
    this.size = 80,
    this.strokeWidth = 8,
    this.showLabel = false,
    this.label,
  });

  Color get scoreColor {
    if (score >= 80) return AppColors.accent;
    if (score >= 60) return AppColors.primary;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = label;
    final hasLabel = showLabel && effectiveLabel != null && effectiveLabel.isNotEmpty;
    final clampedScore = score.clamp(0, 100);
    final innerDiameter = (size - strokeWidth * 2).clamp(10.0, size);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle inner background tint
          Container(
            width: innerDiameter,
            height: innerDiameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scoreColor.withValues(alpha: 0.04),
            ),
          ),

          // Custom Painted Arc with smooth animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: clampedScore / 100.0),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return CustomPaint(
                size: Size(size, size),
                painter: _GaugePainter(
                  progress: val,
                  progressColor: scoreColor,
                  trackColor: AppColors.border,
                  strokeWidth: strokeWidth,
                ),
              );
            },
          ),

          // Perfectly proportioned center text with guaranteed bounds
          Center(
            child: SizedBox(
              width: innerDiameter * 0.74,
              height: innerDiameter * 0.74,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$clampedScore',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: scoreColor,
                            height: 1.0,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 1.0, left: 1.0),
                          child: Text(
                            '%',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: scoreColor.withValues(alpha: 0.8),
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (hasLabel) ...[
                      const SizedBox(height: 2),
                      Text(
                        effectiveLabel,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: AppColors.textSecondary,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress; // 0.0 - 1.0
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  _GaugePainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Draw background full track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Draw progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -pi / 2;
      final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
