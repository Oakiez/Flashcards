// ไฟล์: lib/models/deck_model.dart

class Flashcard {
  String id;
  String front;
  String back;
  String? frontImagePath;
  String? backImagePath;

  Flashcard({
    required this.id,
    required this.front,
    required this.back,
    this.frontImagePath,
    this.backImagePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'front': front,
    'back': back,
    'frontImagePath': frontImagePath,
    'backImagePath': backImagePath,
  };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    id: json['id'],
    front: json['front'] ?? '',
    back: json['back'] ?? '',
    frontImagePath: json['frontImagePath'],
    backImagePath: json['backImagePath'],
  );
}

class Deck {
  String id;
  String title;
  List<Flashcard> cards;
  String? backgroundImagePath;
  List<String> rememberedIds;
  // Card Theme เป็นทั้ง theme การ์ด และสีสำรับ
  String cardTheme;
  // Deck Icon ID
  String deckIconId;

  Deck({
    required this.id,
    required this.title,
    required this.cards,
    this.backgroundImagePath,
    List<String>? rememberedIds,
    this.cardTheme = 'default',
    this.deckIconId = 'default',
  }) : rememberedIds = rememberedIds ?? [];

  /// สีสำรับ = accentColor ของ cardTheme (ใช้แทน colorValue เดิม)
  int get colorValue {
    const Map<String, int> _themeAccents = {
      'default': 0xFFA3C9A8,
      'ocean': 0xFF1565C0,
      'sakura': 0xFFAD1457,
      'christmas': 0xFFB71C1C,
      'chinese_new_year': 0xFFE65100,
      'halloween': 0xFF4A148C,
    };
    return _themeAccents[cardTheme] ?? 0xFFA3C9A8;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'backgroundImagePath': backgroundImagePath,
    'cards': cards.map((c) => c.toJson()).toList(),
    'rememberedIds': rememberedIds,
    'cardTheme': cardTheme,
    'deckIconId': deckIconId,
  };

  factory Deck.fromJson(Map<String, dynamic> json) => Deck(
    id: json['id'],
    title: json['title'] ?? 'สำรับไม่มีชื่อ',
    backgroundImagePath: json['backgroundImagePath'],
    cards: json['cards'] != null
        ? (json['cards'] as List).map((c) => Flashcard.fromJson(c)).toList()
        : [],
    rememberedIds: json['rememberedIds'] != null
        ? List<String>.from(json['rememberedIds'])
        : [],
    // รองรับข้อมูลเก่าที่มี colorValue แต่ไม่มี cardTheme
    cardTheme: json['cardTheme'] ?? 'default',
    deckIconId: json['deckIconId'] ?? 'default',
  );
}

class UserProfile {
  String name;
  int level;
  int exp;
  int coins;
  String? profileImagePath;
  String? selectedFrame;
  List<String> unlockedFrames;
  int streak;
  String? lastPlayedDate;
  List<String> unlockedCardThemes;
  List<String> unlockedDeckIcons;
  // 🆕 Title ผู้เล่น
  String? selectedTitle;
  List<String> unlockedTitles;

  UserProfile({
    this.name = 'นักเรียนใหม่ 🌱',
    this.level = 1,
    this.exp = 0,
    this.coins = 0,
    this.selectedFrame,
    List<String>? unlockedFrames,
    this.profileImagePath,
    this.streak = 0,
    this.lastPlayedDate,
    List<String>? unlockedCardThemes,
    List<String>? unlockedDeckIcons,
    this.selectedTitle,
    List<String>? unlockedTitles,
  }) : unlockedFrames = unlockedFrames ?? [],
       unlockedCardThemes = unlockedCardThemes ?? ['default'],
       unlockedDeckIcons = unlockedDeckIcons ?? ['default'],
       unlockedTitles = unlockedTitles ?? [];

