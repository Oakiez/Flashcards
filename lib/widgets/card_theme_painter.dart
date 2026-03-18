// lib/widgets/card_theme_painter.dart
import 'dart:math';
import 'package:flutter/material.dart';

class CardThemePainter extends CustomPainter {
  final String themeId;
  final Color bg;
  final Color accent;
  final bool isBack;

  CardThemePainter({
    required this.themeId,
    required this.bg,
    required this.accent,
    required this.isBack,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bgPaint = Paint()
      ..shader = LinearGradient(
        colors: [bg, _darken(bg, 0.08)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(rrect, bgPaint);

    // border
    _drawBorder(canvas, size, rrect);

    // pattern / icon
    canvas.save();
    canvas.clipRRect(rrect);
    if (isBack) {
      _drawPattern(canvas, size);
    } else {
      _drawFrontIcon(canvas, size);
    }
    canvas.restore();

    // shine overlay
    final shine = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white.withOpacity(0.18), Colors.transparent],
        begin: Alignment.topLeft,
        end: Alignment.center,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(rrect, shine);
  }

  // ── Border ─────────────────────────────────────────

  void _drawBorder(Canvas c, Size s, RRect rrect) {
    Paint p;
    switch (themeId) {
      case 'christmas':
        p = Paint()
          ..shader = SweepGradient(
            colors: [
              Colors.red.shade700,
              Colors.white,
              Colors.red.shade700,
              Colors.white,
              Colors.red.shade700,
            ],
          ).createShader(Rect.fromLTWH(0, 0, s.width, s.height))
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;
        break;
      case 'chinese_new_year':
        p = Paint()
          ..shader = SweepGradient(
            colors: [
              const Color(0xFFFFD700),
              const Color(0xFFFFF176),
              const Color(0xFFFFD700),
            ],
          ).createShader(Rect.fromLTWH(0, 0, s.width, s.height))
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;
        break;
      case 'halloween':
        p = Paint()
          ..color = const Color(0xFFFF6D00)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3);
        break;
      case 'ocean':
        p = Paint()
          ..shader = SweepGradient(
            colors: [Colors.cyan, Colors.blue.shade300, Colors.cyan],
          ).createShader(Rect.fromLTWH(0, 0, s.width, s.height))
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;
        break;
      case 'sakura':
        p = Paint()
          ..shader = SweepGradient(
            colors: [
              Colors.pink.shade200,
              Colors.pink.shade100,
              Colors.pink.shade300,
              Colors.pink.shade200,
            ],
          ).createShader(Rect.fromLTWH(0, 0, s.width, s.height))
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;
        break;
      default:
        p = Paint()
          ..color = accent.withOpacity(0.5)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
    }
    c.drawRRect(rrect, p);
  }

  // ── Pattern ────────────────────────────────────────

  void _drawPattern(Canvas c, Size s) {
    switch (themeId) {
      case 'christmas':
        _patternChristmas(c, s);
        break;
      case 'chinese_new_year':
        _patternCNY(c, s);
        break;
      case 'halloween':
        _patternHalloween(c, s);
        break;
      case 'ocean':
        _patternOcean(c, s);
        break;
      case 'sakura':
        _patternSakura(c, s);
        break;
      default:
        _patternDefault(c, s);
    }
  }

  // ── Icon ───────────────────────────────────────────

  void _drawFrontIcon(Canvas c, Size s) {
    _drawPattern(c, s);
  }

  // ── Patterns ────────────────────────────────────────────────

  void _patternChristmas(Canvas c, Size s) {
    final snowP = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (final pos in [
      [0.12, 0.12],
      [0.88, 0.18],
      [0.25, 0.72],
      [0.75, 0.65],
      [0.5, 0.35],
      [0.1, 0.45],
      [0.9, 0.55],
    ]) {
      _drawSnowflake(
        c,
        Offset(s.width * pos[0], s.height * pos[1]),
        s.width * 0.06,
        snowP,
      );
    }
    // ⭐ ดาว
    final starP = Paint()..color = Colors.yellow.withOpacity(0.5);
    for (final pos in [
      [0.82, 0.08],
      [0.18, 0.22],
      [0.65, 0.78],
    ]) {
      _drawStar(
        c,
        Offset(s.width * pos[0], s.height * pos[1]),
        s.width * 0.055,
        starP,
      );
    }
    // 🟥 กล่องของขวัญ
    final boxP = Paint()..color = Colors.red.withOpacity(0.22);
    final ribbonP = Paint()
      ..color = Colors.yellow.withOpacity(0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (final pos in [
      [0.15, 0.82],
      [0.78, 0.25],
    ]) {
      final bx = s.width * pos[0];
      final by = s.height * pos[1];
      final bw = s.width * 0.1;
      final bh = s.height * 0.07;
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(bx, by), width: bw, height: bh),
          const Radius.circular(3),
        ),
        boxP,
      );
      c.drawLine(Offset(bx, by - bh / 2), Offset(bx, by + bh / 2), ribbonP);
      c.drawLine(Offset(bx - bw / 2, by), Offset(bx + bw / 2, by), ribbonP);
    }
    // จุดสีแดงเล็ก
    final dotP = Paint()..color = Colors.red.withOpacity(0.18);
    for (final pos in [
      [0.4, 0.15],
      [0.6, 0.88],
      [0.05, 0.6],
      [0.95, 0.4],
    ]) {
      c.drawCircle(
        Offset(s.width * pos[0], s.height * pos[1]),
        s.width * 0.025,
        dotP,
      );
    }
  }

  void _drawSnowflake(Canvas c, Offset center, double size, Paint p) {
    for (int i = 0; i < 6; i++) {
      final angle = i * 3.14159 / 3;
      c.drawLine(
        Offset(center.dx + size * cos(angle), center.dy + size * sin(angle)),
        Offset(center.dx - size * cos(angle), center.dy - size * sin(angle)),
        p,
      );
      // กิ่งเล็ก
      for (final t in [0.5, -0.5]) {
        final mx = center.dx + size * 0.5 * cos(angle);
        final my = center.dy + size * 0.5 * sin(angle);
        final bAngle = angle + t * 3.14159 / 3;
        c.drawLine(
          Offset(mx, my),
          Offset(
            mx + size * 0.25 * cos(bAngle),
            my + size * 0.25 * sin(bAngle),
          ),
          p,
        );
      }
    }
  }

  void _patternCNY(Canvas c, Size s) {
    // 🔴 วงกลมทองซ้อน
    final ringP = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (int i = 1; i <= 3; i++) {
      c.drawCircle(
        Offset(s.width * 0.5, s.height * 0.5),
        s.width * i * 0.18,
        ringP,
      );
    }
    // 🏮 โคมไฟ
    final lanternP = Paint()..color = Colors.red.withOpacity(0.28);
    final stringP = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (final pos in [
      [0.15, 0.18],
      [0.85, 0.18],
      [0.5, 0.08],
    ]) {
      final lx = s.width * pos[0];
      final ly = s.height * pos[1];
      c.drawLine(
        Offset(lx, ly - s.height * 0.04),
        Offset(lx, ly + s.height * 0.06),
        stringP,
      );
      c.drawOval(
        Rect.fromCenter(
          center: Offset(lx, ly),
          width: s.width * 0.1,
          height: s.height * 0.09,
        ),
        lanternP,
      );
      c.drawLine(
        Offset(lx, ly + s.height * 0.045),
        Offset(lx, ly + s.height * 0.07),
        stringP,
      );
    }
    // 💛 เพชรทอง
    final dp = Paint()..color = const Color(0xFFFFD700).withOpacity(0.3);
    for (final pos in [
      [0.15, 0.75],
      [0.85, 0.75],
      [0.5, 0.88],
    ]) {
      _drawDiamond(
        c,
        Offset(s.width * pos[0], s.height * pos[1]),
        s.width * 0.055,
        dp,
      );
    }
    // คลื่น
    final waveP = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.12)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (int row = 0; row < 3; row++) {
      final path = Path()..moveTo(0, s.height * (0.3 + row * 0.15));
      for (double x = 0; x <= s.width; x += 3) {
        path.lineTo(
          x,
          s.height * (0.3 + row * 0.15) +
              sin(x / s.width * 2 * pi * 3) * s.height * 0.02,
        );
      }
      c.drawPath(path, waveP);
    }
  }

  void _patternHalloween(Canvas c, Size s) {
    // 🕸️ ใยแมงมุม
    final wp = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= 4; i++) {
      c.drawArc(
        Rect.fromLTWH(
          -s.width * 0.05,
          -s.height * 0.05,
          s.width * i * 0.3,
          s.height * i * 0.3,
        ),
        0,
        pi / 2,
        false,
        wp,
      );
      c.drawArc(
        Rect.fromLTWH(
          s.width * 1.05 - s.width * i * 0.3,
          s.height * 0.7,
          s.width * i * 0.3,
          s.height * i * 0.3,
        ),
        pi,
        pi / 2,
        false,
        wp,
      );
    }
    // เส้นใย
    for (int i = 0; i < 4; i++) {
      final angle = i * pi / 8;
      c.drawLine(
        Offset.zero,
        Offset(s.width * 0.9 * cos(angle), s.height * 0.9 * sin(angle)),
        wp,
      );
    }
    // 🦇 ค้างคาว
    final batP = Paint()..color = Colors.purple.shade900.withOpacity(0.3);
    for (final pos in [
      [0.25, 0.25],
      [0.75, 0.15],
      [0.5, 0.65],
      [0.85, 0.55],
    ]) {
      _drawBat(
        c,
        Offset(s.width * pos[0], s.height * pos[1]),
        s.width * 0.07,
        batP,
      );
    }
    // ⚡ จุดส้มเรืองแสง
    final p = Paint()..color = const Color(0xFFFF6D00).withOpacity(0.2);
    for (final pos in [
      [0.1, 0.7],
      [0.9, 0.3],
      [0.4, 0.88],
      [0.6, 0.1],
    ]) {
      c.drawCircle(
        Offset(s.width * pos[0], s.height * pos[1]),
        s.width * 0.04,
        p,
      );
    }
  }

  void _drawBat(Canvas c, Offset center, double size, Paint p) {
    // ตัว
    c.drawOval(
      Rect.fromCenter(center: center, width: size * 0.5, height: size * 0.35),
      p,
    );
    // ปีกซ้าย
    final leftWing = Path()
      ..moveTo(center.dx - size * 0.2, center.dy)
      ..cubicTo(
        center.dx - size * 0.8,
        center.dy - size * 0.5,
        center.dx - size,
        center.dy - size * 0.2,
        center.dx - size * 0.9,
        center.dy + size * 0.1,
      )
      ..lineTo(center.dx - size * 0.2, center.dy)
      ..close();
    c.drawPath(leftWing, p);
    // ปีกขวา
    final rightWing = Path()
      ..moveTo(center.dx + size * 0.2, center.dy)
      ..cubicTo(
        center.dx + size * 0.8,
        center.dy - size * 0.5,
        center.dx + size,
        center.dy - size * 0.2,
        center.dx + size * 0.9,
        center.dy + size * 0.1,
      )
      ..lineTo(center.dx + size * 0.2, center.dy)
      ..close();
    c.drawPath(rightWing, p);
  }

  void _patternOcean(Canvas c, Size s) {
    // 🌊 คลื่น
    final waveP = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (int row = 0; row < 5; row++) {
      final y = s.height * (row + 0.5) / 5;
      final path = Path()..moveTo(0, y);
      for (double x = 0; x <= s.width; x += 2) {
        path.lineTo(x, y + sin(x / s.width * 2 * pi * 2) * s.height * 0.04);
      }
      c.drawPath(path, waveP);
    }
    // 🐠 ปลาเล็ก
    final fishP = Paint()..color = Colors.orange.withOpacity(0.25);
    for (final pos in [
      [0.2, 0.2],
      [0.75, 0.35],
      [0.4, 0.65],
      [0.85, 0.75],
    ]) {
      _drawTinyFish(
        c,
        Offset(s.width * pos[0], s.height * pos[1]),
        s.width * 0.08,
        fishP,
      );
    }
    // ⭐ ดาวทะเล
    final starP = Paint()..color = Colors.yellow.withOpacity(0.28);
    for (final pos in [
      [0.1, 0.8],
      [0.9, 0.15],
      [0.55, 0.88],
    ]) {
      _drawStar(
        c,
        Offset(s.width * pos[0], s.height * pos[1]),
        s.width * 0.06,
        starP,
      );
    }
    // ฟองน้ำ
    final bubbleP = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final pos in [
      [0.15, 0.45],
      [0.65, 0.2],
      [0.35, 0.78],
      [0.8, 0.55],
    ]) {
      c.drawCircle(
        Offset(s.width * pos[0], s.height * pos[1]),
        s.width * 0.04,
        bubbleP,
      );
    }
  }

  void _drawTinyFish(Canvas c, Offset center, double size, Paint p) {
    final bodyPath = Path()
      ..moveTo(center.dx + size * 0.5, center.dy)
      ..cubicTo(
        center.dx + size * 0.5,
        center.dy - size * 0.3,
        center.dx - size * 0.2,
        center.dy - size * 0.3,
        center.dx - size * 0.2,
        center.dy,
      )
      ..cubicTo(
        center.dx - size * 0.2,
        center.dy + size * 0.3,
        center.dx + size * 0.5,
        center.dy + size * 0.3,
        center.dx + size * 0.5,
        center.dy,
      );
    c.drawPath(bodyPath, p);
    final tailPath = Path()
      ..moveTo(center.dx - size * 0.2, center.dy)
      ..lineTo(center.dx - size * 0.5, center.dy - size * 0.25)
      ..lineTo(center.dx - size * 0.5, center.dy + size * 0.25)
      ..close();
    c.drawPath(tailPath, p);
  }

  void _patternSakura(Canvas c, Size s) {
    // 🌸 ดอกซากุระ
    for (final item in [
      [0.15, 0.15, 0.09, 0.3],
      [0.8, 0.12, 0.07, 0.22],
      [0.5, 0.45, 0.11, 0.28],
      [0.08, 0.65, 0.08, 0.25],
      [0.88, 0.62, 0.09, 0.27],
      [0.4, 0.85, 0.07, 0.2],
      [0.65, 0.28, 0.06, 0.18],
      [0.25, 0.55, 0.05, 0.15],
    ]) {
      final p = Paint()..color = Colors.pink.withOpacity(item[3]);
      _drawSakura(
        c,
        Offset(s.width * item[0], s.height * item[1]),
        s.width * item[2],
        p,
      );
    }
    // กลีบร่วง
    final petalP = Paint()..color = Colors.pink.withOpacity(0.18);
    for (final pos in [
      [0.35, 0.32],
      [0.7, 0.68],
      [0.18, 0.82],
      [0.82, 0.38],
    ]) {
      c.save();
      c.translate(s.width * pos[0], s.height * pos[1]);
      c.rotate(0.5);
      c.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: s.width * 0.06,
          height: s.width * 0.03,
        ),
        petalP,
      );
      c.restore();
    }
    // จุดสีชมพู
    final dotP = Paint()..color = Colors.pinkAccent.withOpacity(0.15);
    for (final pos in [
      [0.55, 0.12],
      [0.03, 0.35],
      [0.97, 0.82],
      [0.48, 0.95],
    ]) {
      c.drawCircle(
        Offset(s.width * pos[0], s.height * pos[1]),
        s.width * 0.025,
        dotP,
      );
    }
  }

  void _patternDefault(Canvas c, Size s) {
    final p = Paint()..color = accent.withOpacity(0.12);
    for (int r = 0; r < 4; r++) {
      for (int col = 0; col < 3; col++) {
        c.drawCircle(
          Offset(s.width * (col * 0.35 + 0.18), s.height * (r * 0.28 + 0.1)),
          s.width * 0.04,
          p,
        );
      }
    }
  }

  // ── Shape ───────────────────────────────────────────

  void _drawStar(Canvas c, Offset center, double size, Paint p) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outer = (i * 4 * pi / 5) - pi / 2;
      final inner = outer + 2 * pi / 10;
      final ox = center.dx + size * cos(outer);
      final oy = center.dy + size * sin(outer);
      final ix = center.dx + size * 0.4 * cos(inner);
      final iy = center.dy + size * 0.4 * sin(inner);
      i == 0 ? path.moveTo(ox, oy) : path.lineTo(ox, oy);
      path.lineTo(ix, iy);
    }
    path.close();
    c.drawPath(path, p);
  }

  void _drawDiamond(Canvas c, Offset center, double size, Paint p) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx + size * 0.6, center.dy)
      ..lineTo(center.dx, center.dy + size * 0.8)
      ..lineTo(center.dx - size * 0.6, center.dy)
      ..close();
    c.drawPath(path, p);
  }

  void _drawSakura(Canvas c, Offset center, double size, Paint p) {
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * pi / 5) - pi / 2;
      final px = center.dx + size * 0.7 * cos(angle);
      final py = center.dy + size * 0.7 * sin(angle);
      c.drawOval(
        Rect.fromCenter(
          center: Offset(px, py),
          width: size * 0.7,
          height: size * 0.5,
        ),
        p,
      );
    }
    c.drawCircle(
      center,
      size * 0.15,
      Paint()..color = Colors.yellow.withOpacity(0.35),
    );
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0, 1)).toColor();
  }

  @override
  bool shouldRepaint(CardThemePainter old) =>
      old.themeId != themeId || old.isBack != isBack;
}
