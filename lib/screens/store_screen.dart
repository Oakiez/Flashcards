import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/deck_provider.dart';
import '../services/audio_service.dart';
import '../widgets/frame_painter.dart';
import '../widgets/card_theme_painter.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  final Map<String, int> avatarFrames = const {
    'กรอบไม้ธรรมชาติ 🪵': 200,
    'กรอบทองคำขาว 💎': 500,
    'กรอบออร่าพาสเทล ✨': 350,
    'กรอบดาวทอง ⭐': 300,
    'กรอบแมว 🐱': 400,
    'กรอบไฟฟ้า ⚡': 350,
    'กรอบเพชร 💎✨': 450,
    'กรอบไฟ 🔥': 400,
    'กรอบเปลวสี 🌈': 500,
  };

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DeckProvider>(context);
    final user = provider.user;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cozy Store 🛍️'),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '💰 ${user.coins}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFFA3C9A8),
            labelColor: null,
            tabs: [
              Tab(text: 'ธีมการ์ด 🃏'),
              Tab(text: 'ไอคอนสำรับ'),
              Tab(text: 'กรอบ & ตู้ปลา'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCardThemeTab(context, provider),
            _buildDeckIconTab(context, provider),
            _buildItemAndFishTab(context, provider),
          ],
        ),
      ),
    );
  }

  // ── ธีมการ์ด ──────────────────────────────────────────

  Widget _buildCardThemeTab(BuildContext context, DeckProvider provider) {
    final themes = DeckProvider.cardThemeCatalog;
    final unlockedThemes = provider.user.unlockedCardThemes;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFA3C9A8).withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFA3C9A8).withOpacity(0.3)),
          ),
          child: const Text(
            '🃏 ธีมการ์ด = สีของสำรับ\nเลือกธีมแล้วสีสำรับจะเปลี่ยนตามอัตโนมัติ\nไปตั้งค่าที่หน้าแก้ไขสำรับ (กด ⋮ → ปรับแต่งสำรับ)',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.85,
          children: themes.map((theme) {
            final isUnlocked = unlockedThemes.contains(theme['id']);
            final price = theme['price'] as int;
            final frontColor = Color(theme['frontColor'] as int);
            final backColor = Color(theme['backColor'] as int);
            final accentColor = Color(theme['accentColor'] as int);

            return GestureDetector(
              onTap: isUnlocked
                  ? null
                  : () => _confirmBuyCardTheme(context, provider, theme),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isUnlocked
                        ? accentColor
                        : Colors.grey.withOpacity(0.3),
                    width: isUnlocked ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 20,
                            child: _miniCard(
                              backColor,
                              accentColor,
                              isBack: true,
                              themeId: theme['id'] as String,
                            ),
                          ),
                          Positioned(
                            right: 20,
                            child: _miniCard(
                              frontColor,
                              accentColor,
                              isBack: false,
                              themeId: theme['id'] as String,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${theme['emoji']} ${theme['name']}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'ปลดล็อกแล้ว ✓',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            size: 13,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            price == 0 ? 'ฟรี' : '💰 $price',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _miniCard(
    Color bg,
    Color accent, {
    required bool isBack,
    String themeId = 'default',
  }) {
    return Container(
      width: 54,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: CardThemePainter(
          themeId: themeId,
          bg: bg,
          accent: accent,
          isBack: isBack,
        ),
      ),
    );
  }

  void _confirmBuyCardTheme(
    BuildContext context,
    DeckProvider provider,
    Map<String, dynamic> theme,
  ) {
    final price = theme['price'] as int;
    final name = '${theme['emoji']} ${theme['name']}';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ปลดล็อกธีมการ์ด 🃏'),
        content: Text('ต้องการซื้อธีม "$name"\nราคา $price เหรียญ ใช่ไหม?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA3C9A8),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final ok = provider.buyCardTheme(theme['id'] as String);
              if (ok) AudioService.instance.playPurchase();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok ? 'ปลดล็อกธีม $name แล้ว! 🎉' : 'เหรียญไม่พอจ้า 🥲',
                  ),
                ),
              );
            },
            child: const Text('ยืนยัน', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── ไอคอนสำรับ ────────────────────────────────────────

  Widget _buildDeckIconTab(BuildContext context, DeckProvider provider) {
    final icons = DeckProvider.deckIconCatalog;
    final unlockedIcons = provider.user.unlockedDeckIcons;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFA3C9A8).withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFA3C9A8).withOpacity(0.3)),
          ),
          child: const Text(
            '🏷️ ไอคอนสำรับ เปลี่ยนไอคอนที่แสดงในหน้าหลัก\nซื้อแล้วไปตั้งค่าที่หน้าแก้ไขสำรับ',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
          children: icons.map((icon) {
            final isUnlocked = unlockedIcons.contains(icon['id']);
            final price = icon['price'] as int;
            return GestureDetector(
              onTap: isUnlocked
                  ? null
                  : () => _confirmBuyDeckIcon(context, provider, icon),
              child: Container(
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? const Color(0xFFA3C9A8).withOpacity(0.12)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isUnlocked
                        ? const Color(0xFFA3C9A8)
                        : Colors.grey.withOpacity(0.25),
                    width: isUnlocked ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      icon['emoji'] as String,
                      style: const TextStyle(fontSize: 34),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      icon['name'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (isUnlocked)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFFA3C9A8),
                        size: 16,
                      )
                    else
                      Text(
                        price == 0 ? 'ฟรี' : '💰 $price',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _confirmBuyDeckIcon(
    BuildContext context,
    DeckProvider provider,
    Map<String, dynamic> icon,
  ) {
    final price = icon['price'] as int;
    final name = '${icon['emoji']} ${icon['name']}';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ปลดล็อกไอคอน 🏷️'),
        content: Text('ต้องการซื้อไอคอน "$name"\nราคา $price เหรียญ ใช่ไหม?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA3C9A8),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final ok = provider.buyDeckIcon(icon['id'] as String);
              if (ok) AudioService.instance.playPurchase();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok ? 'ปลดล็อกไอคอน $name แล้ว! 🎉' : 'เหรียญไม่พอจ้า 🥲',
                  ),
                ),
              );
            },
            child: const Text('ยืนยัน', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── กรอบ & ตู้ปลา ─────────────────────────────────────

  Widget _buildItemAndFishTab(BuildContext context, DeckProvider provider) {
    return _InnerFishItemTab(
      itemTabContent: _buildItemTab(context, provider),
      fishTabContent: _buildFishTab(context, provider),
    );
  }

  // ── กรอบโปรไฟล์ ──────────────────────────────────────────────

  Widget _buildItemTab(BuildContext context, DeckProvider provider) {
    final user = provider.user;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'กรอบโปรไฟล์พิเศษ 🖼️',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
          children: avatarFrames.entries.map((entry) {
            final isUnlocked = user.unlockedFrames.contains(entry.key);
            final isEquipped = user.selectedFrame == entry.key;
            return Container(
              decoration: BoxDecoration(
                color: isEquipped
                    ? const Color(0xFFA3C9A8).withOpacity(0.15)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isEquipped
                      ? const Color(0xFFA3C9A8)
                      : Colors.grey.withOpacity(0.2),
                  width: isEquipped ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: const Color(0xFFA3C9A8),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        SizedBox(
                          width: 82,
                          height: 82,
                          child: CustomPaint(painter: FramePainter(entry.key)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.key,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUnlocked ? 'มีแล้ว ✨' : '💰 ${entry.value}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isUnlocked
                          ? const Color(0xFFA3C9A8)
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEquipped
                            ? Colors.grey
                            : const Color(0xFFA3C9A8),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isEquipped
                          ? null
                          : () {
                              if (isUnlocked) {
                                provider.updateSelectedFrame(entry.key);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('สวมใส่กรอบรูปเรียบร้อย! ✨'),
                                  ),
                                );
                              } else {
                                _confirmBuyFrame(
                                  context,
                                  provider,
                                  entry.key,
                                  entry.value,
                                );
                              }
                            },
                      child: Text(
                        isEquipped
                            ? 'ใช้อยู่'
                            : (isUnlocked ? 'ใช้งาน' : 'ซื้อ'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _confirmBuyFrame(
    BuildContext context,
    DeckProvider provider,
    String frameName,
    int price,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการซื้อ 🛍️'),
        content: Text('ต้องการซื้อ "$frameName"\nราคา $price เหรียญ ใช่ไหม?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA3C9A8),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final ok = provider.buyFrame(frameName, price);
              if (ok) AudioService.instance.playPurchase();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok ? 'ซื้อและสวมใส่กรอบเรียบร้อย! 🎉' : 'เหรียญไม่พอจ้า 🥲',
                  ),
                ),
              );
            },
            child: const Text('ยืนยัน', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── ตู้ปลา ────────────────────────────────────────────────────

  Widget _buildFishTab(BuildContext context, DeckProvider provider) {
    final tank = provider.fishTank;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'อาหารปลา 🍤',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'มี ${tank.foodBags} ถุง',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                '1 ถุง = อาหาร +20% | ราคา 💰 30/ถุง',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Text('🍤', style: TextStyle(fontSize: 18)),
                label: const Text(
                  'ซื้ออาหารปลา',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => _showBuyFoodDialog(context, provider),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'ปลา 🐠',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'ปลาในตู้: ${tank.fishes.length}/20 ตัว',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: DeckProvider.fishCatalog.map((fish) {
            final owned = tank.fishes
                .where((f) => f.type == fish['type'])
                .length;
            return _buildFishTile(
              context,
              provider,
              type: fish['type'],
              name: fish['name'],
              color: Color(fish['colorValue'] as int),
              price: fish['price'] as int,
              owned: owned,
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _buildDecorSection(context, provider, '🪨 พื้นกรวด', 'floor'),
        const SizedBox(height: 16),
        _buildDecorSection(context, provider, '🌿 พืชน้ำ', 'plant'),
        const SizedBox(height: 16),
        _buildDecorSection(context, provider, '🏰 โครงสร้าง', 'structure'),
        const SizedBox(height: 16),
        _buildDecorSection(context, provider, '💡 ตะเกียง', 'light'),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDecorSection(
    BuildContext context,
    DeckProvider provider,
    String title,
    String category,
  ) {
    final items = DeckProvider.decorCatalog
        .where((d) => d['category'] == category)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.5,
          children: items.map((decor) {
            final isOwned = _isDecorOwned(
              provider.fishTank,
              decor['type'] as String,
            );
            return GestureDetector(
              onTap: isOwned
                  ? null
                  : () => _confirmBuyDecor(
                      context,
                      provider,
                      decor['type'] as String,
                      decor['name'] as String,
                      decor['price'] as int,
                    ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isOwned
                      ? const Color(0xFFA3C9A8).withOpacity(0.15)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isOwned
                        ? const Color(0xFFA3C9A8)
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        decor['name'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isOwned)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFFA3C9A8),
                        size: 18,
                      )
                    else
                      Text(
                        '💰${decor['price']}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFishTile(
    BuildContext context,
    DeckProvider provider, {
    required String type,
    required String name,
    required Color color,
    required int price,
    required int owned,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 18,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'มี $owned ตัว',
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
                GestureDetector(
                  onTap: () => _showBuyFishDialog(
                    context,
                    provider,
                    type,
                    name,
                    color,
                    price,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA3C9A8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '💰$price',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isDecorOwned(tank, String type) {
    switch (type) {
      case 'plant':
        return tank.hasPlant;
      case 'castle':
        return tank.hasCastle;
      case 'seaweed':
        return tank.hasSeaweed;
      case 'coral':
        return tank.hasCoral;
      case 'tunnel':
        return tank.hasTunnel;
      case 'anchor':
        return tank.hasAnchor;
      case 'rock':
        return tank.hasRock;
      case 'lamp_blue':
        return tank.lampColor == 'blue';
      case 'lamp_purple':
        return tank.lampColor == 'purple';
      case 'lamp_green':
        return tank.lampColor == 'green';
      case 'gravel_brown':
        return tank.gravelColor == 'brown';
      case 'gravel_pink':
        return tank.gravelColor == 'pink';
      case 'gravel_blue':
        return tank.gravelColor == 'blue';
      case 'gravel_white':
        return tank.gravelColor == 'white';
      case 'gravel_black':
        return tank.gravelColor == 'black';
      default:
        return false;
    }
  }

  void _showBuyFishDialog(
    BuildContext context,
    DeckProvider provider,
    String type,
    String name,
    Color color,
    int price,
  ) {
    final ctrl = TextEditingController(text: '1');
    final canAdd = 20 - provider.fishTank.fishes.length;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialog) {
          final qty = int.tryParse(ctrl.text) ?? 1;
          final actualQty = qty.clamp(1, canAdd > 0 ? canAdd : 1);
          final total = price * actualQty;
          final canAfford = provider.user.coins >= total;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('ซื้อ $name 🐠'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  canAdd > 0
                      ? 'ที่ว่างในตู้: $canAdd ตัว'
                      : '⚠️ ตู้เต็มแล้ว! (20/20)',
                  style: TextStyle(
                    color: canAdd > 0 ? Colors.grey : Colors.red,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('จำนวน: '),
                    Expanded(
                      child: TextField(
                        controller: ctrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        enabled: canAdd > 0,
                        onChanged: (_) => setDialog(() {}),
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const Text(' ตัว'),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: canAfford && canAdd > 0
                        ? const Color(0xFFA3C9A8).withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'รวม: 💰 $total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: canAfford && canAdd > 0
                              ? Colors.black
                              : Colors.red,
                        ),
                      ),
                      Text(
                        'มีอยู่: 💰 ${provider.user.coins}',
                        style: TextStyle(
                          color: canAfford ? Colors.grey : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ยกเลิก'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAfford && canAdd > 0
                      ? const Color(0xFFA3C9A8)
                      : Colors.grey,
                ),
                onPressed: canAfford && canAdd > 0 && qty > 0
                    ? () {
                        Navigator.pop(ctx);
                        final result = provider.buyFishBulk(type, actualQty);
                        String msg;
                        if (result.startsWith('partial')) {
                          final got = result.split(':')[1];
                          msg =
                              'ซื้อได้ $got ตัว '
                              '(ตู้เหลือที่ว่างแค่นั้น) 🐠';
                          AudioService.instance.playPurchase();
                        } else if (result.startsWith('success')) {
                          msg = 'ซื้อ $name $actualQty ตัวแล้ว! 🐠';
                          AudioService.instance.playPurchase();
                        } else {
                          msg = 'เหรียญไม่พอ 🥲';
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(msg),
                            backgroundColor: const Color(0xFFA3C9A8),
                          ),
                        );
                      }
                    : null,
                child: const Text(
                  'ซื้อเลย!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBuyFoodDialog(BuildContext context, DeckProvider provider) {
    final ctrl = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialog) {
          final qty = int.tryParse(ctrl.text) ?? 1;
          final safeQty = qty.clamp(1, 999);
          final total = 30 * safeQty;
          final canAfford = provider.user.coins >= total;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('ซื้ออาหารปลา 🍤'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '1 ถุง = อาหาร +20%',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('จำนวน: '),
                    Expanded(
                      child: TextField(
                        controller: ctrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (_) => setDialog(() {}),
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const Text(' ถุง'),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: canAfford
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'รวม: 💰 $total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: canAfford ? Colors.black : Colors.red,
                        ),
                      ),
                      Text(
                        'มีอยู่: 💰 ${provider.user.coins}',
                        style: TextStyle(
                          color: canAfford ? Colors.grey : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ยกเลิก'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAfford ? Colors.orange : Colors.grey,
                ),
                onPressed: canAfford && qty > 0
                    ? () {
                        Navigator.pop(ctx);
                        provider.buyFoodBulk(safeQty);
                        AudioService.instance.playPurchase();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('ซื้ออาหาร $safeQty ถุงแล้ว! 🍤'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    : null,
                child: const Text(
                  'ซื้อเลย!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmBuyDecor(
    BuildContext context,
    DeckProvider provider,
    String type,
    String name,
    int price,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ซื้อของตกแต่ง 🌿'),
        content: Text('ต้องการซื้อ $name\nราคา $price เหรียญ ใช่ไหม?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA3C9A8),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final ok = provider.buyDecor(type);
              if (ok) AudioService.instance.playPurchase();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok ? 'ตกแต่งตู้ปลาแล้ว! 🌿' : 'เหรียญไม่พอจ้า 🥲',
                  ),
                ),
              );
            },
            child: const Text(
              'ซื้อเลย!',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _InnerFishItemTab ─────────────────────────────────────────────

class _InnerFishItemTab extends StatefulWidget {
  final Widget itemTabContent;
  final Widget fishTabContent;
  const _InnerFishItemTab({
    required this.itemTabContent,
    required this.fishTabContent,
  });
  @override
  State<_InnerFishItemTab> createState() => _InnerFishItemTabState();
}

class _InnerFishItemTabState extends State<_InnerFishItemTab>
    with SingleTickerProviderStateMixin {
  late TabController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color:
              Theme.of(context).appBarTheme.backgroundColor ??
              const Color(0xFFFFF9F0),
          child: TabBar(
            controller: _ctrl,
            indicatorColor: const Color(0xFFA3C9A8),
            labelColor: null,
            indicatorSize: TabBarIndicatorSize.tab,
            padding: EdgeInsets.zero,
            tabs: const [
              Tab(text: 'กรอบโปรไฟล์ 🖼️'),
              Tab(text: 'ตู้ปลา 🐠'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _ctrl,
            children: [widget.itemTabContent, widget.fishTabContent],
          ),
        ),
      ],
    );
  }
}
