// lib/widgets/fish_painter.dart
import 'dart:math';
import 'package:flutter/material.dart';

// ── FishPainter — Vector ปลาสวยงาม ─────────────────────────────

class FishPainter extends CustomPainter {
  final String fishType;
  final Color color;
  final bool facingRight;

  FishPainter({
    required this.fishType,
    required this.color,
    this.facingRight = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    if (!facingRight) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    switch (fishType) {
      case 'nemo':
        _drawNemo(canvas, size);
        break;
      case 'goldfish':
        _drawGoldfish(canvas, size);
        break;
      case 'blue':
        _drawBlueTang(canvas, size);
        break;
      case 'angel':
        _drawAngelfish(canvas, size);
        break;
      case 'purple':
        _drawPurplefish(canvas, size);
        break;
      default:
        _drawGenericFish(canvas, size, color);
    }

    canvas.restore();
  }

  // ── Helper: วาดลำตัวหลัก ──────────────────────────────────────
  void _drawBody(Canvas c, Size s, List<Color> gradient) {
    final w = s.width;
    final h = s.height;

    // ลำตัวรูปทรงปลา
    final bodyPath = Path()
      ..moveTo(w * 0.82, h * 0.5)
      ..cubicTo(w * 0.82, h * 0.12, w * 0.4, h * 0.05, w * 0.18, h * 0.5)
      ..cubicTo(w * 0.4, h * 0.95, w * 0.82, h * 0.88, w * 0.82, h * 0.5);

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: gradient,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    c.drawPath(bodyPath, bodyPaint);

    // แสงสะท้อนบนตัวปลา
    final shinePath = Path()
      ..moveTo(w * 0.55, h * 0.18)
      ..cubicTo(w * 0.7, h * 0.12, w * 0.78, h * 0.2, w * 0.72, h * 0.32)
      ..cubicTo(w * 0.62, h * 0.28, w * 0.52, h * 0.24, w * 0.55, h * 0.18);

    c.drawPath(shinePath, Paint()..color = Colors.white.withOpacity(0.25));
  }

  // ── Helper: วาดหาง ────────────────────────────────────────────
  void _drawTail(Canvas c, Size s, Color tailColor, {double spread = 1.0}) {
    final w = s.width;
    final h = s.height;

    final tailPath = Path()
      ..moveTo(w * 0.2, h * 0.5)
      ..cubicTo(
        w * 0.08,
        h * 0.5,
        0,
        h * (0.5 - 0.35 * spread),
        w * 0.05,
        h * (0.5 - 0.38 * spread),
      )
      ..cubicTo(
        w * 0.12,
        h * (0.5 - 0.22 * spread),
        w * 0.18,
        h * 0.42,
        w * 0.2,
        h * 0.5,
      );

    final tailPath2 = Path()
      ..moveTo(w * 0.2, h * 0.5)
      ..cubicTo(
        w * 0.08,
        h * 0.5,
        0,
        h * (0.5 + 0.35 * spread),
        w * 0.05,
        h * (0.5 + 0.38 * spread),
      )
      ..cubicTo(
        w * 0.12,
        h * (0.5 + 0.22 * spread),
        w * 0.18,
        h * 0.58,
        w * 0.2,
        h * 0.5,
      );

    final tailPaint = Paint()
      ..shader = LinearGradient(
        colors: [tailColor.withOpacity(0.9), tailColor.withOpacity(0.5)],
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
      ).createShader(Rect.fromLTWH(0, 0, w * 0.25, h));

    c.drawPath(tailPath, tailPaint);
    c.drawPath(tailPath2, tailPaint);
  }

  // ── Helper: ครีบหลัง ──────────────────────────────────────────
  void _drawDorsalFin(Canvas c, Size s, Color finColor) {
    final w = s.width;
    final h = s.height;
    final finPath = Path()
      ..moveTo(w * 0.35, h * 0.15)
      ..cubicTo(w * 0.45, h * 0.0, w * 0.62, h * 0.0, w * 0.7, h * 0.12)
      ..cubicTo(w * 0.62, h * 0.14, w * 0.48, h * 0.13, w * 0.35, h * 0.15);
    c.drawPath(finPath, Paint()..color = finColor.withOpacity(0.75));
  }

  // ── Helper: ครีบท้อง ──────────────────────────────────────────
  void _drawPectoralFin(Canvas c, Size s, Color finColor) {
    final w = s.width;
    final h = s.height;
    final finPath = Path()
      ..moveTo(w * 0.55, h * 0.6)
      ..cubicTo(w * 0.42, h * 0.68, w * 0.38, h * 0.82, w * 0.5, h * 0.88)
      ..cubicTo(w * 0.58, h * 0.8, w * 0.6, h * 0.68, w * 0.55, h * 0.6);
    c.drawPath(finPath, Paint()..color = finColor.withOpacity(0.7));
  }

  // ── Helper: ตา ────────────────────────────────────────────────
  void _drawEye(Canvas c, Size s) {
    final w = s.width;
    final h = s.height;
    // ขาวตา
    c.drawCircle(
      Offset(w * 0.68, h * 0.36),
      w * 0.075,
      Paint()..color = Colors.white,
    );
    // ม่านตา
    c.drawCircle(
      Offset(w * 0.69, h * 0.37),
      w * 0.048,
      Paint()..color = const Color(0xFF1A1A2E),
    );
    // highlight ตา
    c.drawCircle(
      Offset(w * 0.685, h * 0.345),
      w * 0.02,
      Paint()..color = Colors.white.withOpacity(0.9),
    );
  }

  // ── นีโม่ — ส้ม+ขาว ──────────────────────────────────────────
  void _drawNemo(Canvas c, Size s) {
    final w = s.width;
    final h = s.height;

    _drawTail(c, s, const Color(0xFFE85D24));
    _drawDorsalFin(c, s, const Color(0xFFE85D24));
    _drawPectoralFin(c, s, const Color(0xFFFF8C42));

    // ลำตัวสีส้ม
    _drawBody(c, s, [
      const Color(0xFFFF6B35),
      const Color(0xFFE85D24),
      const Color(0xFFFF8C42),
    ]);

    // แถบขาว 3 แถบ
    final stripePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = w * 0.075
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final xPct in [0.42, 0.58, 0.72]) {
      c.drawLine(
        Offset(w * xPct, h * 0.14),
        Offset(w * xPct, h * 0.86),
        stripePaint,
      );
    }

    // เส้นขอบแถบดำ
    final outlinePaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..strokeWidth = w * 0.025
      ..style = PaintingStyle.stroke;
    for (final xPct in [0.38, 0.46, 0.54, 0.62, 0.68, 0.76]) {
      c.drawLine(
        Offset(w * xPct, h * 0.16),
        Offset(w * xPct, h * 0.84),
        outlinePaint,
      );
    }

    _drawEye(c, s);
  }

