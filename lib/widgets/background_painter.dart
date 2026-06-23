// ─────────────────────────────────────────
//  GEOMETRIC BACKGROUND PAINTER
// ─────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:tanqiy/core/colors.dart';

class GeomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // octagonal Islamic pattern
    for (double x = -40; x < size.width + 40; x += 60) {
      for (double y = -40; y < size.height + 40; y += 60) {
        final r = 22.0;
        final path = Path();
        for (int i = 0; i < 8; i++) {
          final angle = (i * 45 - 22.5) * 3.14159 / 180;
          final px =
              x +
              r *
                  1.3 *
                  (i == 0
                      ? 1
                      : (i < 5
                            ? (i % 2 == 0 ? 1 : -1)
                            : (i % 2 == 0 ? 1 : -1)));
          final py =
              y +
              r *
                  (i == 0
                      ? 1
                      : (i < 5
                            ? (i % 2 == 0 ? -1 : 1)
                            : (i % 2 == 0 ? -1 : 1)));
          if (i == 0) path.moveTo(x + r * 0.7, y - r);
          path.lineTo(x + r * _cos(i * 45), y + r * _sin(i * 45));
        }
        path.close();
        canvas.drawPath(path, paint);

        // simple diamond
        final d = Paint()
          ..color = AppColors.gold.withOpacity(0.04)
          ..style = PaintingStyle.fill;
        final dp = Path()
          ..moveTo(x, y - 16)
          ..lineTo(x + 16, y)
          ..lineTo(x, y + 16)
          ..lineTo(x - 16, y)
          ..close();
        canvas.drawPath(dp, d);
      }
    }
  }

  double _cos(int deg) => (deg == 0)
      ? 1
      : (deg == 45)
      ? 0.707
      : (deg == 90)
      ? 0
      : (deg == 135)
      ? -0.707
      : (deg == 180)
      ? -1
      : (deg == 225)
      ? -0.707
      : (deg == 270)
      ? 0
      : 0.707;
  double _sin(int deg) => (deg == 0)
      ? 0
      : (deg == 45)
      ? 0.707
      : (deg == 90)
      ? 1
      : (deg == 135)
      ? 0.707
      : (deg == 180)
      ? 0
      : (deg == 225)
      ? -0.707
      : (deg == 270)
      ? -1
      : -0.707;

  @override
  bool shouldRepaint(_) => false;
}