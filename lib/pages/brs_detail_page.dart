import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_services.dart';
import '../services/bps_model.dart';

class BrsDetailPage extends StatefulWidget {
  final String brsId;

  const BrsDetailPage({super.key, required this.brsId});

  @override
  State<BrsDetailPage> createState() => _BrsDetailPageState();
}

class _BrsDetailPageState extends State<BrsDetailPage> {
  final ApiService _apiService = ApiService();
  BpsPressRelease? _pressReleaseDetail;
  bool _isLoading = true;

  // --- 1. MEMBERSIHKAN TEKS (LOGIKA KUAT) ---
  String _cleanHtmlContent(String htmlContent) {
    if (htmlContent.isEmpty) return "";
    String cleaned = htmlContent;

    // Decode HTML Entities DULUAN
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

    // Baru Hapus Tag HTML
    final RegExp htmlTagRegex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    cleaned = cleaned.replaceAll(htmlTagRegex, ' ');

    // Rapikan Spasi
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned;
  }

  // --- 2. MEMPERBAIKI URL GAMBAR ---
  String _constructImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) return '';
    // Jika sudah ada http/https, pakai langsung
    if (imageUrl.startsWith('http')) return imageUrl;
    // Jika belum, tambahkan domain webapi BPS
    return 'https://webapi.bps.go.id/$imageUrl';
  }

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  void _fetchDetail() async {
    setState(() => _isLoading = true);
    try {
      final allList = await _apiService.getPressReleases();
      final detail = allList.firstWhere(
        (e) => e.brsId == widget.brsId,
        orElse: () => throw Exception("Data tidak ditemukan"),
      );
      
      if (mounted) {
        setState(() {
          _pressReleaseDetail = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal membuka file")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_pressReleaseDetail == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text("Data tidak ditemukan")));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: const Text("Detail BRS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            
            // --- GAMBAR COVER (FIXED) ---
            Container(
              width: double.infinity,
              height: 200, // Sedikit lebih tinggi biar jelas
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _pressReleaseDetail!.cover.isNotEmpty
                    ? Image.network(
                        _constructImageUrl(_pressReleaseDetail!.cover), // Panggil helper URL
                        fit: BoxFit.contain, // Agar gambar tidak terpotong (contain) atau cover (penuh)
                        errorBuilder: (ctx, err, stack) => 
                            Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey[400])),
                      )
                    : Center(child: Icon(Icons.analytics, size: 80, color: Colors.blue[200])),
              ),
            ),
            
            const SizedBox(height: 24),

            // Judul & Tanggal
            Text(
              _pressReleaseDetail!.title.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Dirilis pada tanggal ${_pressReleaseDetail!.rlDate}",
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),

            const SizedBox(height: 30),

            // Tombol Aksi
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.inventory_2_outlined,
                    label: "Infografis",
                    subLabel: "Unduh",
                    isAvailable: true,
                    onTap: () {
                      if (_pressReleaseDetail!.pdf.isNotEmpty) {
                        _launchUrl(_pressReleaseDetail!.pdf);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.qr_code_2, 
                    label: "Bahan Tayang",
                    subLabel: "Belum tersedia",
                    isAvailable: false,
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Abstrak (Teks Bersih)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Abstraksi",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _cleanHtmlContent(_pressReleaseDetail!.abstract), // Panggil helper pembersih
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.6,
              ),
              textAlign: TextAlign.justify,
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
      
      // Tombol Download Bawah
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
          ],
        ),
        child: Row(
          children: [
            _buildIconButton(context, Icons.favorite_border),
            const SizedBox(width: 12),
            _buildIconButton(context, Icons.near_me_outlined),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_pressReleaseDetail!.pdf.isNotEmpty) {
                    _launchUrl(_pressReleaseDetail!.pdf);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  "Unduh (${_pressReleaseDetail!.size})",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {
    required IconData icon, 
    required String label, 
    required String subLabel,
    required bool isAvailable,
    required VoidCallback onTap
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: isAvailable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isAvailable ? Colors.black87 : Colors.grey),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subLabel,
              style: TextStyle(fontSize: 12, color: isAvailable ? Colors.grey[600] : Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: isDark ? Colors.white : Colors.black87, size: 24),
    );
  }
}