  // ── ปลาทอง ────────────────────────────────────────────────────
  void _drawGoldfish(Canvas c, Size s) {
    final w = s.width;
    final h = s.height;

    // หางสวย 2 แฉก
    final tail1 = Path()
      ..moveTo(w * 0.2, h * 0.5)
      ..cubicTo(w * 0.05, h * 0.08, 0, h * 0.02, w * 0.06, h * 0.12)
      ..cubicTo(w * 0.12, h * 0.3, w * 0.18, h * 0.4, w * 0.2, h * 0.5);
    final tail2 = Path()
      ..moveTo(w * 0.2, h * 0.5)
      ..cubicTo(w * 0.05, h * 0.92, 0, h * 0.98, w * 0.06, h * 0.88)
      ..cubicTo(w * 0.12, h * 0.7, w * 0.18, h * 0.6, w * 0.2, h * 0.5);

    final tailShader = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFDAA520),
          const Color(0xFFFFD700).withOpacity(0.4),
        ],
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
      ).createShader(Rect.fromLTWH(0, 0, w * 0.25, h));
    c.drawPath(tail1, tailShader);
    c.drawPath(tail2, tailShader);

    _drawDorsalFin(c, s, const Color(0xFFDAA520));
    _drawPectoralFin(c, s, const Color(0xFFFFD700));

    _drawBody(c, s, [
      const Color(0xFFFFD700),
      const Color(0xFFDAA520),
      const Color(0xFFFFC107),
    ]);

    // ลาย scale เล็กๆ
    final scalePaint = Paint()
      ..color = const Color(0xFFB8860B).withOpacity(0.3)
      ..strokeWidth = w * 0.012
      ..style = PaintingStyle.stroke;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 4; col++) {
        c.drawArc(
          Rect.fromCenter(
            center: Offset(w * (0.35 + col * 0.1), h * (0.3 + row * 0.2)),
            width: w * 0.12,
            height: h * 0.14,
          ),
          0,
          pi,
          false,
          scalePaint,
        );
      }
    }

    _drawEye(c, s);
  }

  // ── Blue Tang (ปลาสีน้ำเงิน) ─────────────────────────────────
  void _drawBlueTang(Canvas c, Size s) {
    final w = s.width;
    final h = s.height;

    _drawTail(c, s, const Color(0xFF0D47A1), spread: 0.9);
    _drawDorsalFin(c, s, const Color(0xFF1565C0));
    _drawPectoralFin(c, s, const Color(0xFF42A5F5));

    _drawBody(c, s, [
      const Color(0xFF42A5F5),
      const Color(0xFF1565C0),
      const Color(0xFF0D47A1),
    ]);

    // เส้นสีเหลืองข้างตัว (Blue Tang signature)
    final linePaint = Paint()
      ..color = const Color(0xFFFFEB3B).withOpacity(0.85)
      ..strokeWidth = h * 0.07
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    c.drawLine(Offset(w * 0.3, h * 0.5), Offset(w * 0.78, h * 0.5), linePaint);

    // หางสีเหลือง
    final yellowTail = Paint()
      ..color = const Color(0xFFFFEB3B).withOpacity(0.7)
      ..strokeWidth = h * 0.12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    c.drawLine(
      Offset(w * 0.22, h * 0.28),
      Offset(w * 0.08, h * 0.15),
      yellowTail,
    );
    c.drawLine(
      Offset(w * 0.22, h * 0.72),
      Offset(w * 0.08, h * 0.85),
      yellowTail,
    );

    _drawEye(c, s);
  }

  // ── Angelfish (ปลาเทวดา) ─────────────────────────────────────
  void _drawAngelfish(Canvas c, Size s) {
    final w = s.width;
    final h = s.height;

    // ครีบบน-ล่างยาว (signature ของ angelfish)
    final topFin = Path()
      ..moveTo(w * 0.4, h * 0.08)
      ..cubicTo(w * 0.55, h * -0.25, w * 0.7, h * -0.15, w * 0.75, h * 0.1)
      ..cubicTo(w * 0.65, h * 0.08, w * 0.5, h * 0.06, w * 0.4, h * 0.08);
    c.drawPath(
      topFin,
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFBDBDBD),
            const Color(0xFF9E9E9E).withOpacity(0.5),
          ],
        ).createShader(Rect.fromLTWH(w * 0.3, 0, w * 0.5, h * 0.3)),
    );

    final bottomFin = Path()
      ..moveTo(w * 0.4, h * 0.92)
      ..cubicTo(w * 0.55, h * 1.25, w * 0.7, h * 1.15, w * 0.75, h * 0.9)
      ..cubicTo(w * 0.65, h * 0.92, w * 0.5, h * 0.94, w * 0.4, h * 0.92);
    c.drawPath(
      bottomFin,
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFBDBDBD),
            const Color(0xFF9E9E9E).withOpacity(0.5),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(w * 0.3, h * 0.7, w * 0.5, h * 0.5)),
    );

    _drawTail(c, s, const Color(0xFF9E9E9E), spread: 0.7);
    _drawPectoralFin(c, s, const Color(0xFFBDBDBD));

    _drawBody(c, s, [
      const Color(0xFFEEEEEE),
      const Color(0xFFBDBDBD),
      const Color(0xFFE0E0E0),
    ]);

    // แถบดำ 3 เส้น (angelfish signature)
    final stripePaint = Paint()
      ..color = const Color(0xFF2C2C2C).withOpacity(0.7)
      ..strokeWidth = w * 0.065
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final xPct in [0.4, 0.58, 0.73]) {
      c.drawLine(
        Offset(w * xPct, h * 0.1),
        Offset(w * xPct, h * 0.9),
        stripePaint,
      );
    }

    _drawEye(c, s);
  }

  // ── ปลาม่วง ───────────────────────────────────────────────────
  void _drawPurplefish(Canvas c, Size s) {
    final w = s.width;
    final h = s.height;

    _drawTail(c, s, const Color(0xFF6A1B9A), spread: 1.1);
    _drawDorsalFin(c, s, const Color(0xFF7B1FA2));
    _drawPectoralFin(c, s, const Color(0xFFAB47BC));

    _drawBody(c, s, [
      const Color(0xFFCE93D8),
      const Color(0xFF7B1FA2),
      const Color(0xFFAB47BC),
    ]);

    // ลาย sparkle จุดสว่าง
    final sparkPaint = Paint()..color = Colors.white.withOpacity(0.45);
    for (final pos in [
      [0.48, 0.28],
      [0.62, 0.35],
      [0.55, 0.55],
      [0.7, 0.6],
      [0.45, 0.65],
    ]) {
      c.drawCircle(Offset(w * pos[0], h * pos[1]), w * 0.025, sparkPaint);
    }

    _drawEye(c, s);
  }

  // ── Generic fish ─────────────────────────────────────────────
  void _drawGenericFish(Canvas c, Size s, Color col) {
    final dark = HSLColor.fromColor(col)
        .withLightness((HSLColor.fromColor(col).lightness - 0.15).clamp(0, 1))
        .toColor();
    final light = HSLColor.fromColor(col)
        .withLightness((HSLColor.fromColor(col).lightness + 0.15).clamp(0, 1))
        .toColor();
    _drawTail(c, s, dark);
    _drawDorsalFin(c, s, dark);
    _drawPectoralFin(c, s, col);
    _drawBody(c, s, [light, col, dark]);
    _drawEye(c, s);
  }

  @override
  bool shouldRepaint(FishPainter old) =>
      old.fishType != fishType ||
      old.color != color ||
      old.facingRight != facingRight;
}

// ── FishWidget — Widget wrapper ─────────────────────────────────

class FishWidget extends StatelessWidget {
  final String fishType;
  final Color color;
  final double width;
  final double height;
  final bool facingRight;

  const FishWidget({
    super.key,
    required this.fishType,
    required this.color,
    this.width = 80,
    this.height = 50,
    this.facingRight = true,
  });

  /// ใช้ในร้านค้า — ขนาดใหญ่สำหรับ tile
  factory FishWidget.tile(String type, Color color) =>
      FishWidget(fishType: type, color: color, width: 90, height: 56);

  /// ใช้ในตู้ปลา — ขนาดจาก constraints
  factory FishWidget.tank(String type, Color color, double w) =>
      FishWidget(fishType: type, color: color, width: w, height: w * 0.62);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: FishPainter(
          fishType: fishType,
          color: color,
          facingRight: facingRight,
        ),
      ),
    );
  }
}
