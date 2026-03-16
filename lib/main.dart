import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/deck_provider.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/tutorial_screen.dart';
import 'screens/store_screen.dart';
import 'screens/fish_tank_screen.dart';
import 'services/audio_service.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioService.instance.init();
  final prefs = await SharedPreferences.getInstance();
  final isFirstRun = prefs.getBool('isFirstRun') ?? true;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeckProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: CozyFlashcardApp(isFirstRun: isFirstRun),
    ),
  );
}

class CozyFlashcardApp extends StatelessWidget {
  final bool isFirstRun;
  const CozyFlashcardApp({super.key, required this.isFirstRun});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final primary = themeProvider.primaryColor;
        final bg = themeProvider.bgColor;
        final isDark = themeProvider.isDark;

        final textColor = isDark
            ? const Color(0xFFF0F0F0)
            : const Color(0xFF4A4A4A);
        final subTextColor = isDark ? const Color(0xFFAAAAAA) : Colors.grey;
        final cardColor = isDark ? const Color(0xFF262640) : Colors.white;
        final dividerColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;

        return MaterialApp(
          title: 'Cozy Flashcards',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: isDark ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: bg,
            primaryColor: primary,
            // ── colorScheme ครอบคลุม widget ทุกตัว ──
            colorScheme: ColorScheme(
              brightness: isDark ? Brightness.dark : Brightness.light,
              primary: primary,
              onPrimary: Colors.white,
              secondary: primary,
              onSecondary: Colors.white,
              surface: cardColor,
              onSurface: textColor,
              error: Colors.redAccent,
              onError: Colors.white,
            ),
            // ── textTheme ──────────────────────────────
            textTheme: GoogleFonts.promptTextTheme(
              isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
            ).apply(bodyColor: textColor, displayColor: textColor),
            // ── AppBar ─────────────────────────────────
            appBarTheme: AppBarTheme(
              backgroundColor: bg,
              elevation: 0,
              iconTheme: IconThemeData(color: textColor),
              titleTextStyle: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.prompt().fontFamily,
              ),
            ),
            // ── Card ───────────────────────────────────
            cardTheme: CardThemeData(
              color: cardColor,
              elevation: isDark ? 0 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: isDark
                    ? BorderSide(color: Colors.grey[800]!, width: 1)
                    : BorderSide.none,
              ),
            ),
            // ── ElevatedButton ─────────────────────────
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            // ── OutlinedButton ─────────────────────────
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: textColor,
                side: BorderSide(color: subTextColor),
              ),
            ),
            // ── TextButton ─────────────────────────────
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primary),
            ),
            // ── BottomNav ──────────────────────────────
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: cardColor,
              selectedItemColor: primary,
              unselectedItemColor: subTextColor,
            ),
            // ── TabBar ─────────────────────────────────
            tabBarTheme: TabBarThemeData(
              labelColor: primary,
              unselectedLabelColor: subTextColor,
              indicatorColor: primary,
            ),
            // ── Slider ─────────────────────────────────
            sliderTheme: SliderThemeData(
              activeTrackColor: primary,
              thumbColor: primary,
              inactiveTrackColor: isDark ? Colors.grey[700] : Colors.grey[200],
            ),
            // ── Input ──────────────────────────────────
            inputDecorationTheme: InputDecorationTheme(
              filled: isDark,
              fillColor: isDark ? const Color(0xFF2E2E4E) : null,
              labelStyle: TextStyle(color: subTextColor),
              hintStyle: TextStyle(color: subTextColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: dividerColor),
              ),
            ),
            // ── Divider ────────────────────────────────
            dividerColor: dividerColor,
            // ── ListTile ───────────────────────────────
            listTileTheme: ListTileThemeData(
              textColor: textColor,
              iconColor: subTextColor,
            ),
            // ── PopupMenu ──────────────────────────────
            popupMenuTheme: PopupMenuThemeData(
              color: cardColor,
              textStyle: TextStyle(color: textColor),
            ),
            // ── Dialog ─────────────────────────────────
            dialogTheme: DialogThemeData(
              backgroundColor: cardColor,
              titleTextStyle: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.prompt().fontFamily,
              ),
              contentTextStyle: TextStyle(color: textColor, fontSize: 14),
            ),
            // ── SnackBar ───────────────────────────────
            snackBarTheme: SnackBarThemeData(
              backgroundColor: isDark
                  ? const Color(0xFF3A3A5A)
                  : const Color(0xFF4A4A4A),
              contentTextStyle: const TextStyle(color: Colors.white),
            ),
          ),
          home: isFirstRun ? const TutorialScreen() : const MainNavigation(),
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    const FishTankScreen(),
    const HomeScreen(),
    const StoreScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Consumer<DeckProvider>(
        builder: (context, provider, _) {
          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.water),
                    if (provider.needsFoodWarning)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'ตู้ปลา',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.style),
                label: 'สำรับ',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'ร้านค้า',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'โปรไฟล์',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded),
                label: 'ตั้งค่า',
              ),
            ],
          );
        },
      ),
    );
  }
}
