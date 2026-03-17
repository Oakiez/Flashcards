import 'dart:io';
import 'package:flashcards/screens/study_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/deck_provider.dart';
import '../models/deck_model.dart';
import '../services/audio_service.dart';
import 'game_rules_dialog.dart';

class DeckEditorScreen extends StatefulWidget {
  final String deckId;
  const DeckEditorScreen({super.key, required this.deckId});

  @override
  State<DeckEditorScreen> createState() => _DeckEditorScreenState();
}

class _DeckEditorScreenState extends State<DeckEditorScreen> {
  bool _selectMode = false;
  final Set<String> _selectedIds = {};

  Future<String?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile?.path;
  }

  void _showAddCardOptions(BuildContext context) {
    AudioService.instance.playBtnClick();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'เพิ่มการ์ด',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                _showCardEditorModal(context);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFA3C9A8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFA3C9A8).withOpacity(0.5),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.add_card_outlined,
                      color: Color(0xFFA3C9A8),
                      size: 32,
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'เพิ่มทีละใบ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'พร้อมใส่รูปภาพได้',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                _showBulkAddModal(context);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.playlist_add, color: Colors.purple, size: 32),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'เพิ่มหลายใบพร้อมกัน',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'พิมพ์คำถาม-คำตอบทีละแถว',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _deleteSelected(BuildContext context, Deck deck) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ลบการ์ด 🗑️'),
        content: Text('ต้องการลบ ${_selectedIds.length} ใบ ใช่ไหม?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              final provider = Provider.of<DeckProvider>(
                context,
                listen: false,
              );
              for (final id in _selectedIds) {
                provider.deleteCard(widget.deckId, id);
              }
              setState(() {
                _selectedIds.clear();
                _selectMode = false;
              });
              AudioService.instance.playBtnClick();
            },
            child: const Text('ลบเลย', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── ตั้งค่าสำรับ — ลบ color picker ออกแล้ว (สีมาจาก cardTheme) ────────────
  void _showDeckSettingsModal(BuildContext context, Deck deck) {
    final titleController = TextEditingController(text: deck.title);
    String? selectedImagePath = deck.backgroundImagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) => Padding(
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
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ตั้งค่าสำรับ 🛠️',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'ชื่อสำรับ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Row(
                //   children: [
                //     Expanded(
                //       child: OutlinedButton.icon(
                //         icon: const Icon(Icons.image_outlined),
                //         label: Text(
                //           selectedImagePath != null
                //               ? 'เปลี่ยนรูปพื้นหลัง'
                //               : 'เลือกรูปพื้นหลัง',
                //         ),
                //         style: OutlinedButton.styleFrom(
                //           padding: const EdgeInsets.symmetric(vertical: 12),
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(12),
                //           ),
                //         ),
                //         onPressed: () async {
                //           final path = await _pickImage();
                //           if (path != null)
                //             setStateModal(() => selectedImagePath = path);
                //         },
                //       ),
                //     ),
                //     if (selectedImagePath != null) ...[
                //       const SizedBox(width: 8),
                //       IconButton(
                //         icon: const Icon(
                //           Icons.delete_outline,
                //           color: Colors.redAccent,
                //         ),
                //         onPressed: () =>
                //             setStateModal(() => selectedImagePath = null),
                //       ),
                //     ],
                //   ],
                // ),
                const SizedBox(height: 20),
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
                      Provider.of<DeckProvider>(
                        context,
                        listen: false,
                      ).editDeck(
                        deck.id,
                        titleController.text,
                        selectedImagePath,
                      );
                      AudioService.instance.playBtnClick();
                      Navigator.pop(ctx);
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
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    icon: const Icon(
                      Icons.delete_forever,
                      color: Colors.redAccent,
                    ),
                    label: const Text(
                      'ลบสำรับนี้',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogCtx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Text('ยืนยันการลบ 🗑️'),
                          content: const Text(
                            'แน่ใจหรือไม่? การ์ดทั้งหมดจะหายไปด้วยนะ!',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogCtx),
                              child: const Text(
                                'ยกเลิก',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                              onPressed: () {
                                Provider.of<DeckProvider>(
                                  context,
                                  listen: false,
                                ).deleteDeck(deck.id);
                                Navigator.pop(dialogCtx);
                                Navigator.pop(ctx);
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'ลบเลย',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCardEditorModal(BuildContext context, {Flashcard? existingCard}) {
    final frontController = TextEditingController(
      text: existingCard?.front ?? '',
    );
    final backController = TextEditingController(
      text: existingCard?.back ?? '',
    );
    String? frontImg = existingCard?.frontImagePath;
    String? backImg = existingCard?.backImagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  existingCard == null ? 'เพิ่มการ์ดใหม่ ✨' : 'แก้ไขการ์ด ✏️',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // ด้านหน้า
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'คำถาม',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: frontController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'พิมพ์คำถาม...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      frontImg != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(frontImg!),
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () =>
                                        setStateModal(() => frontImg = null),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : OutlinedButton.icon(
                              onPressed: () async {
                                final p = await _pickImage();
                                if (p != null)
                                  setStateModal(() => frontImg = p);
                              },
                              icon: const Icon(
                                Icons.add_photo_alternate,
                                size: 18,
                              ),
                              label: const Text('เพิ่มรูป'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),
                const Icon(Icons.swap_vert, color: Colors.grey),
                const SizedBox(height: 4),

                // ด้านหลัง
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA3C9A8).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFA3C9A8).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA3C9A8).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'คำตอบ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6AAF84),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: backController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'พิมพ์คำตอบ...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      backImg != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(backImg!),
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () =>
                                        setStateModal(() => backImg = null),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : OutlinedButton.icon(
                              onPressed: () async {
                                final p = await _pickImage();
                                if (p != null) setStateModal(() => backImg = p);
                              },
                              icon: const Icon(
                                Icons.add_photo_alternate,
                                size: 18,
                              ),
                              label: const Text('เพิ่มรูป'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
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
                      if (frontController.text.isEmpty &&
                          backController.text.isEmpty &&
                          frontImg == null &&
                          backImg == null)
                        return;
                      final provider = Provider.of<DeckProvider>(
                        context,
                        listen: false,
                      );
                      if (existingCard == null) {
                        provider.addCard(
                          widget.deckId,
                          frontController.text,
                          backController.text,
                          frontImg: frontImg,
                          backImg: backImg,
                        );
                      } else {
                        provider.editCard(
                          widget.deckId,
                          existingCard.id,
                          frontController.text,
                          backController.text,
                          newFrontImg: frontImg,
                          newBackImg: backImg,
                        );
                      }
                      AudioService.instance.playBtnClick();
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'บันทึกการ์ด',
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
      ),
    );
  }

  void _showBulkAddModal(BuildContext context) {
    final List<Map<String, TextEditingController>> rows = List.generate(
      3,
      (_) => {
        'front': TextEditingController(),
        'back': TextEditingController(),
      },
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'เพิ่มหลายการ์ด ✨',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => setModal(() {
                      rows.add({
                        'front': TextEditingController(),
                        'back': TextEditingController(),
                      });
                    }),
                    icon: const Icon(
                      Icons.add,
                      color: Color(0xFFA3C9A8),
                      size: 18,
                    ),
                    label: const Text(
                      'เพิ่มแถว',
                      style: TextStyle(color: Color(0xFFA3C9A8), fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 32, right: 36),
                child: Row(
                  children: const [
                    Expanded(
                      child: Center(
                        child: Text(
                          'คำถาม',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Center(
                        child: Text(
                          'คำตอบ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.42,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: rows.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            '${i + 1}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: rows[i]['front'],
                            decoration: InputDecoration(
                              hintText: 'คำถาม...',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: rows[i]['back'],
                            decoration: InputDecoration(
                              hintText: 'คำตอบ...',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 32,
                          child: rows.length > 1
                              ? IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      setModal(() => rows.removeAt(i)),
                                )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA3C9A8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.save_rounded, color: Colors.white),
                  label: const Text(
                    'บันทึกทั้งหมด',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    final provider = Provider.of<DeckProvider>(
                      context,
                      listen: false,
                    );
                    int added = 0;
                    for (final row in rows) {
                      final front = row['front']!.text.trim();
                      final back = row['back']!.text.trim();
                      if (front.isEmpty && back.isEmpty) continue;
                      provider.addCard(widget.deckId, front, back);
                      added++;
                    }
                    Navigator.pop(ctx);
                    if (added > 0) {
                      AudioService.instance.playBtnClick();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('เพิ่ม $added การ์ดแล้ว! ✨'),
                          backgroundColor: const Color(0xFFA3C9A8),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showCardOptions(BuildContext context, Deck deck, Flashcard card) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.edit_outlined, color: Color(0xFFA3C9A8)),
              ),
              title: const Text('แก้ไขการ์ด'),
              onTap: () {
                Navigator.pop(context);
                _showCardEditorModal(context, existingCard: card);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFEBEE),
                child: Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
              title: const Text(
                'ลบการ์ดนี้',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text('ลบการ์ด?'),
                    content: Text(
                      'ต้องการลบ "${card.front.isNotEmpty ? card.front : '[รูปภาพ]'}" ไหม?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('ยกเลิก'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: () {
                          Provider.of<DeckProvider>(
                            context,
                            listen: false,
                          ).deleteCard(widget.deckId, card.id);
                          Navigator.pop(context);
                          AudioService.instance.playBtnClick();
                        },
                        child: const Text(
                          'ลบเลย',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DeckProvider>(context);
    final deckIndex = provider.decks.indexWhere((d) => d.id == widget.deckId);
    if (deckIndex == -1) return const Scaffold();
    final deck = provider.decks[deckIndex];
    final allSelected =
        deck.cards.isNotEmpty && _selectedIds.length == deck.cards.length;

    // 🆕 deckColor = accent color ของ theme สำรับ
    final deckColor = Color(deck.colorValue);
    // 🆕 ใช้สี bg จาก app theme แทนการทำ AppBar เป็นสีสำรับ
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final cardBg = Theme.of(context).cardTheme.color ?? Colors.white;

    return Scaffold(
      appBar: AppBar(
        // 🆕 พื้นหลัง AppBar ใช้สี scaffold เดิม ไม่ใช้สีสำรับ
        backgroundColor: scaffoldBg,
        // 🆕 ชื่อสำรับใช้สี deckColor เพื่อให้โดดเด่นและเป็นตัวบ่งบอก theme
        title: _selectMode
            ? Text(
                'เลือกแล้ว ${_selectedIds.length} ใบ',
                style: TextStyle(color: textColor),
              )
            : Text(
                deck.title,
                style: TextStyle(
                  color: deckColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
        automaticallyImplyLeading: !_selectMode,
        actions: _selectMode
            ? [
                TextButton(
                  onPressed: () => setState(() {
                    if (allSelected)
                      _selectedIds.clear();
                    else
                      _selectedIds.addAll(deck.cards.map((c) => c.id));
                  }),
                  child: Text(
                    allSelected ? 'ยกเลิกทั้งหมด' : 'เลือกทั้งหมด',
                    style: TextStyle(color: textColor),
                  ),
                ),
                if (_selectedIds.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_rounded,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => _deleteSelected(context, deck),
                  ),
                IconButton(
                  icon: Icon(Icons.close, color: textColor),
                  onPressed: () => setState(() {
                    _selectMode = false;
                    _selectedIds.clear();
                  }),
                ),
              ]
            : [
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: textColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (val) {
                    AudioService.instance.playBtnClick();
                    switch (val) {
                      case 'play':
                        _tryPlay(context, deck);
                        break;
                      case 'select':
                        setState(() {
                          _selectMode = true;
                          _selectedIds.clear();
                        });
                        break;
                      case 'settings':
                        _showDeckSettingsModal(context, deck);
                        break;
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'select',
                      child: Row(
                        children: [
                          Icon(Icons.checklist_rounded, color: Colors.orange),
                          SizedBox(width: 12),
                          Text('เลือกเพื่อลบ'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings_outlined, color: Colors.grey),
                          SizedBox(width: 12),
                          Text('ตั้งค่าสำรับ'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
      ),

      body: Column(
        children: [
          // 🆕 Header แถบสรุป — ใช้ deckColor เป็นแค่ accent บน bg ปกติ
          Container(
            color: deckColor.withOpacity(0.12),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${deck.cards.length} การ์ด',
                      style: TextStyle(
                        color: deckColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      deck.cards.length < 10
                          ? 'ต้องการอีก ${10 - deck.cards.length} ใบเพื่อเล่น'
                          : deck.cards.length > 30
                          ? 'เกินลิมิต! ลบออก ${deck.cards.length - 30} ใบ'
                          : 'พร้อมเล่นแล้ว ✓',
                      style: TextStyle(
                        color: deckColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                // 🆕 badge จำได้ใช้ deckColor border
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: deckColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: deckColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${deck.rememberedIds.length}/${deck.cards.length} จำได้',
                    style: TextStyle(
                      color: deckColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: deck.cards.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.style_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'ยังไม่มีการ์ด',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'กดปุ่ม + ด้านล่างเพื่อเพิ่มการ์ด',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: deck.cards.length,
                    itemBuilder: (context, index) {
                      final card = deck.cards[index];
                      final isSelected = _selectedIds.contains(card.id);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        // 🆕 shadow เพื่อให้การ์ดโดดเด่นออกมาจากพื้นหลัง
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.red.withOpacity(0.04)
                              : cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.redAccent
                                : deckColor.withOpacity(0.15),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: deckColor.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: _selectMode
                              ? Checkbox(
                                  value: isSelected,
                                  activeColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (_) => setState(() {
                                    if (isSelected)
                                      _selectedIds.remove(card.id);
                                    else
                                      _selectedIds.add(card.id);
                                  }),
                                )
                              : card.frontImagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(card.frontImagePath!),
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: deckColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      card.front.isNotEmpty
                                          ? card.front[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: deckColor,
                                      ),
                                    ),
                                  ),
                                ),
                          title: Text(
                            card.front.isNotEmpty ? card.front : '[รูปภาพ]',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              card.back.isNotEmpty ? card.back : '[รูปภาพ]',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                              ),
                            ),
                          ),
                          trailing: _selectMode ? null : null,
                          onTap: _selectMode
                              ? () => setState(() {
                                  if (isSelected)
                                    _selectedIds.remove(card.id);
                                  else
                                    _selectedIds.add(card.id);
                                })
                              : () => _showCardOptions(context, deck, card),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: _selectMode
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'play',
                  backgroundColor: cardBg,
                  elevation: 3,
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: deckColor,
                    size: 32,
                  ),
                  onPressed: () {
                    AudioService.instance.playBtnClick();
                    _tryPlay(context, deck);
                  },
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'add',
                  backgroundColor: deckColor,
                  elevation: 3,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'เพิ่มการ์ด',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => _showAddCardOptions(context),
                ),
              ],
            ),
    );
  }

  void _tryPlay(BuildContext context, Deck deck) {
    if (deck.cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ต้องเพิ่มการ์ดอย่างน้อย 1 ใบก่อน! 🌟')),
      );
      return;
    }
    if (deck.cards.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ต้องมีการ์ดอย่างน้อย 10 ใบ! (ตอนนี้มี ${deck.cards.length} ใบ) 📋',
          ),
        ),
      );
      return;
    }
    if (deck.cards.length > 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('การ์ดเกิน 30 ใบแล้ว! (${deck.cards.length} ใบ) 📋'),
        ),
      );
      return;
    }
    GameRulesDialog.showIfNeeded(context, () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StudyScreen(deckId: deck.id)),
      );
    });
  }
}
