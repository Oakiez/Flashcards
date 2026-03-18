// ไฟล์: lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/deck_provider.dart';
import '../services/audio_service.dart';
import 'tutorial_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _audio = AudioService.instance;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final primary = themeProvider.primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('ตั้งค่า ⚙️')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── 🎨 ธีมแอป ─────────────────────────────
          _buildSectionTitle('🎨 ธีมแอป'),
          _buildThemeSelector(context, themeProvider),

          const SizedBox(height: 28),

          // ── 🔊 เสียง ──────────────────────────────
          _buildSectionTitle('🔊 เสียง'),

          _buildVolumeCard(
            title: 'Master Volume',
            subtitle: 'ควบคุมเสียงทั้งหมด',
            value: _audio.masterVolume,
            isMuted: _audio.masterMuted,
            primaryColor: primary,
            onChanged: (v) async {
              await _audio.setMasterVolume(v);
              setState(() {});
            },
            onMute: () async {
              await _audio.toggleMasterMute();
              setState(() {});
              _audio.playBtnClick();
            },
          ),

          const SizedBox(height: 12),

          _buildVolumeCard(
            title: 'Music Volume',
            subtitle: 'เพลงประกอบเกม',
            value: _audio.musicVolume,
            isMuted: _audio.musicMuted,
            primaryColor: primary,
            onChanged: (v) async {
              await _audio.setMusicVolume(v);
              setState(() {});
            },
            onMute: () async {
              await _audio.toggleMusicMute();
              setState(() {});
              _audio.playBtnClick();
            },
          ),

          const SizedBox(height: 28),

          // ── 🗂️ ข้อมูล ──────────────────────────────
          _buildSectionTitle('🗂️ ข้อมูล'),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFE0E0),
                child: Icon(Icons.delete_forever, color: Colors.redAccent),
              ),
              title: const Text(
                'Reset ข้อมูลทั้งหมด',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('ลบข้อมูลทั้งหมดในแอป'),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
              onTap: () => _showResetDialog(context),
            ),
          ),

          const SizedBox(height: 28),

          // ── ℹ️ เกี่ยวกับ ───────────────────────────
          _buildSectionTitle('ℹ️ เกี่ยวกับ'),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: Color(0xFFA3C9A8)),
                  title: Text('เวอร์ชัน'),
                  trailing: Text('1.0.0', style: TextStyle(color: Colors.grey)),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.code, color: Color(0xFFA3C9A8)),
                  title: Text('สร้างด้วย'),
                  trailing: Text(
                    'Flutter',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Theme Selector ─────────────────────────────────────────────

  Widget _buildThemeSelector(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.0,
      children: kAppThemes.map((theme) {
        final isSelected = themeProvider.themeId == theme.id;
        return GestureDetector(
          onTap: () => themeProvider.setTheme(theme.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: theme.bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? theme.primaryColor
                    : Colors.grey.withOpacity(0.2),
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.25),
                        blurRadius: 8,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // preview: dot สี primary บน bg
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      theme.emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  theme.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: theme.primaryColor,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 2),
                  Icon(Icons.check_circle, size: 14, color: theme.primaryColor),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    ),
  );

  Widget _buildVolumeCard({
    required String title,
    required String subtitle,
    required double value,
    required bool isMuted,
    required Color primaryColor,
    required ValueChanged<double> onChanged,
    required VoidCallback onMute,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onMute,
                  icon: Icon(
                    isMuted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    color: isMuted ? Colors.grey : primaryColor,
                    size: 28,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 4),
                Icon(
                  isMuted
                      ? Icons.volume_mute_rounded
                      : Icons.volume_down_rounded,
                  color: Colors.grey,
                  size: 18,
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: isMuted
                          ? Colors.grey[300]
                          : primaryColor,
                      thumbColor: isMuted ? Colors.grey : primaryColor,
                      inactiveTrackColor: Colors.grey[200],
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: isMuted ? 0 : value,
                      min: 0,
                      max: 1,
                      onChanged: isMuted ? null : onChanged,
                    ),
                  ),
                ),
                Text(
                  isMuted ? 'Muted' : '${(value * 100).round()}%',
                  style: TextStyle(
                    color: isMuted ? Colors.grey : null,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Reset Dialog ───────────────────────────────────────────────

  void _showResetDialog(BuildContext context) {
    final ctrl = TextEditingController();
    bool confirmed = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Text('⚠️', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Text('Reset ข้อมูลทั้งหมด', style: TextStyle(fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Text(
                  'ข้อมูลทั้งหมดจะถูกลบ:\n'
                  '• สำรับการ์ดทั้งหมด\n'
                  '• Profile และ Level\n'
                  '• Coins และ EXP\n'
                  '• ตู้ปลาและปลาทั้งหมด\n'
                  '• ของที่ซื้อทั้งหมด',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'พิมพ์ "Reset" เพื่อยืนยัน:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl,
                onChanged: (v) => setDialog(() => confirmed = v == 'Reset'),
                decoration: InputDecoration(
                  hintText: 'พิมพ์ Reset ที่นี่',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  isDense: true,
                  errorText: ctrl.text.isNotEmpty && !confirmed
                      ? 'พิมพ์ "Reset" ให้ถูกต้อง'
                      : null,
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
                backgroundColor: confirmed ? Colors.redAccent : Colors.grey,
              ),
              onPressed: confirmed
                  ? () async {
                      Navigator.pop(ctx);
                      await _doReset(context);
                    }
                  : null,
              child: const Text(
                'ยืนยัน Reset',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _doReset(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!context.mounted) return;
    context.read<DeckProvider>().resetAllData();
    await context.read<ThemeProvider>().setTheme('green');
    await AudioService.instance.startBgm();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TutorialScreen()),
      (route) => false,
    );
  }
}
