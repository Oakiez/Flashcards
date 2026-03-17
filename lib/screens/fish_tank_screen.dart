import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/deck_provider.dart';
import '../models/deck_model.dart';

class FishTankScreen extends StatefulWidget {
  const FishTankScreen({super.key});

  @override
  State<FishTankScreen> createState() => _FishTankScreenState();
}

class _FishTankScreenState extends State<FishTankScreen>
    with TickerProviderStateMixin {
  late AnimationController _fishController;
  late AnimationController _bubbleController;
  late AnimationController _waveController;

  final Map<String, _FishState> _fishStates = {};
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DeckProvider>();
      if (provider.fishDiedFromHunger) {
        provider.fishDiedFromHunger = false;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('ปลาตายหมดแล้ว 💀'),
            content: const Text(
              'ปลาของคุณหิวอาหารจนตายหมดแล้ว!\nอย่าลืมให้อาหารปลาสม่ำเสมอนะ 🍤',
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA3C9A8),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'รับทราบ',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }
    });

    _fishController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..addListener(_updateFishPositions)
          ..repeat();

    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  void _updateFishPositions() {
    final tank = context.read<DeckProvider>().fishTank;
    for (final fish in tank.fishes) {
      if (!_fishStates.containsKey(fish.id)) {
        _fishStates[fish.id] = _FishState(
          x: fish.x,
          y: fish.y,
          targetX: _random.nextDouble() * 0.8 + 0.1,
          targetY: _random.nextDouble() * 0.5 + 0.15,
          speed: 0.003 + _random.nextDouble() * 0.002,
          facingRight: true,
          wiggle: 0,
        );
      }
      final state = _fishStates[fish.id]!;
      state.wiggle = sin(_fishController.value * 2 * pi * 3) * 0.05;
      final dx = state.targetX - state.x;
      final dy = state.targetY - state.y;
      final dist = sqrt(dx * dx + dy * dy);
      if (dist < 0.02) {
        state.targetX = _random.nextDouble() * 0.8 + 0.1;
        state.targetY = _random.nextDouble() * 0.5 + 0.15;
      } else {
        state.facingRight = dx > 0;
        state.x += (dx / dist) * state.speed;
        state.y += (dy / dist) * state.speed;
      }
    }
    setState(() {});
  }

  void _showFishListModal(BuildContext context, DeckProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Consumer<DeckProvider>(
        builder: (context, prov, _) {
          final fishes = prov.fishTank.fishes;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ปลาในตู้ 🐠',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${fishes.length}/20 ตัว',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (fishes.isEmpty)
                  const Center(
                    child: Text(
                      'ไม่มีปลาในตู้',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: fishes.length,
                      itemBuilder: (_, i) {
                        final fish = fishes[i];
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 25,
                            decoration: BoxDecoration(
                              color: Color(fish.colorValue),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          title: Text(
                            fish.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('ตัวที่ ${i + 1}'),
                          trailing: TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('ขายปลา?'),
                                  content: Text(
                                    'ขาย ${fish.name} ได้ 💰 20 เหรียญ',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('ยกเลิก'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                      ),
                                      onPressed: () {
                                        prov.sellFish(fish.id);
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'ขาย',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.sell,
                              size: 16,
                              color: Colors.redAccent,
                            ),
                            label: const Text(
                              'ขาย',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _fishController.dispose();
    _bubbleController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeckProvider>();
    final tank = provider.fishTank;
    final user = provider.user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('ตู้ปลาของฉัน 🐠'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${user.coins}',
                  style: const TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── ตู้ปลา ──────────────────────────────────
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        _buildWaterBackground(constraints),
                        _buildLampGlow(tank, constraints),
                        _buildGravel(tank, constraints),
                        if (tank.hasPlant) _buildPlant(constraints),
                        if (tank.hasSeaweed) _buildSeaweed(constraints),
                        if (tank.hasCoral) _buildCoral(constraints),
                        if (tank.hasRock) _buildRock(constraints),
                        if (tank.hasTunnel) _buildTunnel(constraints),
                        if (tank.hasCastle) _buildCastle(constraints),
                        if (tank.hasAnchor) _buildAnchor(constraints),
                        if (tank.lampColor.isNotEmpty)
                          _buildLamp(tank, constraints),
                        ...tank.fishes.map(
                          (fish) => _buildFish(fish, constraints),
                        ),
                        _buildBubbles(constraints),
                        _buildWave(constraints),
                        if (tank.fishes.isEmpty)
                          const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('🐚', style: TextStyle(fontSize: 48)),
                                SizedBox(height: 8),
                                Text(
                                  'ยังไม่มีปลาในตู้\nไปซื้อปลาจากร้านค้าได้เลย!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // ── ปุ่มให้อาหาร + สถานะ ────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Food level bar
                Row(
                  children: [
                    const Text('🍤', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: tank.foodLevel / 100,
                          minHeight: 10,
                          backgroundColor: Colors.grey[200],
                          color: tank.foodLevel > 30
                              ? const Color(0xFFA3C9A8)
                              : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${tank.foodLevel}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: tank.foodLevel <= 30 ? Colors.red : Colors.grey,
                        fontWeight: tank.foodLevel <= 30
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),

                if (tank.fishes.isNotEmpty && tank.foodLevel <= 30)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tank.foodLevel == 0
                              ? 'ปลาตายแล้ว! ไปซื้อปลาใหม่ได้เลย 💀'
                              : 'อาหารใกล้หมดแล้ว! ไปซื้อเพิ่มในร้านค้านะ 🍤',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // ปุ่มให้อาหาร
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: provider.isFedToday
                          ? Colors.grey[300]
                          : const Color(0xFFA3C9A8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Text('🍤', style: TextStyle(fontSize: 20)),
                    label: Text(
                      tank.foodLevel >= 100
                          ? 'อาหารเต็มแล้ว 100% ✓'
                          : 'ให้อาหารปลา  (มี ${tank.foodBags} ถุง)',
                      style: TextStyle(
                        color: provider.isFedToday ? Colors.grey : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: provider.isFedToday
                        ? null
                        : () {
                            final result = provider.feedFish();
                            String msg;
                            Color color;
                            switch (result) {
                              case 'no_fish':
                                msg = 'ยังไม่มีปลาในตู้เลย! ไปซื้อปลาก่อนนะ 🐠';
                                color = Colors.orange;
                                break;
                              case 'no_food':
                                msg =
                                    'ไม่มีอาหาร! ไปซื้ออาหารในร้านค้าก่อนนะ 🍤';
                                color = Colors.red;
                                break;
                              case 'full':
                                msg =
                                    'อาหารเต็ม 100% แล้ว ไม่ต้องให้เพิ่มนะ 🐠';
                                color = Colors.green;
                                break;
                              default:
                                msg =
                                    'ให้อาหารปลาแล้ว! 🐠 (เหลือ ${tank.foodBags} ถุง)';
                                color = const Color(0xFFA3C9A8);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(msg),
                                backgroundColor: color,
                              ),
                            );
                          },
                  ),
                ),


                // ── จำนวนปลา + ปุ่มจัดการ ──────────────
                if (tank.fishes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ปลาในตู้: ${tank.fishes.length}/20 ตัว',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              _showFishListModal(context, provider),
                          icon: const Icon(
                            Icons.manage_accounts,
                            size: 16,
                            color: Color(0xFFA3C9A8),
                          ),
                          label: const Text(
                            'จัดการปลา',
                            style: TextStyle(
                              color: Color(0xFFA3C9A8),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget Builders ───────────────────────────────

  Widget _buildWaterBackground(BoxConstraints c) {
    return Container(
      width: c.maxWidth,
      height: c.maxHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A6B8A), Color(0xFF0D4F6E), Color(0xFF093D55)],
        ),
      ),
    );
  }

  // ✅ แสง glow จากตะเกียง
  Widget _buildLampGlow(FishTank tank, BoxConstraints c) {
    if (tank.lampColor.isEmpty) return const SizedBox();
    final color = _lampColor(tank.lampColor);
    return Positioned(
      top: 0,
      right: 0,
      left: 0,
      child: Container(
        height: c.maxHeight * 0.5,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.6, -0.8),
            radius: 1.2,
            colors: [color.withOpacity(0.15), Colors.transparent],
          ),
        ),
      ),
    );
  }

  Widget _buildGravel(FishTank tank, BoxConstraints c) {
    final color = _gravelColor(tank.gravelColor);
    return Positioned(
      bottom: 0,
      child: Container(
        width: c.maxWidth,
        height: c.maxHeight * 0.12,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withOpacity(0.8), color],
          ),
        ),
      ),
    );
  }

  Color _gravelColor(String g) {
    switch (g) {
      case 'pink':
        return const Color(0xFFFFB6C1);
      case 'blue':
        return const Color(0xFF87CEEB);
      case 'white':
        return const Color(0xFFECF0F1);
      case 'black':
        return const Color(0xFF2C3E50);
      default:
        return const Color(0xFF8B7355);
    }
  }

  Color _lampColor(String l) {
    switch (l) {
      case 'blue':
        return const Color(0xFF4A90D9);
      case 'purple':
        return const Color(0xFF9B59B6);
      default:
        return const Color(0xFF2ECC71);
    }
  }

  Widget _buildPlant(BoxConstraints c) => Positioned(
    bottom: c.maxHeight * 0.1,
    left: c.maxWidth * 0.08,
    child: CustomPaint(
      size: Size(c.maxWidth * 0.12, c.maxHeight * 0.35),
      painter: _PlantPainter(),
    ),
  );

  Widget _buildSeaweed(BoxConstraints c) => Positioned(
    bottom: c.maxHeight * 0.1,
    left: c.maxWidth * 0.22,
    child: CustomPaint(
      size: Size(c.maxWidth * 0.08, c.maxHeight * 0.3),
      painter: _SeaweedPainter(),
    ),
  );

  Widget _buildCoral(BoxConstraints c) => Positioned(
    bottom: c.maxHeight * 0.1,
    left: c.maxWidth * 0.42,
    child: CustomPaint(
      size: Size(c.maxWidth * 0.18, c.maxHeight * 0.22),
      painter: _CoralPainter(),
    ),
  );

  Widget _buildRock(BoxConstraints c) => Positioned(
    bottom: c.maxHeight * 0.1,
    left: c.maxWidth * 0.58,
    child: CustomPaint(
      size: Size(c.maxWidth * 0.16, c.maxHeight * 0.13),
      painter: _RockPainter(),
    ),
  );

  Widget _buildTunnel(BoxConstraints c) => Positioned(
    bottom: c.maxHeight * 0.1,
    left: c.maxWidth * 0.28,
    child: CustomPaint(
      size: Size(c.maxWidth * 0.26, c.maxHeight * 0.19),
      painter: _TunnelPainter(),
    ),
  );

  Widget _buildCastle(BoxConstraints c) => Positioned(
    bottom: c.maxHeight * 0.1,
    right: c.maxWidth * 0.05,
    child: CustomPaint(
      size: Size(c.maxWidth * 0.22, c.maxHeight * 0.3),
      painter: _CastlePainter(),
    ),
  );

  Widget _buildAnchor(BoxConstraints c) => Positioned(
    bottom: c.maxHeight * 0.12,
    right: c.maxWidth * 0.28,
    child: CustomPaint(
      size: Size(c.maxWidth * 0.1, c.maxHeight * 0.2),
      painter: _AnchorPainter(),
    ),
  );

  Widget _buildLamp(FishTank tank, BoxConstraints c) => Positioned(
    top: 0,
    right: c.maxWidth * 0.08,
    child: CustomPaint(
      size: Size(c.maxWidth * 0.09, c.maxHeight * 0.28),
      painter: _LampPainter(_lampColor(tank.lampColor)),
    ),
  );

  Widget _buildFish(Fish fish, BoxConstraints c) {
    final state = _fishStates[fish.id];
    if (state == null) return const SizedBox();
    final fishW = c.maxWidth * 0.14;
    final fishH = fishW * 0.55;
    final x = state.x * c.maxWidth - fishW / 2;
    final y = state.y * c.maxHeight - fishH / 2;
    return Positioned(
      left: x.clamp(0, c.maxWidth - fishW),
      top: y.clamp(0, c.maxHeight * 0.8 - fishH),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..rotateY(state.facingRight ? 0 : pi)
          ..rotateZ(state.wiggle),
        child: CustomPaint(
          size: Size(fishW, fishH),
          painter: _FishPainter(color: Color(fish.colorValue), type: fish.type),
        ),
      ),
    );
  }

  Widget _buildBubbles(BoxConstraints c) => AnimatedBuilder(
    animation: _bubbleController,
    builder: (_, __) => CustomPaint(
      size: Size(c.maxWidth, c.maxHeight),
      painter: _BubblePainter(_bubbleController.value),
    ),
  );

  Widget _buildWave(BoxConstraints c) => AnimatedBuilder(
    animation: _waveController,
    builder: (_, __) => CustomPaint(
      size: Size(c.maxWidth, 20),
      painter: _WavePainter(_waveController.value),
    ),
  );
}

// ── Fish State ────────────────────────────────────────────────

class _FishState {
  double x, y, targetX, targetY, speed, wiggle;
  bool facingRight;
  _FishState({
    required this.x,
    required this.y,
    required this.targetX,
    required this.targetY,
    required this.speed,
    required this.facingRight,
    required this.wiggle,
  });
}

// ── Painters ──────────────────────────────────────────────────

class _FishPainter extends CustomPainter {
  final Color color;
  final String type;
  _FishPainter({required this.color, required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ลำตัว
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.15, h * 0.5)
        ..quadraticBezierTo(w * 0.5, 0, w * 0.85, h * 0.5)
        ..quadraticBezierTo(w * 0.5, h, w * 0.15, h * 0.5),
      Paint()..color = color,
    );

    // หาง
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.15, h * 0.5)
        ..lineTo(0, h * 0.15)
        ..lineTo(0, h * 0.85)
        ..close(),
      Paint()..color = color.withOpacity(0.8),
    );

    // ลาย nemo
    if (type == 'nemo') {
      final p = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..strokeWidth = w * 0.06
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(w * 0.45, h * 0.12),
        Offset(w * 0.45, h * 0.88),
        p,
      );
      canvas.drawLine(
        Offset(w * 0.65, h * 0.18),
        Offset(w * 0.65, h * 0.82),
        p,
      );
    }

    // ครีบ angel
    if (type == 'angel') {
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.4, h * 0.1)
          ..lineTo(w * 0.5, -h * 0.2)
          ..lineTo(w * 0.7, h * 0.1)
          ..close(),
        Paint()..color = color.withOpacity(0.6),
      );
    }

    // ตา
    canvas.drawCircle(
      Offset(w * 0.72, h * 0.38),
      w * 0.065,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(w * 0.73, h * 0.38),
      w * 0.035,
      Paint()..color = Colors.black87,
    );
  }

  @override
  bool shouldRepaint(_) => true;
}

