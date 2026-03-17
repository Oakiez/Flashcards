import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _ctrl = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': '👋',
      'title': 'ยินดีต้อนรับสู่\nCozy Flashcards!',
      'desc':
          'แอปช่วยจำที่ทำให้การเรียนรู้สนุกและผ่อนคลาย\nสร้างสำรับการ์ดของคุณเองได้ง่ายๆ',
      'color': const Color(0xFFA3C9A8),
    },
    {
      'icon': '📚',
      'title': 'สร้างสำรับการ์ด',
      'desc':
          '• กด + เพื่อสร้างสำรับใหม่\n• ตั้งชื่อและเลือกสีธีมได้\n• เพิ่มการ์ดได้ไม่จำกัด (แนะนำ 10-30 ใบ)\n• ใส่รูปภาพในการ์ดได้',
      'color': const Color(0xFFB5EAD7),
    },
    {
      'icon': '🎮',
      'title': 'กฏการเล่น',
      'desc':
          '• สำรับต้องมี 10-30 ใบจึงจะเล่นได้\n• แตะการ์ดเพื่อพลิกดูคำตอบ\n• กด ✓ จำได้ หรือ ✗ ลืม\n• 90%+ = ⭐⭐⭐  |  70%+ = ⭐⭐  |  50%+ = ⭐',
      'color': const Color(0xFFFFD3B6),
    },
    {
      'icon': '💰',
      'title': 'รางวัลและเหรียญ',
      'desc':
          '• จำการ์ดได้ = +15 EXP +10 Coins\n• สะสม EXP เพื่อ Level Up\n• นำ Coins ไปซื้อของในร้านค้า\n• เล่นทุกวันเพื่อสะสม Streak 🔥',
      'color': const Color(0xFFFFF3B0),
    },
    {
      'icon': '🐠',
      'title': 'ตู้ปลา',
      'desc':
          '• ซื้อปลาจากร้านค้าด้วย Coins\n• อย่าลืมให้อาหารปลาทุก 8 ชั่วโมง\n• ถ้าอาหารหมด ปลาจะตาย!\n• ตกแต่งตู้ปลาได้ตามใจชอบ 🌿',
      'color': const Color(0xFFB5EAD7),
    },
    {
      'icon': '🛍️',
      'title': 'ร้านค้า',
      'desc':
          '• สีสำรับ — ปรับแต่งสีของสำรับ\n• กรอบโปรไฟล์ — ใส่กรอบรูปสวยๆ\n• ตู้ปลา — ปลา, อาหาร, ของตกแต่ง\n• ยิ่งเล่นมาก ยิ่งมี Coins เยอะ!',
      'color': const Color(0xFFC7CEEA),
    },
    {
      'icon': '🌟',
      'title': 'พร้อมแล้ว!\nไปเริ่มเลย',
      'desc':
          'สร้างสำรับแรกของคุณและเริ่มเดินทาง\nสู่การเรียนรู้แบบ Cozy ได้เลย!',
      'color': const Color(0xFFA3C9A8),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('ข้าม', style: TextStyle(color: Colors.grey)),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon circle
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: (page['color'] as Color).withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: page['color'] as Color,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              page['icon'] as String,
                              style: const TextStyle(fontSize: 52),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        Text(
                          page['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A4A4A),
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (page['color'] as Color).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: (page['color'] as Color).withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            page['desc'] as String,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF4A4A4A),
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == i ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? const Color(0xFFA3C9A8)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA3C9A8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _ctrl.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _finish();
                    }
                  },
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? '🚀 เริ่มใช้งานเลย!'
                        : 'ถัดไป →',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', false);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
}