// ไฟล์: lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/deck_provider.dart';
import 'deck_editor_screen.dart';
import '../services/audio_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showTutorial(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
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
            const Expanded(child: _TutorialContent()),
          ],
        ),
      ),
    );
  }

  void _showCreateDeckModal(BuildContext context, DeckProvider deckProvider) {
    final titleCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'สร้างสำรับใหม่ ✨',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // hint: สีสำรับมาจาก theme
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFA3C9A8).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Text('🎨', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'สีสำรับจะตามธีมการ์ดที่เลือก\nตั้งค่าได้ในหน้า "ปรับแต่งสำรับ"',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: titleCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'ชื่อสำรับ',
                  hintText: 'เช่น ภาษาอังกฤษ, คณิตศาสตร์',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA3C9A8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    final name = titleCtrl.text.trim();
                    deckProvider.addDeck(name.isEmpty ? 'สำรับใหม่ 🌟' : name);
                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    'สร้างสำรับ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    DeckProvider deckProvider,
    String deckId,
    String deckTitle,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ลบสำรับ 🗑️'),
        content: Text(
          'ต้องการลบ "$deckTitle" ใช่ไหม?\nการ์ดทั้งหมดจะหายไปด้วยนะ',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              deckProvider.deleteDeck(deckId);
              Navigator.pop(context);
            },
            child: const Text('ลบเลย', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 🆕 Bottom sheet สำหรับตั้งค่า Icon และ Card Theme ของสำรับ
  void _showDeckCustomizeSheet(
    BuildContext context,
    DeckProvider provider,
    String deckId,
    String currentIconId,
    String currentThemeId,
  ) {
    // ✅ ย้าย state ออกมานอก builder เพื่อให้ setSheet ทำงานถูกต้อง
    String selectedIcon = currentIconId;
    String selectedTheme = currentThemeId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheet) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            maxChildSize: 0.92,
            builder: (_, scrollCtrl) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: ListView(
                controller: scrollCtrl,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const Text(
                    'ปรับแต่งสำรับ 🎨',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // ── ไอคอนสำรับ ─────────────────────────────
                  const Text(
                    'ไอคอนสำรับ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: DeckProvider.deckIconCatalog.map((icon) {
                      final isUnlocked = provider.user.unlockedDeckIcons
                          .contains(icon['id']);
                      final isSelected = selectedIcon == icon['id'];

                      return GestureDetector(
                        onTap: () {
                          if (isUnlocked) {
                            setSheet(() => selectedIcon = icon['id'] as String);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'ยังไม่ได้ปลดล็อก "${icon['emoji']} ${icon['name']}" '
                                  '— ไปซื้อในร้านค้าก่อนนะ 🛍️',
                                ),
                              ),
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFA3C9A8).withOpacity(0.2)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFA3C9A8)
                                  : Colors.grey.withOpacity(0.25),
                              width: isSelected ? 2.5 : 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  icon['emoji'] as String,
                                  style: TextStyle(
                                    fontSize: 26,
                                    color: isUnlocked
                                        ? null
                                        : Colors.black.withOpacity(0.25),
                                  ),
                                ),
                              ),
                              if (!isUnlocked)
                                Positioned(
                                  bottom: 2,
                                  right: 4,
                                  child: Icon(
                                    Icons.lock,
                                    size: 12,
                                    color: Colors.grey[400],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // ── ธีมการ์ด ────────────────────────────────
                  const Text(
                    'ธีมการ์ด',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: DeckProvider.cardThemeCatalog.map((theme) {
                      final isUnlocked = provider.user.unlockedCardThemes
                          .contains(theme['id']);
                      final isSelected = selectedTheme == theme['id'];
                      final accentColor = Color(theme['accentColor'] as int);
                      final frontColor = Color(theme['frontColor'] as int);

                      return GestureDetector(
                        onTap: () {
                          if (isUnlocked) {
                            setSheet(
                              () => selectedTheme = theme['id'] as String,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'ยังไม่ได้ปลดล็อกธีม "${theme['emoji']} ${theme['name']}" '
                                  '— ไปซื้อในร้านค้าก่อนนะ 🛍️',
                                ),
                              ),
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 80,
                          height: 60,
                          decoration: BoxDecoration(
                            color: frontColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? accentColor
                                  : Colors.grey.withOpacity(0.3),
                              width: isSelected ? 2.5 : 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      theme['emoji'] as String,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      theme['name'] as String,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: accentColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isUnlocked)
                                Positioned(
                                  bottom: 2,
                                  right: 4,
                                  child: Icon(
                                    Icons.lock,
                                    size: 12,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              if (isSelected)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: accentColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),

                  // ── ปุ่มบันทึก ─────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA3C9A8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        provider.applyDeckIcon(deckId, selectedIcon);
                        provider.applyCardTheme(deckId, selectedTheme);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('บันทึกการตั้งค่าแล้ว! 🎨'),
                          ),
                        );
                      },
                      child: const Text(
                        'บันทึก',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deckProvider = Provider.of<DeckProvider>(context);
    final user = deckProvider.user;

    final filteredDecks = _searchQuery.isEmpty
        ? deckProvider.decks
        : deckProvider.decks
              .where(
                (d) =>
                    d.title.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library 📚'),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFA3C9A8).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFA3C9A8)),
            ),
            child: Text(
              'Lv. ${user.level}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.help_outline_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: 'Tutorial',
            onPressed: () => _showTutorial(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'ค้นหาสำรับ...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).cardTheme.color ?? Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: filteredDecks.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🔍', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      _searchQuery.isEmpty
                          ? 'ยังไม่มีสำรับ\nกด + เพื่อสร้างสำรับแรก!'
                          : 'ไม่พบสำรับ "$_searchQuery"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: filteredDecks.length,
                itemBuilder: (context, index) {
                  final deck = filteredDecks[index];
                  final total = deck.cards.length;
                  final remembered = deck.rememberedIds.length;
                  final progress = total > 0 ? remembered / total : 0.0;

                  // 🆕 ดึง icon emoji จาก deckIconId
                  final iconData = DeckProvider.getDeckIconData(
                    deck.deckIconId,
                  );
                  final iconEmoji = iconData['emoji'] as String;

                  // 🆕 ดึง accent color จาก cardTheme สำหรับ border
                  final themeData = DeckProvider.getCardThemeData(
                    deck.cardTheme,
                  );
                  final themeAccent = Color(themeData['accentColor'] as int);
                  final isCustomTheme = deck.cardTheme != 'default';

                  return Card(
                    // 🆕 ถ้ามี theme พิเศษ ใส่ border แสดงให้รู้
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: isCustomTheme
                          ? BorderSide(
                              color: themeAccent.withOpacity(0.4),
                              width: 1.5,
                            )
                          : BorderSide.none,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeckEditorScreen(deckId: deck.id),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // ── เนื้อหาการ์ด ──────────────────────
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 🆕 แสดง Emoji Icon แทน Icons.style เดิม
                                Text(
                                  iconEmoji,
                                  style: const TextStyle(fontSize: 44),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  deck.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$total Cards',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 8,
                                    backgroundColor: Colors.grey[200],
                                    color: Color(deck.colorValue),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  total == 0
                                      ? 'ยังไม่มีการ์ด'
                                      : '$remembered/$total ใบ',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ── ปุ่ม ⋮ มุมขวาบน ───────────────────
                          Positioned(
                            top: 4,
                            right: 4,
                            child: PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                size: 20,
                                color: Colors.grey[400],
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _showDeleteDialog(
                                    context,
                                    deckProvider,
                                    deck.id,
                                    deck.title,
                                  );
                                } else if (value == 'customize') {
                                  // 🆕
                                  _showDeckCustomizeSheet(
                                    context,
                                    deckProvider,
                                    deck.id,
                                    deck.deckIconId,
                                    deck.cardTheme,
                                  );
                                }
                              },
                              itemBuilder: (_) => [
                                // 🆕 ตัวเลือกปรับแต่งสำรับ
                                PopupMenuItem(
                                  value: 'customize',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.palette_outlined,
                                        color: Color(0xFFA3C9A8),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('ปรับแต่งสำรับ'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'ลบสำรับ',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 🆕 badge theme emoji มุมซ้ายบน (ถ้าไม่ใช่ default)
                          if (isCustomTheme)
                            Positioned(
                              top: 8,
                              left: 10,
                              child: Text(
                                themeData['emoji'] as String,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFA3C9A8),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          AudioService.instance.playBtnClick();
          _showCreateDeckModal(context, deckProvider);
        },
      ),
    );
  }
}

// ── Tutorial Content ─────────────────────────────────────────────

class _TutorialContent extends StatefulWidget {
  const _TutorialContent();

  @override
  State<_TutorialContent> createState() => _TutorialContentState();
}

class _TutorialContentState extends State<_TutorialContent> {
  final PageController _ctrl = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': '📚',
      'title': 'สร้างสำรับการ์ด',
      'desc':
          '• กด + เพื่อสร้างสำรับใหม่\n• ตั้งชื่อสำรับได้ตามใจ\n• เพิ่มการ์ดได้ 10-30 ใบ\n• ใส่รูปภาพในการ์ดได้',
      'color': const Color(0xFFB5EAD7),
    },
    {
      'icon': '🎨',
      'title': 'ปรับแต่งสำรับ',
      'desc':
          '• กด ⋮ ที่การ์ดสำรับ → ปรับแต่งสำรับ\n• เลือกธีมการ์ด = สีสำรับเปลี่ยนตาม\n• ธีมพิเศษ: 🎄🧧🎃🌊🌸\n• เปลี่ยนไอคอนสำรับได้ (ซื้อจากร้านค้า)',
      'color': const Color(0xFFFFD3B6),
    },
    {
      'icon': '🎮',
      'title': 'กฏการเล่น',
      'desc':
          '• สำรับต้องมี 10-30 ใบจึงจะเล่นได้\n• แตะการ์ดเพื่อพลิกดูคำตอบ\n• กด ✓ จำได้ หรือ ✗ ลืม\n• 90%+ = ⭐⭐⭐  |  70%+ = ⭐⭐  |  50%+ = ⭐',
      'color': const Color(0xFFFFF3B0),
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
          '• ธีมการ์ด = สีสำรับ (เขียว/ฟ้า/ชมพู...)\n• ไอคอนสำรับ — ไอคอนในหน้าหลัก\n• กรอบโปรไฟล์ — ตกแต่งโปรไฟล์\n• ตู้ปลา — ปลา, อาหาร, ของตกแต่ง',
      'color': const Color(0xFFC7CEEA),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          'คู่มือการใช้งาน 📖',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: PageView.builder(
            controller: _ctrl,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) {
              final page = _pages[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
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
                          style: const TextStyle(fontSize: 44),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      page['title'] as String,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
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
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _ctrl.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('← ก่อนหน้า'),
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _ctrl.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA3C9A8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'เข้าใจแล้ว ✓'
                        : 'ถัดไป →',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
