import 'package:flutter/material.dart';
import 'detection_result.dart';

class DamagePainter extends CustomPainter {
  final List<DetectionResult> results;
  DamagePainter(this.results);  

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 2;

    final crossPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 3.0;

    double lineLength = 40;

    canvas.drawLine(
      Offset(centerX - lineLength, centerY),
      Offset(centerX + lineLength, centerY),
      crossPaint,
    );

    canvas.drawLine(
      Offset(centerX, centerY - lineLength),
      Offset(centerX, centerY + lineLength),
      crossPaint,
    );

    for (var res in results) {
      final boxPaint = Paint()
        ..color = getDamageColor(res.label)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      double left = res.box.left * size.width;
      double top = res.box.top * size.height;
      double width = res.box.width * size.width;
      double height = res.box.height * size.height;

      final rect = Rect.fromLTWH(left, top, width, height);

      canvas.drawRect(rect, boxPaint);

      final textSpan = TextSpan(
        text: "${res.label} ${(res.score * 100).toStringAsFixed(0)}%",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          backgroundColor: Colors.black54,
          shadows: [
            Shadow(
              blurRadius: 4,
              color: Colors.black,
              offset: Offset(2, 2),
            ),
          ],
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(left, top - textPainter.height - 4),
      );
    }

    final centerTextSpan = const TextSpan(
      text: "Searching for Road Damage...",
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        backgroundColor: Colors.black54,
        shadows: [
          Shadow(
            blurRadius: 6,
            color: Colors.black,
            offset: Offset(2, 2),
          ),
        ],
      ),
    );

    final centerTextPainter = TextPainter(
      text: centerTextSpan,
      textDirection: TextDirection.ltr,
    );

    centerTextPainter.layout();

    centerTextPainter.paint(
      canvas,
      Offset(
        centerX - centerTextPainter.width / 2,
        centerY + 30,
      ),
    );
  }

  Color getDamageColor(String label) {
    if (label.contains("D40")) {
      return Colors.redAccent;
    } else if (label.contains("D00")) {
      return Colors.yellowAccent;
    } else {
      return Colors.greenAccent;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}