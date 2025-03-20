import 'package:flutter/material.dart';
import 'dart:math';

class AppIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [
          Colors.pink[300]!,
          Colors.pink[400]!,
          Colors.pink[500]!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw main circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    // Draw multiplication symbol
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw "×" symbol
    final textPainter = TextPainter(
      text: TextSpan(
        text: '×',
        style: TextStyle(
          color: Colors.white,
          fontSize: size.width * 0.6,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.width / 2 - textPainter.width / 2,
        size.height / 2 - textPainter.height / 2,
      ),
    );

    // Draw small circles around
    final smallCircleRadius = size.width * 0.1;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.35;

    for (var i = 0; i < 6; i++) {
      final angle = i * (2 * pi / 6);
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      canvas.drawCircle(
        Offset(x, y),
        smallCircleRadius,
        whitePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AppIcon extends StatelessWidget {
  final double size;

  const AppIcon({super.key, this.size = 192});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(
        painter: AppIconPainter(),
        size: Size(size, size),
      ),
    );
  }
}
