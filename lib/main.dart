import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'pages/home_page.dart';
import 'pages/tabel_page.dart';
import 'pages/pencarian_page.dart';
import 'pages/publikasi_page.dart';
import 'pages/berita_page.dart';
import 'pages/data_ekspor_impor_page.dart';
import 'pages/brs_page.dart';

// --- IMPORT HALAMAN BARU ---
import 'pages/about_app_page.dart';
import 'pages/faq_page.dart';

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
    builder: (context) => Container(
      // Tinggi modal menyesuaikan konten tapi maksimal 75% layar agar proporsional
      height: MediaQuery.of(context).size.height * 0.75, 
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: const LainnyaModalContent(),
    ),
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
          title: 'KLASTAT',

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
                  // MUNCULKAN MODAL SHEET
                  showLainnyaModal(context);
                } else {
                  // Pindah halaman biasa
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

  void showDetailPage(Widget detailPage) {
    setState(() {
      _detailPages.add(detailPage);
    });
  }

  void closeDetailPage() {
    if (_detailPages.isNotEmpty) {
      setState(() {
        _detailPages.removeLast();
      });
    }
  }

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

  Future<void> _launchExternalUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal membuka link: $urlString"))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandGreen = Color(0xFF2AA090); 

    return Column(
      children: [
        // Handle bar & Header (Fixed di atas)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Column(
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
              ),
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
            ],
          ),
        ),
        
        const Divider(),

        // Konten Scrollable
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              // Row Notifikasi & Bookmark (Placeholder)
              Row(
                children: [
                  Expanded(child: _buildBigButton(context, Icons.notifications_none, "Notifikasi", "1 Pesan", Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildBigButton(context, Icons.bookmark_border, "Bookmark", "0 Konten", Colors.blue)),
                ],
              ),
              const SizedBox(height: 20),

              // --- DAFTAR MENU ---

              _buildMenuTile(
                context,
                Icons.insert_chart_outlined,
                "Berita BPS Kabupaten Klaten",
                Colors.orange,
                () {
                  Navigator.pop(context);
                  navigateToDetailPage(const BeritaPage());
                }
              ),

              _buildMenuTile(
                context,
                Icons.calendar_month_outlined,
                "Rencana Terbit",
                Colors.purple,
                () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Column(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 50, color: Colors.purple),
                            SizedBox(height: 10),
                            Text("Informasi", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        content: const Text("Mohon maaf, fitur ini belum tersedia untuk saat ini.", textAlign: TextAlign.center),
                        actions: [
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("Tutup", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
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
                Colors.blueAccent,
                () {
                  Navigator.pop(context);
                  navigateToDetailPage(const DataEksporImporPage());
                }
              ),

              _buildMenuTile(
                context,
                Icons.article_outlined,
                "Berita Resmi Statistik",
                Colors.indigo,
                () {
                  Navigator.pop(context);
                  navigateToDetailPage(const BrsPage());
                }
              ),

              // --- MENU LAYANAN PENGADUAN (LAPOR!) ---
              _buildMenuTile(
                context,
                Icons.campaign_outlined, 
                "Layanan Pengaduan (Lapor!)",
                Colors.redAccent,
                () async {
                  Navigator.pop(context);
                  _launchExternalUrl(context, 'https://www.lapor.go.id/');
                }
              ),

              // --- MENU WHATSAPP ---
              _buildMenuTile(
                context,
                Icons.chat_outlined,
                "WhatsApp Pelayanan",
                Colors.green,
                () async {
                  Navigator.pop(context);
                  _launchExternalUrl(context, 'https://wa.me/628977703310');
                }
              ),

              // --- MENU FAQ (BARU) ---
              _buildMenuTile(
                context,
                Icons.help_outline_rounded,
                "FAQ",
                Colors.teal, // Warna Teal untuk Bantuan
                () { 
                  Navigator.pop(context); 
                  navigateToDetailPage(const FaqPage()); // Navigasi ke Halaman FAQ
                }
              ),

              // --- MENU TENTANG APLIKASI (DULU TENTANG KAMI) ---
              _buildMenuTile(
                context,
                Icons.info_outline,
                "Tentang Aplikasi",
                Colors.grey[700]!, // Warna Abu tua
                () { 
                  Navigator.pop(context); 
                  navigateToDetailPage(const AboutAppPage()); // Navigasi ke Halaman Tentang Aplikasi
                }
              ),

              const SizedBox(height: 30), 
            ],
          ),
        ),
      ],
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

  Widget _buildMenuTile(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap, 
    );
  }
}