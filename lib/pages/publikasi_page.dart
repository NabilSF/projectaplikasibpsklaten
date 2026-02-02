import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Pastikan package ini ada
import '../services/api_services.dart';
import '../services/bps_model.dart';

class PublikasiPage extends StatefulWidget {
  const PublikasiPage({super.key});

  @override
  State<PublikasiPage> createState() => _PublikasiPageState();
}

class _PublikasiPageState extends State<PublikasiPage> {
  final ApiService _apiService = ApiService();
  List<BpsPublikasi> _listPublikasi = [];
  bool _isLoading = true;
  String _errorMessage = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData({String keyword = ""}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final data = await _apiService.getPublikasi(keyword: keyword);
      if (mounted) {
        setState(() {
          _listPublikasi = data;
          _isLoading = false;
          if (data.isEmpty) {
            _errorMessage = "Tidak ada publikasi ditemukan";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Gagal memuat data: $e";
        });
      }
    }
  }

  // Helper: Memperbaiki URL Gambar dari API BPS
  String _constructImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) return '';
    // Jika URL sudah lengkap
    if (imageUrl.startsWith('http')) return imageUrl;
    // Jika URL relatif, tambahkan domain BPS
    return 'https://webapi.bps.go.id/$imageUrl'; 
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal membuka link")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F6FA), // Background abu muda biar card menonjol
      appBar: AppBar(
        title: const Text("Publikasi Statistik", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- SEARCH BAR AREA ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            color: theme.primaryColor, // Menyatu dengan AppBar
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (value) => _fetchData(keyword: value),
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: "Cari judul publikasi...",
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Tombol Cari Biru Tua (Opsional, karena sudah ada icon search di field)
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue[800], // Warna lebih gelap dari primary
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () => _fetchData(keyword: _searchController.text),
                  ),
                ),
              ],
            ),
          ),

          // --- CONTENT LIST ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.library_books_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(_errorMessage, style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 100), // Bottom padding untuk navigasi
                        itemCount: _listPublikasi.length,
                        itemBuilder: (context, index) {
                          return _buildPublikasiCard(context, _listPublikasi[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublikasiCard(BuildContext context, BpsPublikasi item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cover Image (Thumbnail)
            Container(
              width: 80,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                ],
              ),
              child: item.cover.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _constructImageUrl(item.cover),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                            Icon(Icons.broken_image, color: Colors.grey[400]),
                      ),
                    )
                  : Icon(Icons.book, color: theme.primaryColor, size: 40),
            ),
            
            const SizedBox(width: 16),

            // 2. Info & Download Button
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Tanggal Update
                  Text(
                    "Update: ${item.rlDate}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tombol Download PDF
                  if (item.pdf.isNotEmpty)
                    SizedBox(
                      height: 36,
                      child: ElevatedButton.icon(
                        onPressed: () => _launchUrl(item.pdf),
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: Text(
                          "Download PDF", 
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor.withOpacity(0.1), // Background transparan biru
                          foregroundColor: theme.primaryColor, // Teks & Icon biru
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}