class _PlantPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size;
    canvas.drawLine(
      Offset(s.width / 2, s.height),
      Offset(s.width / 2, s.height * 0.3),
      Paint()
        ..color = const Color(0xFF2ECC71)
        ..strokeWidth = s.width * 0.15
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      Path()
        ..moveTo(s.width / 2, s.height * 0.6)
        ..quadraticBezierTo(0, s.height * 0.4, s.width * 0.1, s.height * 0.2),
      Paint()
        ..color = const Color(0xFF27AE60)
        ..strokeWidth = s.width * 0.12
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      Path()
        ..moveTo(s.width / 2, s.height * 0.45)
        ..quadraticBezierTo(
          s.width,
          s.height * 0.25,
          s.width * 0.9,
          s.height * 0.05,
        ),
      Paint()
        ..color = const Color(0xFF2ECC71)
        ..strokeWidth = s.width * 0.12
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _SeaweedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1ABC9C)
      ..strokeWidth = size.width * 0.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(size.width / 2, size.height)
        ..cubicTo(
          0,
          size.height * 0.75,
          size.width,
          size.height * 0.5,
          size.width / 2,
          size.height * 0.25,
        )
        ..cubicTo(0, 0, size.width, size.height * 0.1, size.width / 2, 0),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _CoralPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = const Color(0xFFE74C3C)
      ..strokeWidth = w * 0.1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(w / 2, h), Offset(w / 2, h * 0.3), paint);
    canvas.drawLine(Offset(w / 2, h * 0.65), Offset(w * 0.1, h * 0.25), paint);
    canvas.drawLine(Offset(w / 2, h * 0.5), Offset(w * 0.9, h * 0.2), paint);
    canvas.drawLine(Offset(w / 2, h * 0.4), Offset(w * 0.2, h * 0.05), paint);

    final dot = Paint()..color = const Color(0xFFFF6B6B);
    for (final o in [
      Offset(w / 2, h * 0.28),
      Offset(w * 0.08, h * 0.22),
      Offset(w * 0.92, h * 0.17),
      Offset(w * 0.18, h * 0.03),
    ]) {
      canvas.drawCircle(o, w * 0.09, dot);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _RockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawOval(
      Rect.fromLTWH(0, h * 0.25, w * 0.68, h * 0.75),
      Paint()..color = const Color(0xFF7F8C8D),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.48, h * 0.45, w * 0.52, h * 0.55),
      Paint()..color = const Color(0xFF95A5A6),
    );
    // highlight
    canvas.drawOval(
      Rect.fromLTWH(w * 0.12, h * 0.28, w * 0.25, h * 0.18),
      Paint()..color = Colors.white.withOpacity(0.15),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _TunnelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // ตัวอุโมงค์
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0, h * 0.3, w, h * 0.7),
        topLeft: Radius.circular(w * 0.5),
        topRight: Radius.circular(w * 0.5),
      ),
      Paint()..color = const Color(0xFF7F8C8D),
    );
    // ช่องทาง
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h * 0.55),
        width: w * 0.55,
        height: h * 0.48,
      ),
      Paint()..color = const Color(0xFF1A2634),
    );
    // ขอบบน
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(w * 0.05, h * 0.27, w * 0.9, h * 0.08),
        topLeft: Radius.circular(w * 0.5),
        topRight: Radius.circular(w * 0.5),
      ),
      Paint()..color = const Color(0xFF95A5A6),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _CastlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..color = const Color(0xFFBDC3C7);
    canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.4, w * 0.8, h * 0.6), paint);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.2, w * 0.3, h * 0.5), paint);
    canvas.drawRect(Rect.fromLTWH(w * 0.7, h * 0.2, w * 0.3, h * 0.5), paint);
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.2)
        ..lineTo(w * 0.15, 0)
        ..lineTo(w * 0.3, h * 0.2)
        ..close(),
      Paint()..color = const Color(0xFF95A5A6),
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.7, h * 0.2)
        ..lineTo(w * 0.85, 0)
        ..lineTo(w, h * 0.2)
        ..close(),
      Paint()..color = const Color(0xFF95A5A6),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.35, h * 0.65, w * 0.3, h * 0.35),
        Radius.circular(w * 0.15),
      ),
      Paint()..color = const Color(0xFF7F8C8D),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _AnchorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = const Color(0xFFBDC3C7)
      ..strokeWidth = w * 0.14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    // แกน
    canvas.drawLine(Offset(w / 2, h * 0.18), Offset(w / 2, h * 0.85), paint);
    // คาน
    canvas.drawLine(
      Offset(w * 0.15, h * 0.3),
      Offset(w * 0.85, h * 0.3),
      paint,
    );
    // แขนซ้าย
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.2, h * 0.72),
        width: w * 0.38,
        height: h * 0.28,
      ),
      3.14,
      3.14 / 2,
      false,
      paint,
    );
    // แขนขวา
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.8, h * 0.72),
        width: w * 0.38,
        height: h * 0.28,
      ),
      0,
      3.14 / 2,
      false,
      paint,
    );
    // วงแหวนหัว
    canvas.drawCircle(
      Offset(w / 2, h * 0.1),
      w * 0.11,
      Paint()
        ..color = const Color(0xFFBDC3C7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.12,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _LampPainter extends CustomPainter {
  final Color color;
  _LampPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // สาย
    canvas.drawLine(
      Offset(w / 2, 0),
      Offset(w / 2, h * 0.45),
      Paint()
        ..color = Colors.grey.shade400
        ..strokeWidth = w * 0.1,
    );
    // โคม
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.1, h * 0.45)
        ..lineTo(0, h * 0.72)
        ..lineTo(w, h * 0.72)
        ..lineTo(w * 0.9, h * 0.45)
        ..close(),
      Paint()..color = color,
    );
    // แสงด้านล่าง
    canvas.drawCircle(
      Offset(w / 2, h * 0.72),
      w * 0.7,
      Paint()
        ..color = color.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _BubblePainter extends CustomPainter {
  final double progress;
  _BubblePainter(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final positions = [0.2, 0.5, 0.75];
    for (int i = 0; i < positions.length; i++) {
      final offset = (progress + i * 0.33) % 1.0;
      canvas.drawCircle(
        Offset(size.width * positions[i], size.height * (1.0 - offset * 0.9)),
        3.0 + i * 2.0,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

class _WavePainter extends CustomPainter {
  final double progress;
  _WavePainter(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      path.lineTo(
        x,
        sin((x / size.width * 2 * pi) + (progress * 2 * pi)) *
                size.height *
                0.4 +
            size.height * 0.5,
      );
    }
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_) => true;
}