  Map<String, dynamic> toJson() => {
    'name': name,
    'level': level,
    'exp': exp,
    'coins': coins,
    'profileImagePath': profileImagePath,
    'selectedFrame': selectedFrame,
    'unlockedFrames': unlockedFrames,
    'streak': streak,
    'lastPlayedDate': lastPlayedDate,
    'unlockedCardThemes': unlockedCardThemes,
    'unlockedDeckIcons': unlockedDeckIcons,
    'selectedTitle': selectedTitle,
    'unlockedTitles': unlockedTitles,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? 'นักเรียนใหม่ 🌱',
    level: json['level'] ?? 1,
    exp: json['exp'] ?? 0,
    coins: json['coins'] ?? 0,
    profileImagePath: json['profileImagePath'],
    selectedFrame: json['selectedFrame'],
    unlockedFrames: json['unlockedFrames'] != null
        ? List<String>.from(json['unlockedFrames'])
        : [],
    streak: json['streak'] ?? 0,
    lastPlayedDate: json['lastPlayedDate'],
    unlockedCardThemes: json['unlockedCardThemes'] != null
        ? List<String>.from(json['unlockedCardThemes'])
        : ['default'],
    unlockedDeckIcons: json['unlockedDeckIcons'] != null
        ? List<String>.from(json['unlockedDeckIcons'])
        : ['default'],
    selectedTitle: json['selectedTitle'],
    unlockedTitles: json['unlockedTitles'] != null
        ? List<String>.from(json['unlockedTitles'])
        : [],
  );
}

// ── Fish Model ─────────────────────────────────────────────────

class Fish {
  final String id;
  final String type;
  final String name;
  final int colorValue;
  double x;
  double y;
  bool facingRight;

  Fish({
    required this.id,
    required this.type,
    required this.name,
    required this.colorValue,
    this.x = 0.5,
    this.y = 0.5,
    this.facingRight = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'name': name,
    'colorValue': colorValue,
    'x': x,
    'y': y,
  };

  factory Fish.fromJson(Map<String, dynamic> json) => Fish(
    id: json['id'],
    type: json['type'],
    name: json['name'],
    colorValue: json['colorValue'],
    x: (json['x'] ?? 0.5).toDouble(),
    y: (json['y'] ?? 0.5).toDouble(),
  );
}

// ── FishTank Model ──────────────────────────────────────────────

class FishTank {
  List<Fish> fishes;
  String gravelColor;
  bool hasPlant;
  bool hasCastle;
  int foodLevel;
  int foodBags;
  int lastFedTime;
  int lastDecreaseTime;
  bool hasSeaweed;
  bool hasCoral;
  bool hasTunnel;
  bool hasAnchor;
  bool hasRock;
  String lampColor;

  FishTank({
    List<Fish>? fishes,
    this.gravelColor = 'brown',
    this.hasPlant = false,
    this.hasCastle = false,
    this.hasSeaweed = false,
    this.hasCoral = false,
    this.hasTunnel = false,
    this.hasAnchor = false,
    this.hasRock = false,
    this.lampColor = '',
    this.foodLevel = 50,
    this.foodBags = 0,
    this.lastFedTime = 0,
    this.lastDecreaseTime = 0,
  }) : fishes = fishes ?? [];

  Map<String, dynamic> toJson() => {
    'fishes': fishes.map((f) => f.toJson()).toList(),
    'gravelColor': gravelColor,
    'hasPlant': hasPlant,
    'hasCastle': hasCastle,
    'foodLevel': foodLevel,
    'foodBags': foodBags,
    'lastFedTime': lastFedTime,
    'lastDecreaseTime': lastDecreaseTime,
    'hasSeaweed': hasSeaweed,
    'hasCoral': hasCoral,
    'hasTunnel': hasTunnel,
    'hasAnchor': hasAnchor,
    'hasRock': hasRock,
    'lampColor': lampColor,
  };

  factory FishTank.fromJson(Map<String, dynamic> json) => FishTank(
    fishes: json['fishes'] != null
        ? (json['fishes'] as List).map((f) => Fish.fromJson(f)).toList()
        : [],
    gravelColor: json['gravelColor'] ?? 'brown',
    hasPlant: json['hasPlant'] ?? false,
    hasCastle: json['hasCastle'] ?? false,
    foodLevel: json['foodLevel'] ?? 0,
    foodBags: json['foodBags'] ?? 0,
    lastFedTime: json['lastFedTime'] ?? 0,
    lastDecreaseTime: json['lastDecreaseTime'] ?? 0,
    hasSeaweed: json['hasSeaweed'] ?? false,
    hasCoral: json['hasCoral'] ?? false,
    hasTunnel: json['hasTunnel'] ?? false,
    hasAnchor: json['hasAnchor'] ?? false,
    hasRock: json['hasRock'] ?? false,
    lampColor: json['lampColor'] ?? '',
  );
}
