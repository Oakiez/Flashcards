// ไฟล์: lib/providers/deck_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/deck_model.dart';
import '../services/audio_service.dart';

// ── App Theme Catalog ─────────────────────────────────────────────

/// App theme ที่ให้เลือกได้ในหน้าตั้งค่า
class AppThemeOption {
  final String id;
  final String name;
  final String emoji;
  final Color primaryColor; // สี AppBar, BottomNav selected, ปุ่ม
  final Color bgColor; // สีพื้นหลัง Scaffold

  const AppThemeOption({
    required this.id,
    required this.name,
    required this.emoji,
    required this.primaryColor,
    required this.bgColor,
  });
}

const List<AppThemeOption> kAppThemes = [
  AppThemeOption(
    id: 'green',
    name: 'Cozy Green',
    emoji: '🌿',
    primaryColor: Color(0xFFA3C9A8),
    bgColor: Color(0xFFFFF9F0),
  ),
  AppThemeOption(
    id: 'blue',
    name: 'Ocean Blue',
    emoji: '🌊',
    primaryColor: Color(0xFF4A90D9),
    bgColor: Color(0xFFF0F7FF),
  ),
  AppThemeOption(
    id: 'purple',
    name: 'Lavender',
    emoji: '💜',
    primaryColor: Color(0xFF9B6FD4),
    bgColor: Color(0xFFF8F4FF),
  ),
  AppThemeOption(
    id: 'pink',
    name: 'Cherry Blossom',
    emoji: '🌸',
    primaryColor: Color(0xFFE07FA0),
    bgColor: Color(0xFFFFF0F5),
  ),
  AppThemeOption(
    id: 'orange',
    name: 'Sunset',
    emoji: '🌅',
    primaryColor: Color(0xFFE8853A),
    bgColor: Color(0xFFFFFAF0),
  ),
  AppThemeOption(
    id: 'dark',
    name: 'Midnight',
    emoji: '🌙',
    primaryColor: Color(0xFF7EB8C9),
    bgColor: Color(0xFF1A1A2E),
  ),
];

// ── ThemeProvider ─────────────────────────────────────────────────

class ThemeProvider with ChangeNotifier {
  String _themeId = 'green';

  String get themeId => _themeId;

  AppThemeOption get current => kAppThemes.firstWhere(
    (t) => t.id == _themeId,
    orElse: () => kAppThemes.first,
  );

  Color get primaryColor => current.primaryColor;
  Color get bgColor => current.bgColor;
  bool get isDark => _themeId == 'dark';

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeId = prefs.getString('appThemeId') ?? 'green';
    notifyListeners();
  }

  Future<void> setTheme(String id) async {
    _themeId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appThemeId', id);
    notifyListeners();
  }
}

class DeckProvider with ChangeNotifier {
  bool fishDiedFromHunger = false;
  FishTank fishTank = FishTank();

  UserProfile user = UserProfile(
    name: 'นักเรียนใหม่ 🌱',
    level: 1,
    coins: 0,
    exp: 0,
  );

  List<Deck> _decks = [];
  List<Deck> get decks => _decks;

  DeckProvider() {
    _loadData();
  }

  // ── Catalogs ──────────────────────────────────────────────────

  /// Card Theme catalog — themeId, label, emoji, ราคา
  /// 'default' ฟรีและ unlock แล้วเสมอ
  static const List<Map<String, dynamic>> cardThemeCatalog = [
    {
      'id': 'default',
      'name': 'ธรรมดา',
      'emoji': '🃏',
      'price': 0,
      // front/back สีที่ใช้วาด preview (ใช้ใน store)
      'frontColor': 0xFFFFFFFF,
      'backColor': 0xFFF0FFF4,
      'accentColor': 0xFFA3C9A8,
    },
    {
      'id': 'ocean',
      'name': 'มหาสมุทร',
      'emoji': '🌊',
      'price': 150,
      'frontColor': 0xFFE3F2FD,
      'backColor': 0xFFBBDEFB,
      'accentColor': 0xFF1565C0,
    },
    {
      'id': 'sakura',
      'name': 'ซากุระ',
      'emoji': '🌸',
      'price': 150,
      'frontColor': 0xFFFCE4EC,
      'backColor': 0xFFF8BBD9,
      'accentColor': 0xFFAD1457,
    },
    {
      'id': 'christmas',
      'name': 'คริสต์มาส',
      'emoji': '🎄',
      'price': 200,
      'frontColor': 0xFFFFEBEE,
      'backColor': 0xFFE8F5E9,
      'accentColor': 0xFFB71C1C,
    },
    {
      'id': 'chinese_new_year',
      'name': 'ตรุษจีน',
      'emoji': '🧧',
      'price': 200,
      'frontColor': 0xFFFFF8E1,
      'backColor': 0xFFFFECB3,
      'accentColor': 0xFFE65100,
    },
    {
      'id': 'halloween',
      'name': 'ฮัลโลวีน',
      'emoji': '🎃',
      'price': 200,
      'frontColor': 0xFFFFF3E0,
      'backColor': 0xFFEDE7F6,
      'accentColor': 0xFF4A148C,
    },
  ];

