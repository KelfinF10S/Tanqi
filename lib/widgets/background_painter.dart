// ─────────────────────────────────────────
//  GEOMETRIC BACKGROUND PAINTER
// ─────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:tanqiy/core/colors.dart';

class GeomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke =
        Paint()
          ..color = AppColors.gold.withOpacity(0.06)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    final fill =
        Paint()
          ..color = AppColors.gold.withOpacity(0.04)
          ..style = PaintingStyle.fill;

    for (double x = -40; x < size.width + 40; x += 60) {
      for (double y = -40; y < size.height + 40; y += 60) {
        const r = 22.0;

        final path = Path();

        for (int i = 0; i < 8; i++) {
          final px = x + r * _cos(i * 45);
          final py = y + r * _sin(i * 45);

          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }

        path.close();

        canvas.drawPath(path, stroke);

        final diamond =
            Path()
              ..moveTo(x, y - 16)
              ..lineTo(x + 16, y)
              ..lineTo(x, y + 16)
              ..lineTo(x - 16, y)
              ..close();

        canvas.drawPath(diamond, fill);
      }
    }
  }

  double _cos(int deg) => switch (deg) {
    0 => 1,
    45 => 0.707,
    90 => 0,
    135 => -0.707,
    180 => -1,
    225 => -0.707,
    270 => 0,
    _ => 0.707,
  };

  double _sin(int deg) => switch (deg) {
    0 => 0,
    45 => 0.707,
    90 => 1,
    135 => 0.707,
    180 => 0,
    225 => -0.707,
    270 => -1,
    _ => -0.707,
  };

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}