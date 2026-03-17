// lib/widgets/frame_painter.dart
import 'dart:math';
import 'package:flutter/material.dart';

class FramePainter extends CustomPainter {
  final String frameName;
  FramePainter(this.frameName);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 4;

    switch (frameName) {
      case 'กรอบดาวทอง ⭐':
        _drawStarFrame(canvas, size, cx, cy, r);
        break;
      case 'กรอบแมว 🐱':
        _drawCatFrame(canvas, size, cx, cy, r);
        break;
      case 'กรอบไฟฟ้า ⚡':
        _drawElectricFrame(canvas, size, cx, cy, r);
        break;
      case 'กรอบเพชร 💎✨':
        _drawDiamondFrame(canvas, size, cx, cy, r);
        break;
      case 'กรอบไฟ 🔥':
        _drawFireFrame(canvas, size, cx, cy, r);
        break;
      case 'กรอบเปลวสี 🌈':
        _drawRainbowFrame(canvas, size, cx, cy, r);
        break;
      default:
        _drawDefaultFrame(canvas, size, cx, cy, r);
    }
  }

  // ── กรอบเริ่มต้น (สีจากชื่อ) ──
  void _drawDefaultFrame(Canvas c, Size s, double cx, double cy, double r) {
    final paint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;
    c.drawCircle(Offset(cx, cy), r, paint);
  }

  // ── กรอบดาวทอง ⭐ ──
  void _drawStarFrame(Canvas c, Size s, double cx, double cy, double r) {
    // วงกลมทอง
    final ring = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.amber.shade300,
          Colors.yellow.shade600,
          Colors.amber.shade700,
          Colors.yellow.shade300,
          Colors.amber.shade300,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    c.drawCircle(Offset(cx, cy), r, ring);

    // ดาวรอบวง
    final starPaint = Paint()..color = Colors.amber.shade600;
    final count = 12;
    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi;
      final sx = cx + (r + 2) * cos(angle);
      final sy = cy + (r + 2) * sin(angle);
      _drawStar(c, Offset(sx, sy), 6, starPaint);
    }
  }

  void _drawStar(Canvas c, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outer = (i * 4 * pi / 5) - pi / 2;
      final inner = outer + 2 * pi / 10;
      final ox = center.dx + size * cos(outer);
      final oy = center.dy + size * sin(outer);
      final ix = center.dx + (size * 0.4) * cos(inner);
      final iy = center.dy + (size * 0.4) * sin(inner);
      i == 0 ? path.moveTo(ox, oy) : path.lineTo(ox, oy);
      path.lineTo(ix, iy);
    }
    path.close();
    c.drawPath(path, paint);
  }

  // ── กรอบแมว 🐱 ──
  void _drawCatFrame(Canvas c, Size s, double cx, double cy, double r) {
    // วงกลมชมพู gradient
    final ring = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.pink.shade200,
          Colors.pinkAccent.shade100,
          Colors.pink.shade300,
          Colors.pink.shade200,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke;
    c.drawCircle(Offset(cx, cy), r, ring);

    // หูแมวซ้าย
    final earPaint = Paint()..color = Colors.pink.shade300;
    final earLeft = Path()
      ..moveTo(cx - r * 0.55, cy - r * 0.72)
      ..lineTo(cx - r * 0.80, cy - r * 1.05)
      ..lineTo(cx - r * 0.25, cy - r * 0.90)
      ..close();
    c.drawPath(earLeft, earPaint);

    // หูแมวขวา
    final earRight = Path()
      ..moveTo(cx + r * 0.55, cy - r * 0.72)
      ..lineTo(cx + r * 0.80, cy - r * 1.05)
      ..lineTo(cx + r * 0.25, cy - r * 0.90)
      ..close();
    c.drawPath(earRight, earPaint);

    // ชั้นในหู
    final innerEar = Paint()..color = Colors.pink.shade100;
    final innerLeft = Path()
      ..moveTo(cx - r * 0.57, cy - r * 0.76)
      ..lineTo(cx - r * 0.74, cy - r * 0.98)
      ..lineTo(cx - r * 0.32, cy - r * 0.88)
      ..close();
    c.drawPath(innerLeft, innerEar);

    final innerRight = Path()
      ..moveTo(cx + r * 0.57, cy - r * 0.76)
      ..lineTo(cx + r * 0.74, cy - r * 0.98)
      ..lineTo(cx + r * 0.32, cy - r * 0.88)
      ..close();
    c.drawPath(innerRight, innerEar);

    // หางแมว (ขวาล่าง)
    final tailPaint = Paint()
      ..color = Colors.pink.shade300
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final tail = Path()
      ..moveTo(cx + r * 0.85, cy + r * 0.6)
      ..cubicTo(
        cx + r * 1.3,
        cy + r * 0.9,
        cx + r * 1.4,
        cy + r * 0.3,
        cx + r * 1.1,
        cy + r * 0.1,
      );
    c.drawPath(tail, tailPaint);
  }

  // ── กรอบไฟฟ้า ⚡ ──
  void _drawElectricFrame(Canvas c, Size s, double cx, double cy, double r) {
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.lightBlueAccent,
          Colors.white,
          Colors.lightBlue.shade700,
          Colors.cyanAccent,
          Colors.lightBlueAccent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    c.drawCircle(Offset(cx, cy), r, paint);

    // สายฟ้ารอบวง
    final boltPaint = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final count = 8;
    for (int i = 0; i < count; i++) {
      final a = (i / count) * 2 * pi;
      final x1 = cx + (r - 14) * cos(a);
      final y1 = cy + (r - 14) * sin(a);
      final x2 = cx + (r + 14) * cos(a + 0.15);
      final y2 = cy + (r + 14) * sin(a + 0.15);
      final xm = cx + (r + 4) * cos(a + 0.08);
      final ym = cy + (r + 4) * sin(a + 0.08);
      final bolt = Path()
        ..moveTo(x1, y1)
        ..lineTo(xm, ym)
        ..lineTo(x2, y2);
      c.drawPath(bolt, boltPaint);
    }
  }

  // ── กรอบเพชร 💎 ──
  void _drawDiamondFrame(Canvas c, Size s, double cx, double cy, double r) {
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.purple.shade200,
          Colors.purpleAccent,
          Colors.blue.shade300,
          Colors.purpleAccent.shade100,
          Colors.purple.shade200,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    c.drawCircle(Offset(cx, cy), r, paint);

    // เพชรรอบวง
    final dPaint = Paint()..color = Colors.purpleAccent.shade100;
    final count = 8;
    for (int i = 0; i < count; i++) {
      final a = (i / count) * 2 * pi;
      final dx = cx + (r + 1) * cos(a);
      final dy = cy + (r + 1) * sin(a);
      _drawDiamond(c, Offset(dx, dy), 7, dPaint);
    }
  }

  void _drawDiamond(Canvas c, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx + size * 0.6, center.dy)
      ..lineTo(center.dx, center.dy + size * 0.7)
      ..lineTo(center.dx - size * 0.6, center.dy)
      ..close();
    c.drawPath(path, paint);
  }

  // ── กรอบไฟ 🔥 ──
  void _drawFireFrame(Canvas c, Size s, double cx, double cy, double r) {
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.red.shade700,
          Colors.orange,
          Colors.yellow.shade600,
          Colors.orange,
          Colors.red.shade700,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke;
    c.drawCircle(Offset(cx, cy), r, paint);

    // เปลวไฟรอบวง
    final count = 10;
    for (int i = 0; i < count; i++) {
      final a = (i / count) * 2 * pi;
      final fx = cx + (r + 2) * cos(a);
      final fy = cy + (r + 2) * sin(a);
      _drawFlame(c, Offset(fx, fy), a, 14);
    }
  }

  void _drawFlame(Canvas c, Offset pos, double angle, double size) {
    final paint = Paint()
      ..shader =
          LinearGradient(
            colors: [Colors.yellow, Colors.orange, Colors.red],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(
            Rect.fromCenter(center: pos, width: size, height: size * 2),
          );

    final path = Path()
      ..moveTo(pos.dx, pos.dy - size)
      ..cubicTo(
        pos.dx + size * 0.5,
        pos.dy - size * 0.5,
        pos.dx + size * 0.3,
        pos.dy + size * 0.3,
        pos.dx,
        pos.dy + size * 0.5,
      )
      ..cubicTo(
        pos.dx - size * 0.3,
        pos.dy + size * 0.3,
        pos.dx - size * 0.5,
        pos.dy - size * 0.5,
        pos.dx,
        pos.dy - size,
      );

    c.save();
    c.translate(pos.dx, pos.dy);
    c.rotate(angle + pi / 2);
    c.translate(-pos.dx, -pos.dy);
    c.drawPath(path, paint);
    c.restore();
  }

  // ── กรอบเปลวสี 🌈 ──
  void _drawRainbowFrame(Canvas c, Size s, double cx, double cy, double r) {
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.red,
          Colors.orange,
          Colors.yellow,
          Colors.green,
          Colors.blue,
          Colors.indigo,
          Colors.purple,
          Colors.red,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;
    c.drawCircle(Offset(cx, cy), r, paint);

    // วงในเส้นเล็ก
    final inner = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.purple,
          Colors.blue,
          Colors.green,
          Colors.yellow,
          Colors.orange,
          Colors.red,
          Colors.purple,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r - 12))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    c.drawCircle(Offset(cx, cy), r - 12, inner);
  }

  @override
  bool shouldRepaint(_) => false;
}
