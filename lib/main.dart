import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // Pastikan package ini sudah diinstal

import 'pages/home_page.dart';
import 'pages/tabel_page.dart';
import 'pages/pencarian_page.dart';
import 'pages/publikasi_page.dart';
import 'pages/berita_page.dart';
import 'pages/data_ekspor_impor_page.dart';
import 'pages/brs_page.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<int> selectedIndexNotifier = ValueNotifier(0);

// Global key untuk akses MainScreen dari halaman lain
final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>();

// Helper functions untuk navigasi persistent footer
void navigateToDetailPage(Widget detailPage) {
  mainScreenKey.currentState?.showDetailPage(detailPage);
}

void closeDetailPage() {
  mainScreenKey.currentState?.closeDetailPage();
}

void closeAllDetailPages() {
  mainScreenKey.currentState?.closeAllDetailPages();
}

// Fungsi untuk memunculkan modal Lainnya
void showLainnyaModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const LainnyaModalContent(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bpsPrimary = Color(0xFF4A8BDF); // Dark blue
    const Color bpsSecondary = Color(0xFFA0006D); // Eggplant

    // Helper untuk style input text
    InputDecorationTheme modernInputTheme(bool isDark) {
      return InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F6FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 14),
        prefixIconColor: isDark ? Colors.grey[400] : Colors.grey[400],
      );
    }

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'BPS Klaten Modern',

          // --- LIGHT THEME ---
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: bpsPrimary,
              primary: bpsPrimary,
              secondary: bpsSecondary,
              surface: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: bpsPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
            ),
            inputDecorationTheme: modernInputTheme(false),
            textTheme: GoogleFonts.plusJakartaSansTextTheme(),
          ),

          // --- DARK THEME ---
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            colorScheme: ColorScheme.fromSeed(
              seedColor: bpsPrimary,
              primary: bpsPrimary,
              secondary: bpsSecondary,
              surface: const Color(0xFF1E1E1E),
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            inputDecorationTheme: modernInputTheme(true),
            textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
          ),

          themeMode: mode,
          home: MainScreen(key: mainScreenKey),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // List halaman utama (4 menu di navigasi bawah)
  final List<Widget> _pages = [
    const HomePage(),
    const TabelPage(),
    const PencarianPage(),
    const PublikasiPage(),
  ];

  // Stack untuk detail pages yang persistent dengan footer
  final List<Widget> _detailPages = <Widget>[];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndexNotifier,
      builder: (context, selectedIndex, child) {
        return Scaffold(
          extendBody: true,
          // Stack untuk menampilkan halaman utama + detail pages
          body: Stack(
            children: [
              // Halaman utama (selalu di background)
              IndexedStack(
                index: selectedIndex < 4 ? selectedIndex : 0,
                children: _pages,
              ),
              // Detail pages (jika ada) - akan menutupi halaman utama
              ..._detailPages,
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5))
              ],
            ),
            child: NavigationBar(
              height: 70,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              elevation: 0,
              selectedIndex: selectedIndex < 4 ? selectedIndex : 0,
              onDestinationSelected: (index) {
                if (index == 4) {
                  // MUNCULKAN MODAL SHEET (Tanpa mengubah halaman)
                  showLainnyaModal(context);
                } else {
                  // Pindah halaman biasa - tapi tutup detail pages dulu jika ada
                  if (_detailPages.isNotEmpty) {
                    setState(() {
                      _detailPages.clear();
                    });
                  }
                  selectedIndexNotifier.value = index;
                }
              },
              indicatorColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.15),
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.home_rounded), label: "Beranda"),
                NavigationDestination(
                    icon: Icon(Icons.table_chart_rounded), label: "Tabel"),
                NavigationDestination(
                    icon: Icon(Icons.search_rounded), label: "Cari"),
                NavigationDestination(
                    icon: Icon(Icons.menu_book_rounded), label: "Publikasi"),
                NavigationDestination(
                    icon: Icon(Icons.grid_view_rounded), label: "Lainnya"),
              ],
            ),
          ),
        );
      },
    );
  }

  // Method untuk menampilkan detail page secara persistent
  void showDetailPage(Widget detailPage) {
    setState(() {
      _detailPages.add(detailPage);
    });
  }

  // Method untuk menutup detail page
  void closeDetailPage() {
    if (_detailPages.isNotEmpty) {
      setState(() {
        _detailPages.removeLast();
      });
    }
  }

  // Method untuk menutup semua detail pages
  void closeAllDetailPages() {
    if (_detailPages.isNotEmpty) {
      setState(() {
        _detailPages.clear();
      });
    }
  }
}

// --- KONTEN MODAL LAINNYA ---

class LainnyaModalContent extends StatelessWidget {
  const LainnyaModalContent({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandGreen = Color(0xFF2AA090); // Warna hijau request

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView( // Scrollable agar aman di layar kecil
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar kecil di atas modal
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header Judul & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Lainnya", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row Notifikasi & Bookmark
            Row(
              children: [
                Expanded(child: _buildBigButton(context, Icons.notifications_none, "Notifikasi", "1 Pesan", brandGreen)),
                const SizedBox(width: 12),
                Expanded(child: _buildBigButton(context, Icons.bookmark_border, "Bookmark", "0 Konten", brandGreen)),
              ],
            ),
            const SizedBox(height: 20),

            // --- DAFTAR MENU ---

            _buildMenuTile(
              context,
              Icons.insert_chart_outlined,
              "Berita BPS Kabupaten Klaten",
              brandGreen,
              () {
                Navigator.pop(context);
                navigateToDetailPage(const BeritaPage());
              }
            ),

            // --- MENU RENCANA TERBIT (POP-UP DI TENGAH) ---
            _buildMenuTile(
              context,
              Icons.calendar_month_outlined,
              "Rencana Terbit",
              brandGreen,
              () {
                // Tampilkan DIALOG (Pop-up tengah)
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Column(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 50, color: brandGreen),
                          const SizedBox(height: 10),
                          const Text("Informasi", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      content: const Text(
                        "Mohon maaf, fitur ini belum tersedia untuk saat ini.",
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Tutup dialog
                            },
                            child: const Text("Tutup", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            ),

            _buildMenuTile(
              context,
              Icons.language_outlined,
              "Data Ekspor Impor",
              brandGreen,
              () {
                Navigator.pop(context);
                navigateToDetailPage(const DataEksporImporPage());
              }
            ),

            _buildMenuTile(
              context,
              Icons.article_outlined,
              "Berita Resmi Statistik",
              brandGreen,
              () {
                Navigator.pop(context);
                navigateToDetailPage(const BrsPage());
              }
            ),

            // --- TOMBOL TENTANG KAMI ---
            _buildMenuTile(
              context,
              Icons.info_outline,
              "Tentang Kami",
              brandGreen,
              () async { 
                Navigator.pop(context); 
                const url = 'https://klatenkab.bps.go.id'; 
                final Uri uri = Uri.parse(url);

                try {
                  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                    throw 'Could not launch $url';
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Gagal membuka link: $e"))
                    );
                  }
                }
              }
            ),

            const SizedBox(height: 30), // Padding bawah
          ],
        ),
      ),
    );
  }

  Widget _buildBigButton(BuildContext context, IconData icon, String title, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  // Widget Tile Menu
  Widget _buildMenuTile(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap, // Parameter onTap wajib ada
    );
  }
}