import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tentang Aplikasi", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView( // Agar aman di layar kecil
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Aplikasi
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bar_chart_rounded, size: 50, color: theme.primaryColor),
              ),
              const SizedBox(height: 24),
              
              const Text(
                "KLASTAT",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Klaten Statistik Mobile",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              
              // PERBAIKAN: Warna Badge Versi Dinamis (Dark/Light)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Versi 1.0.0", 
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black87,
                  )
                ),
              ),

              const SizedBox(height: 30),
              
              const Text(
                "Aplikasi resmi dari Badan Pusat Statistik Kabupaten Klaten untuk memudahkan akses data strategis, publikasi, berita resmi statistik, dan tabel statis secara cepat dan mudah dalam genggaman.",
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.5),
              ),

              const SizedBox(height: 50),
              
              Text(
                "© 2026 BPS Kabupaten Klaten",
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}