  /// Deck Icon catalog — iconId, emoji, ราคา
  /// 'default' ฟรีและ unlock แล้วเสมอ
  static const List<Map<String, dynamic>> deckIconCatalog = [
    {'id': 'default', 'emoji': '📚', 'name': 'หนังสือ', 'price': 0},
    {'id': 'star', 'emoji': '⭐', 'name': 'ดาว', 'price': 80},
    {'id': 'heart', 'emoji': '❤️', 'name': 'หัวใจ', 'price': 80},
    {'id': 'flame', 'emoji': '🔥', 'name': 'เปลวไฟ', 'price': 100},
    {'id': 'crown', 'emoji': '👑', 'name': 'มงกุฎ', 'price': 150},
    {'id': 'diamond', 'emoji': '💎', 'name': 'เพชร', 'price': 150},
    {'id': 'rocket', 'emoji': '🚀', 'name': 'จรวด', 'price': 200},
    {'id': 'cat', 'emoji': '🐱', 'name': 'แมว', 'price': 200},
    {'id': 'brain', 'emoji': '🧠', 'name': 'สมอง', 'price': 250},
    {'id': 'trophy', 'emoji': '🏆', 'name': 'ถ้วยรางวัล', 'price': 300},
  ];

  /// Title catalog — id, label (แสดงใต้ชื่อใน Profile), emoji, ราคา, levelRequired
  /// levelRequired = 0 หมายถึงซื้อได้เลยไม่ต้อง unlock ด้วย level
  static const List<Map<String, dynamic>> titleCatalog = [
    // ── ฟรี / เริ่มต้น ──────────────────────────────
    {
      'id': 'newcomer',
      'label': 'นักเรียนใหม่',
      'emoji': '🌱',
      'price': 0,
      'levelRequired': 0,
      'color': 0xFF78B478,
    },
    // ── ซื้อได้เลย ───────────────────────────────────
    {
      'id': 'bookworm',
      'label': 'หนอนหนังสือ',
      'emoji': '📚',
      'price': 100,
      'levelRequired': 0,
      'color': 0xFF6B9BD2,
    },
    {
      'id': 'curious',
      'label': 'จิตใจใฝ่รู้',
      'emoji': '🔍',
      'price': 150,
      'levelRequired': 0,
      'color': 0xFF9B8EC4,
    },
    {
      'id': 'focused',
      'label': 'สมาธิแน่วแน่',
      'emoji': '🎯',
      'price': 200,
      'levelRequired': 0,
      'color': 0xFFD4854A,
    },
    // ── ต้อง Level 5+ ────────────────────────────────
    {
      'id': 'scholar',
      'label': 'นักวิชาการ',
      'emoji': '🎓',
      'price': 300,
      'levelRequired': 5,
      'color': 0xFF5B8DB8,
    },
    {
      'id': 'master',
      'label': 'ผู้เชี่ยวชาญ',
      'emoji': '⚡',
      'price': 400,
      'levelRequired': 5,
      'color': 0xFFE8853A,
    },
    // ── ต้อง Level 10+ ───────────────────────────────
    {
      'id': 'champion',
      'label': 'แชมเปี้ยน',
      'emoji': '🏆',
      'price': 600,
      'levelRequired': 10,
      'color': 0xFFD4AF37,
    },
    {
      'id': 'legend',
      'label': 'ตำนาน',
      'emoji': '👑',
      'price': 1000,
      'levelRequired': 10,
      'color': 0xFFB44FD4,
    },
    // ── ต้อง Streak 7 วัน ─────────────────────────────
    {
      'id': 'streak7',
      'label': 'ไม่เคยขาด',
      'emoji': '🔥',
      'price': 350,
      'levelRequired': 0,
      'streakRequired': 7,
      'color': 0xFFE84A4A,
    },
    // ── Rare / แพง ────────────────────────────────────
    {
      'id': 'cozy',
      'label': 'สายโคซี่',
      'emoji': '☕',
      'price': 500,
      'levelRequired': 0,
      'color': 0xFF9E6B4A,
    },
    {
      'id': 'galaxy',
      'label': 'สัมผัสจักรวาล',
      'emoji': '🌌',
      'price': 800,
      'levelRequired': 15,
      'color': 0xFF4A5FAE,
    },
  ];

