import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String deckTitle;
  final int totalCards;
  final int remembered;
  final int forgot;
  final int sessionExp;
  final int sessionCoins;
  // ✅ เพิ่ม reviewData
  final List<Map<String, dynamic>> reviewData;

  const ResultScreen({
    super.key,
    required this.deckTitle,
    required this.totalCards,
    required this.remembered,
    required this.forgot,
    required this.sessionExp,
    required this.sessionCoins,
    required this.reviewData, // ✅
  });

  // ✅ คำนวณดาว
  int get stars {
    if (totalCards == 0) return 0;
    final pct = remembered / totalCards * 100;
    if (pct >= 90) return 3;
    if (pct >= 70) return 2;
    if (pct >= 50) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final double percent = totalCards > 0 ? remembered / totalCards : 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'สรุปผลการเรียน 📊',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                deckTitle,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 24),

              // ✅ ดาว
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: i < stars ? Colors.amber : Colors.grey[300],
                      size: 48,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // วงกลม %
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: percent,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey[200],
                      color: stars >= 3
                          ? Colors.amber
                          : stars >= 2
                          ? Theme.of(context).primaryColor
                          : stars >= 1
                          ? Colors.orange
                          : Colors.redAccent,
                    ),
                  ),
                  Text(
                    '${(percent * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // สถิติ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatBox(
                    'จำได้ ✅',
                    '$remembered ใบ',
                    Theme.of(context).primaryColor,
                  ),
                  _buildStatBox('ลืม ❌', '$forgot ใบ', const Color(0xFFE5B299)),
                  _buildStatBox(
                    'ทั้งหมด 📚',
                    '$totalCards ใบ',
                    Colors.blueGrey,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // รางวัล
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'รางวัลที่ได้รอบนี้ 🎁',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          '+ $sessionExp EXP ✨',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '+ $sessionCoins Coins 💰',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ปุ่ม
              Row(
                children: [
                  // ✅ ปุ่ม Review
                  if (reviewData.isNotEmpty)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showReview(context),
                        icon: const Icon(Icons.rate_review_outlined),
                        label: const Text('ดูคำตอบ'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  if (reviewData.isNotEmpty) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'กลับหน้าหลัก',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, ctrl) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'รีวิวคำตอบ 📝',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: reviewData.length,
                itemBuilder: (_, i) {
                  final item = reviewData[i];
                  final remembered = item['remembered'] as bool;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: remembered
                            ? Theme.of(context).primaryColor
                            : Colors.redAccent,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                remembered ? Icons.check_circle : Icons.cancel,
                                color: remembered
                                    ? Theme.of(context).primaryColor
                                    : Colors.redAccent,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                remembered ? 'จำได้ ✅' : 'ลืม ❌',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: remembered
                                      ? Theme.of(context).primaryColor
                                      : Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Text(
                            '❓ ${item['question']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '💡 ${item['answer']}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}