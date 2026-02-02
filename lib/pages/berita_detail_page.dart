import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../services/bps_model.dart';

class BeritaDetailPage extends StatefulWidget {
  final int newsId;

  const BeritaDetailPage({super.key, required this.newsId});

  @override
  State<BeritaDetailPage> createState() => _BeritaDetailPageState();
}

class _BeritaDetailPageState extends State<BeritaDetailPage> {
  final ApiService _apiService = ApiService();
  BpsNewsDetail? _newsDetail;
  bool _isLoading = true;
  String _errorMessage = "";

  // --- FUNGSI UTAMA PEMBERSIH TEKS (DIPERBAIKI) ---
  String _cleanHtmlContent(String htmlContent) {
    if (htmlContent.isEmpty) return "";

    String cleaned = htmlContent;

    // LANGKAH 1: Ubah kode-kode aneh (Entities) menjadi simbol asli dulu
    // Contoh: "&lt;p&gt;" menjadi "<p>"
    // Ini PENTING dilakukan DULUAN supaya tag HTML-nya terbentuk dan bisa dideteksi regex
    cleaned = cleaned
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&lt;', '<')  // Ubah &lt; jadi <
        .replaceAll('&gt;', '>')  // Ubah &gt; jadi >
        .replaceAll('&#39;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&lsquo;', "'")
        .replaceAll('&rsquo;', "'")
        .replaceAll('&ndash;', '-')
        .replaceAll('&mdash;', '-')
        .replaceAll('&copy;', '(c)');

    // LANGKAH 2: Hapus semua tag HTML (seperti <p>, <div>, <br>)
    // Karena di langkah 1 simbol < dan > sudah terbentuk, regex ini sekarang BERFUNGSI
    final RegExp htmlTagRegex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    cleaned = cleaned.replaceAll(htmlTagRegex, '\n'); // Ganti tag dengan baris baru agar rapi

    // LANGKAH 3: Rapikan spasi dan baris baru yang berlebihan
    cleaned = cleaned.replaceAll(RegExp(r'\n\s*\n'), '\n\n'); // Maksimal 2 enter
    cleaned = cleaned.trim();

    return cleaned;
  }

  @override
  void initState() {
    super.initState();
    _fetchNewsDetail();
  }

  void _fetchNewsDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final detail = await _apiService.getNewsDetail(widget.newsId);
      if (mounted) {
        setState(() {
          _newsDetail = detail;
          _isLoading = false;
          if (detail == null) {
            _errorMessage = "Berita tidak ditemukan.";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Terjadi kesalahan: $e";
        });
      }
    }
  }

  // Helper untuk memperbaiki URL gambar BPS
  String _constructImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    if (imageUrl.startsWith('/')) {
      return 'https://webapi.bps.go.id$imageUrl';
    }
    return 'https://webapi.bps.go.id/$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: const Text("Detail Berita", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_errorMessage, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchNewsDetail,
                        child: const Text("Coba Lagi"),
                      ),
                    ],
                  ),
                )
              : _newsDetail == null
                  ? const Center(child: Text("Data tidak tersedia"))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- GAMBAR BERITA ---
                          if (_newsDetail!.picture.isNotEmpty)
                            Container(
                              width: double.infinity,
                              height: 220,
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  _constructImageUrl(_newsDetail!.picture),
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (ctx, err, stack) => Container(
                                    color: Colors.grey[200],
                                    child: Icon(Icons.broken_image, size: 50, color: Colors.grey[400]),
                                  ),
                                ),
                              ),
                            ),

                          // --- JUDUL BERITA ---
                          Text(
                            _newsDetail!.title,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- TANGGAL RILIS ---
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: theme.primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                _newsDetail!.rlDate,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          Divider(color: Colors.grey[300], thickness: 1),
                          const SizedBox(height: 24),

                          // --- ISI BERITA (TEXT ONLY) ---
                          Text(
                            _cleanHtmlContent(_newsDetail!.news),
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.8, // Spasi antar baris biar enak dibaca
                              color: isDark ? Colors.grey[300] : Colors.grey[800],
                            ),
                            textAlign: TextAlign.justify, // Rata kanan kiri
                          ),

                          const SizedBox(height: 40),

                          // --- FOOTER COPYRIGHT ---
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.primaryColor.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: theme.primaryColor),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Sumber: Badan Pusat Statistik (BPS) Kabupaten Klaten",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
    );
  }
}