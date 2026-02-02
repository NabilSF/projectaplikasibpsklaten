import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Pastikan import ini ada
import 'berita_page.dart';
import 'data_ekspor_impor_page.dart';
import 'brs_page.dart';

// Fungsi untuk memunculkan modal (Tidak berubah)
void showLainnyaModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const LainnyaModalContent(),
  );
}

class LainnyaModalContent extends StatelessWidget {
  const LainnyaModalContent({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandGreen = Color(0xFF2AA090);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar kecil
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
            
            // Row Notifikasi & Bookmark (Placeholder)
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
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const BeritaPage())
                );
              }
            ),
            
            _buildMenuTile(
              context, 
              Icons.calendar_month_outlined, 
              "Rencana Terbit", 
              brandGreen,
              () {
                // Aksi Rencana Terbit (bisa diarahkan ke website jadwal rilis jika mau)
                debugPrint("Rencana Terbit diklik");
              }
            ),
            
            _buildMenuTile(
              context,
              Icons.language_outlined,
              "Data Ekspor Impor",
              brandGreen,
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DataEksporImporPage())
                );
              }
            ),
            
            _buildMenuTile(
              context,
              Icons.article_outlined,
              "Berita Resmi Statistik",
              brandGreen,
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BrsPage())
                );
              }
            ),

            // --- PERBAIKAN DI SINI: TOMBOL TENTANG KAMI ---
            _buildMenuTile(
              context,
              Icons.info_outline,
              "Tentang Kami",
              brandGreen,
              () async {
                // Link Website BPS Klaten
                const url = 'https://klatenkab.bps.go.id'; 
                final Uri uri = Uri.parse(url);

                if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Gagal membuka website"))
                    );
                  }
                }
              }
            ),
            
            const SizedBox(height: 30),
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

  Widget _buildMenuTile(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}