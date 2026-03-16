// ไฟล์: lib/screens/profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/deck_provider.dart';
import '../models/deck_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      if (!context.mounted) return;
      Provider.of<DeckProvider>(
        context,
        listen: false,
      ).updateProfileImage(image.path);
    }
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('แก้ไขชื่อของคุณ ✏️'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'ใส่ชื่อใหม่ที่นี่...'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                Provider.of<DeckProvider>(
                  context,
                  listen: false,
                ).updateName(ctrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  // 🆕 dialog เลือก Title
  void _showSelectTitleDialog(BuildContext context, DeckProvider provider) {
    final user = provider.user;
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
            initialChildSize: 0.7,
            maxChildSize: 0.92,
            builder: (_, scrollCtrl) => Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Row(
                    children: [
                      const Text(
                        'เลือก Title 🏷️',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (user.selectedTitle != null)
                        TextButton(
                          onPressed: () {
                            provider.updateSelectedTitle(null);
                            Navigator.pop(ctx);
                          },
                          child: const Text(
                            'ถอด Title',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: DeckProvider.titleCatalog.length,
                    itemBuilder: (_, i) {
                      final t = DeckProvider.titleCatalog[i];
                      final isOwned =
                          user.unlockedTitles.contains(t['id']) ||
                          t['price'] == 0;
                      final isEquipped = user.selectedTitle == t['id'];
                      final canUnlock = provider.canUnlockTitle(
                        t['id'] as String,
                      );
                      final lvReq = (t['levelRequired'] as int?) ?? 0;
                      final strReq = (t['streakRequired'] as int?) ?? 0;
                      final price = t['price'] as int;
                      final titleColor = Color(t['color'] as int);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: isEquipped
                              ? BorderSide(color: titleColor, width: 2)
                              : BorderSide.none,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: titleColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                t['emoji'] as String,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                t['label'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                              ),
                              if (isEquipped) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: titleColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'ใช้อยู่',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: titleColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: _buildTitleSubtitle(
                            isOwned,
                            canUnlock,
                            price,
                            lvReq,
                            strReq,
                            titleColor,
                          ),
                          trailing: _buildTitleTrailing(
                            context,
                            provider,
                            t,
                            isOwned,
                            isEquipped,
                            canUnlock,
                            titleColor,
                            setSheet,
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

  Widget _buildTitleSubtitle(
    bool isOwned,
    bool canUnlock,
    int price,
    int lvReq,
    int strReq,
    Color color,
  ) {
    if (isOwned || price == 0) {
      return const Text(
        'ปลดล็อกแล้ว ✓',
        style: TextStyle(color: Colors.grey, fontSize: 12),
      );
    }
    final conditions = <String>[];
    if (lvReq > 0) conditions.add('Lv.$lvReq+');
    if (strReq > 0) conditions.add('Streak $strReq วัน');
    final condText = conditions.isNotEmpty
        ? ' • ต้องการ: ${conditions.join(', ')}'
        : '';
    return Text(
      '💰 $price$condText',
      style: TextStyle(
        fontSize: 12,
        color: canUnlock ? Colors.grey : Colors.red[300],
      ),
    );
  }

  Widget _buildTitleTrailing(
    BuildContext context,
    DeckProvider provider,
    Map<String, dynamic> t,
    bool isOwned,
    bool isEquipped,
    bool canUnlock,
    Color color,
    StateSetter setSheet,
  ) {
    final price = t['price'] as int;

    if (isEquipped) {
      return const SizedBox(width: 8);
    }

    if (isOwned || price == 0) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          provider.updateSelectedTitle(t['id'] as String);
          // ถ้าฟรีและยังไม่ได้ unlock ให้ add เข้า list ด้วย
          if (!provider.user.unlockedTitles.contains(t['id'])) {
            provider.user.unlockedTitles.add(t['id'] as String);
          }
          setSheet(() {});
          Navigator.pop(context);
        },
        child: const Text(
          'ใส่',
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
      );
    }

    if (!canUnlock) {
      return const Icon(Icons.lock, color: Colors.grey, size: 20);
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () {
        final result = provider.buyTitle(t['id'] as String);
        setSheet(() {});
        String msg;
        switch (result) {
          case 'ok':
            msg = 'ได้รับ Title "${t['label']}" แล้ว! 🎉';
          case 'no_coins':
            msg = 'เหรียญไม่พอจ้า 🥲';
          case 'locked':
            msg = 'ยังไม่ถึงเงื่อนไขนะ';
          default:
            msg = 'มี Title นี้แล้ว';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      },
      child: Text(
        '💰 ${t['price']}',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Color _getFrameColor(String? frameName) {
    switch (frameName) {
      case 'กรอบไม้ธรรมชาติ 🪵':
        return Colors.brown;
      case 'กรอบทองคำขาว 💎':
        return Colors.amber;
      case 'กรอบออร่าพาสเทล ✨':
        return Colors.purpleAccent.shade100;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deckProvider = Provider.of<DeckProvider>(context);
    final user = deckProvider.user;
    final primary = Theme.of(context).primaryColor;

    // ดึง title data ของ selectedTitle
    Map<String, dynamic>? titleData;
    if (user.selectedTitle != null) {
      final found = DeckProvider.titleCatalog
          .where((t) => t['id'] == user.selectedTitle)
          .toList();
      if (found.isNotEmpty) titleData = found.first;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile 🌱'), elevation: 0),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 30),

              // ── รูปโปรไฟล์ ──────────────────────
              _buildAvatarSection(context, user),

              const SizedBox(height: 20),

              // ── ชื่อ ─────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 48),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                    onPressed: () => _showEditNameDialog(context, user.name),
                  ),
                ],
              ),

              // 🆕 Title badge ใต้ชื่อ
              GestureDetector(
                onTap: () => _showSelectTitleDialog(context, deckProvider),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: titleData != null
                      ? _TitleBadge(
                          key: ValueKey(titleData['id']),
                          emoji: titleData['emoji'] as String,
                          label: titleData['label'] as String,
                          color: Color(titleData['color'] as int),
                        )
                      : Container(
                          key: const ValueKey('no_title'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: primary.withOpacity(0.2),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Text(
                            '✨ แตะเพื่อเลือก Title',
                            style: TextStyle(fontSize: 13, color: primary),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 8),

              // Level
              Text(
                'Level ${user.level}',
                style: TextStyle(
                  fontSize: 16,
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // ── Stats ────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'EXP ✨',
                        '${user.exp}/100',
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildStatCard(
                        'Coins 💰',
                        '${user.coins}',
                        Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStatCard(
                  'Streak 🔥',
                  '${user.streak} วัน',
                  Colors.deepOrange,
                ),
              ),

              const SizedBox(height: 30),

              // ── Debug ────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Debug: +500 Coins'),
                  onPressed: () => deckProvider.debugAddCoins(500),
                ),
              ),

              const SizedBox(height: 16),

              // ── ถอดกรอบ ──────────────────────────
              if (user.selectedFrame != null)
                TextButton.icon(
                  onPressed: () => deckProvider.updateSelectedFrame(null),
                  icon: const Icon(
                    Icons.no_photography_outlined,
                    color: Colors.redAccent,
                  ),
                  label: const Text(
                    'ถอดกรอบรูปออก',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),

              const SizedBox(height: 40),
              const Text(
                '" การเรียนรู้คือการเดินทางที่สวยงาม "',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context, UserProfile user) {
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle),
        ),
        CircleAvatar(
          radius: 70,
          backgroundColor: const Color(0xFFA3C9A8),
          backgroundImage: user.profileImagePath != null
              ? FileImage(File(user.profileImagePath!))
              : null,
          child: user.profileImagePath == null
              ? const Icon(
                  Icons.face_retouching_natural,
                  size: 70,
                  color: Colors.white,
                )
              : null,
        ),
        if (user.selectedFrame != null)
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _getFrameColor(user.selectedFrame),
                width: 10,
              ),
            ),
          ),
        Positioned(
          bottom: 5,
          right: 5,
          child: GestureDetector(
            onTap: () => _pickImage(context),
            child: CircleAvatar(
              backgroundColor: cardColor,
              radius: 22,
              child: const CircleAvatar(
                backgroundColor: Color(0xFFA3C9A8),
                radius: 19,
                child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Builder(
      builder: (context) {
        final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
        final textColor = Theme.of(context).colorScheme.onSurface;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: color.withOpacity(0.15), width: 2),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Title Badge Widget ───────────────────────────────────────────

class _TitleBadge extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _TitleBadge({
    super.key,
    required this.emoji,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