  /// ตรวจสอบว่า unlock title ได้ไหม (level + streak เพียงพอ)
  bool canUnlockTitle(String titleId) {
    final t = titleCatalog.firstWhere(
      (t) => t['id'] == titleId,
      orElse: () => {},
    );
    if (t.isEmpty) return false;
    final lvReq = (t['levelRequired'] as int?) ?? 0;
    final strReq = (t['streakRequired'] as int?) ?? 0;
    return user.level >= lvReq && user.streak >= strReq;
  }

  // ── Helper: ดึง theme data จาก id ───────────────────────────

  static Map<String, dynamic> getCardThemeData(String themeId) {
    return cardThemeCatalog.firstWhere(
      (t) => t['id'] == themeId,
      orElse: () => cardThemeCatalog.first,
    );
  }

  static Map<String, dynamic> getDeckIconData(String iconId) {
    return deckIconCatalog.firstWhere(
      (d) => d['id'] == iconId,
      orElse: () => deckIconCatalog.first,
    );
  }

  // ── Save / Load ───────────────────────────────────────────────

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userProfile', jsonEncode(user.toJson()));
    prefs.setString(
      'decks',
      jsonEncode(_decks.map((d) => d.toJson()).toList()),
    );
    prefs.setString('fishTank', jsonEncode(fishTank.toJson()));
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('userProfile')) {
      final data = prefs.getString('userProfile');
      if (data != null) user = UserProfile.fromJson(jsonDecode(data));
    }

    if (prefs.containsKey('decks')) {
      final data = prefs.getString('decks');
      if (data != null) {
        final List decoded = jsonDecode(data);
        _decks = decoded.map((d) => Deck.fromJson(d)).toList();
      }
    }

    if (prefs.containsKey('fishTank')) {
      final data = prefs.getString('fishTank');
      if (data != null) fishTank = FishTank.fromJson(jsonDecode(data));
    }

    _decreaseFoodOnLoad();
    notifyListeners();
  }

  void debugNotify() => notifyListeners();

  // ── Profile ───────────────────────────────────────────────────

  void updateName(String newName) {
    user.name = newName;
    _saveData();
    notifyListeners();
  }

  void updateProfileImage(String path) {
    user.profileImagePath = path;
    _saveData();
    notifyListeners();
  }

  void updateSelectedFrame(String? frameName) {
    user.selectedFrame = frameName;
    _saveData();
    notifyListeners();
  }

  void updateSelectedTitle(String? titleId) {
    user.selectedTitle = titleId;
    _saveData();
    notifyListeners();
  }

  void debugAddCoins(int amount) {
    user.coins += amount;
    _saveData();
    notifyListeners();
  }

  // ── Reward System ─────────────────────────────────────────────

  void answerCard(bool remembered, {String? cardId, String? deckId}) {
    if (remembered) {
      user.exp += 15;
      user.coins += 10;

      if (cardId != null && deckId != null) {
        final idx = _decks.indexWhere((d) => d.id == deckId);
        if (idx != -1 && !_decks[idx].rememberedIds.contains(cardId)) {
          _decks[idx].rememberedIds.add(cardId);
        }
      }

      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      if (user.lastPlayedDate == null) {
        user.streak = 1;
      } else {
        final last = DateTime.parse(user.lastPlayedDate!);
        final diff = DateTime(
          today.year,
          today.month,
          today.day,
        ).difference(DateTime(last.year, last.month, last.day)).inDays;
        if (diff == 0) {
          // same day — no change
        } else if (diff == 1) {
          user.streak += 1;
        } else {
          user.streak = 1;
        }
      }
      user.lastPlayedDate = todayStr;

      if (user.exp >= 100) {
        user.level++;
        user.exp -= 100;
        AudioService.instance.playLevelUp();
      }
      _saveData();
      notifyListeners();
    }
  }

  // ── Store — Frames ────────────────────────────────────────────

  bool buyFrame(String frameName, int price) {
    if (user.coins >= price && !user.unlockedFrames.contains(frameName)) {
      user.coins -= price;
      user.unlockedFrames.add(frameName);
      user.selectedFrame = frameName;
      _saveData();
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── Store — Card Themes 🆕 ────────────────────────────────────

  /// ซื้อ Card Theme, คืน true ถ้าสำเร็จ
  bool buyCardTheme(String themeId) {
    if (user.unlockedCardThemes.contains(themeId)) return false; // มีแล้ว
    final catalog = cardThemeCatalog.where((t) => t['id'] == themeId).toList();
    if (catalog.isEmpty) return false;
    final price = catalog.first['price'] as int;
    if (user.coins < price) return false;

    user.coins -= price;
    user.unlockedCardThemes.add(themeId);
    _saveData();
    notifyListeners();
    return true;
  }

  /// เปลี่ยน Card Theme ของสำรับ (ต้องปลดล็อกก่อน)
  bool applyCardTheme(String deckId, String themeId) {
    if (!user.unlockedCardThemes.contains(themeId)) return false;
    final idx = _decks.indexWhere((d) => d.id == deckId);
    if (idx == -1) return false;

    _decks[idx].cardTheme = themeId;
    _saveData();
    notifyListeners();
    return true;
  }

  // ── Store — Deck Icons 🆕 ─────────────────────────────────────

  /// ซื้อ Deck Icon, คืน true ถ้าสำเร็จ
  bool buyDeckIcon(String iconId) {
    if (user.unlockedDeckIcons.contains(iconId)) return false;
    final catalog = deckIconCatalog.where((d) => d['id'] == iconId).toList();
    if (catalog.isEmpty) return false;
    final price = catalog.first['price'] as int;
    if (user.coins < price) return false;

    user.coins -= price;
    user.unlockedDeckIcons.add(iconId);
    _saveData();
    notifyListeners();
    return true;
  }

  /// เปลี่ยน Icon ของสำรับ (ต้องปลดล็อกก่อน)
  bool applyDeckIcon(String deckId, String iconId) {
    if (!user.unlockedDeckIcons.contains(iconId)) return false;
    final idx = _decks.indexWhere((d) => d.id == deckId);
    if (idx == -1) return false;

    _decks[idx].deckIconId = iconId;
    _saveData();
    notifyListeners();
    return true;
  }

  // ── Store — Titles ────────────────────────────────────────────

  /// ซื้อ Title — คืน 'ok', 'owned', 'no_coins', 'locked'
  String buyTitle(String titleId) {
    if (user.unlockedTitles.contains(titleId)) return 'owned';
    if (!canUnlockTitle(titleId)) return 'locked';
    final t = titleCatalog.firstWhere(
      (t) => t['id'] == titleId,
      orElse: () => {},
    );
    if (t.isEmpty) return 'locked';
    final price = t['price'] as int;
    if (user.coins < price) return 'no_coins';

    user.coins -= price;
    user.unlockedTitles.add(titleId);
    user.selectedTitle = titleId; // ใส่ให้ทันที
    _saveData();
    notifyListeners();
    return 'ok';
  }

  // ── Fish Tank ─────────────────────────────────────────────────

  static const List<Map<String, dynamic>> fishCatalog = [
    {
      'type': 'nemo',
      'name': 'นีโม่ 🐠',
      'colorValue': 0xFFFF6B35,
      'price': 100,
    },
    {
      'type': 'goldfish',
      'name': 'ปลาทอง 🐟',
      'colorValue': 0xFFFFD700,
      'price': 80,
    },
    {
      'type': 'blue',
      'name': 'ปลาสีน้ำเงิน 💙',
      'colorValue': 0xFF4A90D9,
      'price': 80,
    },
    {
      'type': 'angel',
      'name': 'ปลาเทวดา 👼',
      'colorValue': 0xFFBDC3C7,
      'price': 150,
    },
    {
      'type': 'purple',
      'name': 'ปลาม่วง 💜',
      'colorValue': 0xFF9B59B6,
      'price': 120,
    },
  ];

  static const List<Map<String, dynamic>> decorCatalog = [
    {
      'type': 'gravel_brown',
      'name': 'กรวดน้ำตาล 🟤',
      'price': 0,
      'category': 'floor',
    },
    {
      'type': 'gravel_pink',
      'name': 'กรวดชมพู 🌸',
      'price': 80,
      'category': 'floor',
    },
    {
      'type': 'gravel_blue',
      'name': 'กรวดฟ้า 💎',
      'price': 80,
      'category': 'floor',
    },
    {
      'type': 'gravel_white',
      'name': 'กรวดขาว 🤍',
      'price': 100,
      'category': 'floor',
    },
    {
      'type': 'gravel_black',
      'name': 'กรวดดำ 🖤',
      'price': 100,
      'category': 'floor',
    },
    {'type': 'plant', 'name': 'ต้นไม้ 🌿', 'price': 50, 'category': 'plant'},
    {'type': 'seaweed', 'name': 'สาหร่าย 🌱', 'price': 60, 'category': 'plant'},
    {
      'type': 'coral',
      'name': 'แนวปะการัง 🌊',
      'price': 150,
      'category': 'plant',
    },
    {
      'type': 'castle',
      'name': 'ปราสาท 🏰',
      'price': 200,
      'category': 'structure',
    },
    {
      'type': 'tunnel',
      'name': 'อุโมงค์ 🐚',
      'price': 180,
      'category': 'structure',
    },
    {
      'type': 'anchor',
      'name': 'สมอเรือ ⚓',
      'price': 120,
      'category': 'structure',
    },
    {
      'type': 'rock',
      'name': 'หินก้อน 🪨',
      'price': 70,
      'category': 'structure',
    },
    {
      'type': 'lamp_blue',
      'name': 'ตะเกียงฟ้า 💙',
      'price': 200,
      'category': 'light',
    },
    {
      'type': 'lamp_purple',
      'name': 'ตะเกียงม่วง 💜',
      'price': 200,
      'category': 'light',
    },
    {
      'type': 'lamp_green',
      'name': 'ตะเกียงเขียว 💚',
      'price': 200,
      'category': 'light',
    },
    {'type': 'food', 'name': 'อาหารปลา 🍤', 'price': 30, 'category': 'food'},
  ];

  String buyFishBulk(String type, int qty) {
    final catalog = fishCatalog.where((f) => f['type'] == type).toList();
    if (catalog.isEmpty) return 'not_found';

    final price = catalog.first['price'] as int;
    final totalPrice = price * qty;

    if (user.coins < totalPrice) return 'no_coins';

    final currentCount = fishTank.fishes.length;
    final canAdd = 20 - currentCount;
    if (canAdd <= 0) return 'tank_full';

    final actualQty = qty > canAdd ? canAdd : qty;
    final actualPrice = price * actualQty;

    user.coins -= actualPrice;
    for (int i = 0; i < actualQty; i++) {
      fishTank.fishes.add(
        Fish(
          id: '${DateTime.now().millisecondsSinceEpoch}_$i',
          type: type,
          name: catalog.first['name'],
          colorValue: catalog.first['colorValue'] as int,
          x: 0.1 + ((currentCount + i) * 0.18) % 0.7,
          y: 0.2 + ((currentCount + i) * 0.15) % 0.5,
        ),
      );
    }
    _saveData();
    notifyListeners();
    return actualQty < qty ? 'partial:$actualQty' : 'success:$actualQty';
  }

  void sellFish(String fishId) {
    fishTank.fishes.removeWhere((f) => f.id == fishId);
    user.coins += 20;
    _saveData();
    notifyListeners();
  }

  String buyFoodBulk(int qty) {
    final price = 30 * qty;
    if (user.coins < price) return 'no_coins';
    user.coins -= price;
    fishTank.foodBags += qty;
    _saveData();
    notifyListeners();
    return 'success';
  }

  bool buyDecor(String type) {
    final catalog = decorCatalog.where((d) => d['type'] == type).toList();
    if (catalog.isEmpty) return false;

    final price = catalog.first['price'] as int;
    if (user.coins < price) return false;

    user.coins -= price;
    switch (type) {
      case 'food':
        fishTank.foodBags += 1;
      case 'plant':
        fishTank.hasPlant = true;
      case 'castle':
        fishTank.hasCastle = true;
      case 'seaweed':
        fishTank.hasSeaweed = true;
      case 'coral':
        fishTank.hasCoral = true;
      case 'tunnel':
        fishTank.hasTunnel = true;
      case 'anchor':
        fishTank.hasAnchor = true;
      case 'rock':
        fishTank.hasRock = true;
      case 'lamp_blue':
        fishTank.lampColor = 'blue';
      case 'lamp_purple':
        fishTank.lampColor = 'purple';
      case 'lamp_green':
        fishTank.lampColor = 'green';
      default:
        if (type.startsWith('gravel_')) {
          fishTank.gravelColor = type.replaceFirst('gravel_', '');
        }
    }
    _saveData();
    notifyListeners();
    return true;
  }

  String feedFish() {
    if (fishTank.fishes.isEmpty) return 'no_fish';
    if (fishTank.foodBags <= 0) return 'no_food';
    if (fishTank.foodLevel >= 100) return 'full';

    fishTank.foodBags -= 1;
    fishTank.foodLevel = (fishTank.foodLevel + 20).clamp(0, 100);
    _saveData();
    notifyListeners();
    return 'success';
  }

  bool get isFedToday => fishTank.foodLevel >= 100;

  String get feedCooldownText => '';

  void _decreaseFoodOnLoad() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final eightHours = 8 * 60 * 60 * 1000;

    if (fishTank.lastDecreaseTime == 0) {
      fishTank.lastDecreaseTime = now;
      _saveData();
      return;
    }

    final diff = now - fishTank.lastDecreaseTime;
    final rounds = (diff / eightHours).floor();
    if (rounds <= 0) return;

    final totalDecrease = rounds * 20;
    fishTank.foodLevel = (fishTank.foodLevel - totalDecrease).clamp(0, 100);
    fishTank.lastDecreaseTime = now;

    if (fishTank.foodLevel <= 0 && fishTank.fishes.isNotEmpty) {
      fishDiedFromHunger = true;
      fishTank.fishes.clear();
    }

    _saveData();
  }

  bool get needsFoodWarning =>
      fishTank.fishes.isNotEmpty && fishTank.foodLevel < 30;

  // ── Deck Management ───────────────────────────────────────────

  String addDeck(String title, {String? imagePath}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _decks.add(
      Deck(id: id, title: title, cards: [], backgroundImagePath: imagePath),
    );
    _saveData();
    notifyListeners();
    return id;
  }

  void deleteCard(String deckId, String cardId) {
    final dIdx = _decks.indexWhere((d) => d.id == deckId);
    if (dIdx != -1) {
      _decks[dIdx].cards.removeWhere((c) => c.id == cardId);
      _decks[dIdx].rememberedIds.remove(cardId);
      _saveData();
      notifyListeners();
    }
  }

  void editDeck(String deckId, String newTitle, String? newImagePath) {
    final index = _decks.indexWhere((d) => d.id == deckId);
    if (index != -1) {
      _decks[index].title = newTitle;
      _decks[index].backgroundImagePath = newImagePath;
      _saveData();
      notifyListeners();
    }
  }

  void deleteDeck(String deckId) {
    _decks.removeWhere((d) => d.id == deckId);
    _saveData();
    notifyListeners();
  }

  void addCard(
    String deckId,
    String front,
    String back, {
    String? frontImg,
    String? backImg,
  }) {
    final index = _decks.indexWhere((deck) => deck.id == deckId);
    if (index != -1) {
      _decks[index].cards.add(
        Flashcard(
          id: DateTime.now().toString(),
          front: front,
          back: back,
          frontImagePath: frontImg,
          backImagePath: backImg,
        ),
      );
      _saveData();
      notifyListeners();
    }
  }

  void editCard(
    String deckId,
    String cardId,
    String newFront,
    String newBack, {
    String? newFrontImg,
    String? newBackImg,
  }) {
    final dIdx = _decks.indexWhere((d) => d.id == deckId);
    if (dIdx != -1) {
      final cIdx = _decks[dIdx].cards.indexWhere((c) => c.id == cardId);
      if (cIdx != -1) {
        _decks[dIdx].cards[cIdx].front = newFront;
        _decks[dIdx].cards[cIdx].back = newBack;
        _decks[dIdx].cards[cIdx].frontImagePath = newFrontImg;
        _decks[dIdx].cards[cIdx].backImagePath = newBackImg;
        _saveData();
        notifyListeners();
      }
    }
  }

  Future<void> resetAllData() async {
    _decks = [];
    fishTank = FishTank();
    user = UserProfile(name: 'นักเรียนใหม่ 🌱', level: 1, coins: 0, exp: 0);
    fishDiedFromHunger = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
