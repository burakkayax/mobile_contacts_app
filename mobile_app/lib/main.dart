import 'package:flutter/material.dart';
import 'screens/person_list_screen.dart';

void main() {
  // Uygulamanın başlangıç noktası: Kök widget olarak PersonManagementApp çalıştırılır.
  runApp(const PersonManagementApp());
}

class PersonManagementApp extends StatelessWidget {
  const PersonManagementApp({super.key});

  // Yönergedeki modern mavi-kırmızı kurumsal renk paleti için ana tohum rengi
  static const Color _seedColor = Color(0xFF3B5BDB);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
      primary: const Color(0xFF3B5BDB),
      error: const Color(0xFFDC2626),
      surface: const Color(0xFFF6F8FC),
    );

    return MaterialApp(
      title: 'Rehber / Kişi Listesi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
        // Üst bar (AppBar) stili
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        // Liste ve detay kartlarının stili
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        // Form metin kutularının (TextFormField) ortak görünümü
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
        ),
        // Ana aksiyon butonlarının (FilledButton) stili
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 48),
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Sağ alt köşedeki sabit + (FAB) butonunun stili
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: const CircleBorder(),
        ),
      ),
      // 1. Kişi Listesi (Ana Sayfa) ile uygulama açılır
      home: const PersonListScreen(),
    );
  }
}
