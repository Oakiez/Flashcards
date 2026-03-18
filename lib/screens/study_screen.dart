// ไฟล์: lib/screens/study_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/deck_provider.dart';
import '../models/deck_model.dart';
import '../services/audio_service.dart';
import 'result_screen.dart';
import '../widgets/card_theme_painter.dart';

class StudyScreen extends StatefulWidget {
  final String deckId;
  const StudyScreen({super.key, required this.deckId});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _sessionExp = 0;
  int _sessionCoins = 0;
  int _sessionRemembered = 0;
  int _sessionForgot = 0;
  bool _isProcessing = false;
  late Deck _deck;

  final List<Map<String, dynamic>> _reviewData = [];

  @override
  void initState() {
    super.initState();
    final found = Provider.of<DeckProvider>(
      context,
      listen: false,
    ).decks.where((d) => d.id == widget.deckId).toList();
    if (found.isNotEmpty) _deck = found.first;
  }

  // 🆕 ดึงสีจาก cardTheme ของสำรับ
  Map<String, Color> get _themeColors {
    final themeData = DeckProvider.getCardThemeData(_deck.cardTheme);
    return {
      'front': Color(themeData['frontColor'] as int),
      'back': Color(themeData['backColor'] as int),
      'accent': Color(themeData['accentColor'] as int),
    };
  }

  // emoji ของ theme สำหรับ decoration มุมการ์ด
  String get _themeEmoji {
    final themeData = DeckProvider.getCardThemeData(_deck.cardTheme);
    final id = themeData['id'] as String;
    switch (id) {
      case 'christmas':
        return '🎄';
      case 'chinese_new_year':
        return '🧧';
      case 'halloween':
        return '🎃';
      case 'ocean':
        return '🌊';
      case 'sakura':
        return '🌸';
      default:
        return '';
    }
  }

  void _nextCard(BuildContext context, bool remembered) {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    if (remembered) {
      AudioService.instance.playCorrect();
      _sessionExp += 15;
      _sessionCoins += 10;
      _sessionRemembered++;
    } else {
      AudioService.instance.playWrong();
      _sessionForgot++;
    }

    final card = _deck.cards[_currentIndex];
    _reviewData.add({
      'question': card.front.isNotEmpty ? card.front : '[รูปภาพ]',
      'answer': card.back.isNotEmpty ? card.back : '[รูปภาพ]',
      'remembered': remembered,
    });

    Provider.of<DeckProvider>(
      context,
      listen: false,
    ).answerCard(remembered, cardId: card.id, deckId: widget.deckId);

    if (_currentIndex < _deck.cards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
        _isProcessing = false;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            deckTitle: _deck.title,
            totalCards: _deck.cards.length,
            remembered: _sessionRemembered,
            forgot: _sessionForgot,
            sessionExp: _sessionExp,
            sessionCoins: _sessionCoins,
            reviewData: _reviewData,
          ),
        ),
      );
    }
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('⏸️ หยุดชั่วคราว', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'การ์ดที่ ${_currentIndex + 1}/${_deck.cards.length}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'จำได้: $_sessionRemembered  ลืม: $_sessionForgot',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            label: const Text(
              'ออกจากเกม',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            label: const Text('เล่นต่อ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = _deck.cards[_currentIndex];
    final colors = _themeColors;
    final deckColor = Color(_deck.colorValue);
    final emoji = _themeEmoji;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_deck.title} (${_currentIndex + 1}/${_deck.cards.length})',
        ),
        backgroundColor: deckColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.pause_circle_outline, color: Colors.white),
            onPressed: _showPauseDialog,
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / _deck.cards.length,
                minHeight: 6,
                backgroundColor: Colors.grey[200],
                color: deckColor,
              ),
            ),
            const SizedBox(height: 20),

            // Card — ใช้สีจาก theme
            Expanded(
              child: GestureDetector(
                onTap: () {
                  AudioService.instance.playCardFlip();
                  setState(() => _isFlipped = !_isFlipped);
                },
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _isFlipped ? colors['back'] : colors['front'],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colors['accent']!.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // pattern background
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: CustomPaint(
                            painter: CardThemePainter(
                              themeId: _deck.cardTheme,
                              bg: _isFlipped
                                  ? colors['back']!
                                  : colors['front']!,
                              accent: colors['accent']!,
                              isBack: _isFlipped,
                            ),
                            child: const SizedBox.expand(),
                          ),
                        ),
                        // เนื้อหาการ์ด
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Stack(
                            children: [
                              // 🆕 Theme emoji ตกแต่งมุมบนขวา (ถ้าไม่ใช่ default)
                              if (emoji.isNotEmpty)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),

                              // เนื้อหาการ์ด
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Label ด้านหน้า/หลัง — จัดกึ่งกลาง
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors['accent']!.withOpacity(
                                          0.13,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: colors['accent']!.withOpacity(
                                            0.25,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        _isFlipped
                                            ? 'ด้านหลัง (คำตอบ)'
                                            : 'ด้านหน้า (คำถาม)',
                                        style: TextStyle(
                                          color: colors['accent'],
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // รูปภาพ — จำกัดความสูงให้ไม่ทับ text
                                  if (!_isFlipped &&
                                      card.frontImagePath != null)
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                            0.28,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(card.frontImagePath!),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  if (_isFlipped && card.backImagePath != null)
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                            0.28,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(card.backImagePath!),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),

                                  if (card.frontImagePath != null ||
                                      card.backImagePath != null)
                                    const SizedBox(height: 16),

                                  // กล่องข้อความ contrast
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 18,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors['accent']!.withOpacity(
                                        0.10,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: colors['accent']!.withOpacity(
                                          0.22,
                                        ),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colors['accent']!.withOpacity(
                                            0.07,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _isFlipped ? card.back : card.front,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: colors['accent'],
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (!_isFlipped)
              Text(
                'แตะที่การ์ดเพื่อดูคำตอบ 👆',
                style: TextStyle(color: Colors.grey[500], fontSize: 16),
              ),

            if (_isFlipped)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text(
                      'ลืม',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    onPressed: _isProcessing
                        ? null
                        : () => _nextCard(context, false),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      'จำได้',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    onPressed: _isProcessing
                        ? null
                        : () => _nextCard(context, true),
                  ),
                ],
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
