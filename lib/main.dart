import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'pages/home_page.dart';
import 'pages/tabel_page.dart';
import 'pages/pencarian_page.dart';
import 'pages/publikasi_page.dart';
// Note: Page Berita, BRS, DataEksporImpor tetap diimport

// --- IMPORT HALAMAN BARU ---
import 'pages/about_app_page.dart';
import 'pages/faq_page.dart';
import 'pages/rencana_terbit_page.dart'; 

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<int> selectedIndexNotifier = ValueNotifier(0);

final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>();

void navigateToDetailPage(Widget detailPage) {
  mainScreenKey.currentState?.showDetailPage(detailPage);
}

void closeDetailPage() {
  mainScreenKey.currentState?.closeDetailPage();
}

void closeAllDetailPages() {
  mainScreenKey.currentState?.closeAllDetailPages();
}

// UPDATE: Tinggi modal disesuaikan agar tampilan card lebih leluasa
void showLainnyaModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.7, // 70% Layar
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
    const Color bpsPrimary = Color(0xFF4A8BDF); 
    const Color bpsSecondary = Color(0xFFA0006D); 

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
  final List<Widget> _pages = [
    const HomePage(),
    const TabelPage(),
    const PencarianPage(),
    const PublikasiPage(),
  ];

  final List<Widget> _detailPages = <Widget>[];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndexNotifier,
      builder: (context, selectedIndex, child) {
        return Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              IndexedStack(
                index: selectedIndex < 4 ? selectedIndex : 0,
                children: _pages,
              ),
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
                  showLainnyaModal(context);
                } else {
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

// --- KONTEN MODAL LAINNYA (REDESIGNED) ---

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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        // Handle bar & Header yang lebih bersih
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
          child: Column(
            children: [
              Container(
                width: 50, height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Menu Lainnya", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("Pintas layanan dan informasi", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.grey.withOpacity(0.1),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 10),

        // Konten Scrollable dengan Card Modern
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              
              // --- SECTION 1: JADWAL & DATA ---
              _buildSectionHeader("Informasi Statistik"),
              _buildModernCard(
                context,
                title: "Rencana Terbit",
                subtitle: "Jadwal rilis data BPS terbaru",
                icon: Icons.calendar_month_rounded,
                color: Colors.purple,
                onTap: () {
                  Navigator.pop(context);
                  navigateToDetailPage(const RencanaTerbitPage()); 
                }
              ),

              const SizedBox(height: 24),

              // --- SECTION 2: PELAYANAN ---
              _buildSectionHeader("Layanan Pengaduan"),
              Row(
                children: [
                  Expanded(
                    child: _buildSmallCard(
                      context,
                      title: "Lapor!",
                      icon: Icons.campaign_rounded,
                      color: Colors.redAccent,
                      onTap: () async {
                        Navigator.pop(context);
                        _launchExternalUrl(context, 'https://www.lapor.go.id/');
                      }
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSmallCard(
                      context,
                      title: "WhatsApp",
                      icon: Icons.chat_bubble_rounded,
                      color: Colors.green,
                      onTap: () async {
                        Navigator.pop(context);
                        _launchExternalUrl(context, 'https://wa.me/628977703310');
                      }
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- SECTION 3: BANTUAN ---
              _buildSectionHeader("Tentang & Bantuan"),
              _buildModernCard(
                context,
                title: "FAQ",
                subtitle: "Pertanyaan yang sering diajukan",
                icon: Icons.help_outline_rounded,
                color: Colors.teal,
                onTap: () { 
                  Navigator.pop(context); 
                  navigateToDetailPage(const FaqPage());
                }
              ),
              const SizedBox(height: 12),
              _buildModernCard(
                context,
                title: "Tentang Aplikasi",
                subtitle: "Versi 1.0.0",
                icon: Icons.info_outline_rounded,
                color: isDark ? Colors.grey : Colors.blueGrey,
                onTap: () { 
                  Navigator.pop(context); 
                  navigateToDetailPage(const AboutAppPage());
                }
              ),

              const SizedBox(height: 40), 
            ],
          ),
        ),
      ],
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2
        ),
      ),
    );
  }

  // Card Besar Memanjang
  Widget _buildModernCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08), // Shadow berwarna sesuai icon
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ]
          ),
          child: Row(
            children: [
              // Icon Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              
              // Text Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),

              // Arrow
              Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  // Card Kecil (Kotak)
  Widget _buildSmallCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}