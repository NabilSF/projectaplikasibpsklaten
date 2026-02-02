import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQ", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        // PERBAIKAN: Menambahkan bottom padding 50 agar tidak mentok
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 50),
        children: const [
          FaqTile(
            question: "Apa itu aplikasi KLASTAT?",
            answer: "KLASTAT adalah aplikasi mobile resmi dari BPS Kabupaten Klaten yang menyediakan data statistik strategis, publikasi, dan berita terbaru seputar Kabupaten Klaten.",
          ),
          FaqTile(
            question: "Apakah data di aplikasi ini gratis?",
            answer: "Ya, seluruh data yang disajikan dalam aplikasi ini dapat diakses dan diunduh secara gratis oleh masyarakat umum.",
          ),
          FaqTile(
            question: "Bagaimana cara mengunduh Publikasi?",
            answer: "Masuk ke menu 'Publikasi', pilih judul yang diinginkan, lalu klik tombol 'Unduh PDF' di bagian bawah detail halaman.",
          ),
          FaqTile(
            question: "Bagaimana cara request data khusus?",
            answer: "Anda dapat menggunakan fitur 'Request Data' di halaman beranda atau menu 'Lainnya' yang akan menghubungkan Anda langsung ke layanan WhatsApp Pelayanan Statistik Terpadu (PST).",
          ),
          FaqTile(
            question: "Seberapa sering data diperbarui?",
            answer: "Data diperbarui secara berkala sesuai dengan jadwal rilis resmi BPS. Anda dapat melihat tanggal rilis pada setiap item data.",
          ),
          // Tambahan FAQ agar list terlihat lebih panjang sedikit
          FaqTile(
            question: "Apakah aplikasi ini membutuhkan koneksi internet?",
            answer: "Ya, aplikasi KLASTAT membutuhkan koneksi internet untuk mengambil data terbaru langsung dari server BPS.",
          ),
        ],
      ),
    );
  }
}

class FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const FaqTile({super.key, required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // Border tipis agar terlihat rapi di dark mode
        side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.2)),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        iconColor: theme.primaryColor,
        collapsedIconColor: Colors.grey,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700], 
                height: 1.5
              ),
            ),
          ),
        ],
      ),
    );
  }
}