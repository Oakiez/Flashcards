import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameRulesDialog extends StatelessWidget {
  final VoidCallback onStart;

  const GameRulesDialog({super.key, required this.onStart});

  static Future<void> showIfNeeded(
    BuildContext context,
    VoidCallback onStart,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('gameRulesShown') ?? false;

    if (!shown && context.mounted) {
      await prefs.setBool('gameRulesShown', true);
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => GameRulesDialog(onStart: onStart),
        );
      }
    } else {
      onStart();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Row(
        children: [
          Text('🎮', style: TextStyle(fontSize: 24)),
          SizedBox(width: 8),
          Text('กฏการเล่น', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRule('📋', 'จำนวนการ์ด', 'สำรับต้องมี 10-30 ใบจึงจะเล่นได้'),
            _buildRule(
              '👆',
              'วิธีเล่น',
              'แตะการ์ดเพื่อพลิกดูคำตอบ จากนั้นเลือก "จำได้" หรือ "ลืม"',
            ),
            _buildRule(
              '⭐',
              'เกณฑ์ดาว',
              '90%+ = ⭐⭐⭐\n70%+ = ⭐⭐\n50%+ = ⭐\nต่ำกว่า 50% = ไม่ได้ดาว',
            ),
            _buildRule('💰', 'รางวัล', 'จำได้ทุกใบ = +15 EXP +10 Coins'),
            _buildRule(
              '⏸️',
              'การหยุดชั่วคราว',
              'กดปุ่ม Pause ที่มุมบนขวาระหว่างเล่นได้',
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA3C9A8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              onStart();
            },
            child: const Text(
              'เข้าใจแล้ว เริ่มเล่นเลย! 🚀',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRule(String icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
