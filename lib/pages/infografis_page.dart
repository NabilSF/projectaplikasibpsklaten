import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_services.dart'; 
import '../services/bps_model.dart';

class InfografisPage extends StatefulWidget {
  const InfografisPage({super.key});

  @override
  State<InfografisPage> createState() => _InfografisPageState();
}

class _InfografisPageState extends State<InfografisPage> {
  final ApiService _apiService = ApiService();
  List<BpsInfografis> _listInfo = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData({String keyword = ""}) async {
    setState(() => _isLoading = true);
    final data = await _apiService.getInfografis(keyword: keyword);
    setState(() {
      _listInfo = data;
      _isLoading = false;
    });
  }

  // Fungsi untuk construct URL gambar
  String _constructImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) return '';

    // Jika URL sudah lengkap (http/https), return as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // Jika URL relatif, tambahkan base URL BPS
    if (imageUrl.startsWith('/')) {
      return 'https://webapi.bps.go.id$imageUrl';
    }

    // Jika URL relatif tanpa slash, tambahkan base URL BPS
    return 'https://webapi.bps.go.id/$imageUrl';
  }

  // Fungsi Zoom Gambar
  void _showImageDialog(BuildContext context, String imgUrl, String title, String dlUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.network(
                _constructImageUrl(imgUrl),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: const Column(
                      children: [
                        Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        Text("Gagal memuat gambar penuh"),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  onPressed: () async {
                    if (dlUrl.isNotEmpty) {
                      final Uri url = Uri.parse(dlUrl);
                      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal membuka link download")));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link download tidak tersedia")));
                    }
                  },
                  label: const Text("Download"),
                  icon: const Icon(Icons.download),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                const SizedBox(width: 12),
                FloatingActionButton.extended(
                  onPressed: () => Navigator.pop(ctx),
                  label: const Text("Tutup"),
                  icon: const Icon(Icons.close),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Galeri Infografis", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: Navigator.canPop(context) 
          ? IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context))
          : null,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) => _fetchData(keyword: value),
              decoration: InputDecoration(
                hintText: "Cari infografis...",
                prefixIcon: const Icon(Icons.image_search_rounded),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          // Grid Content
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
                : _listInfo.isEmpty
                    ? const Center(child: Text("Infografis tidak ditemukan"))
                    : GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 Kolom
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75, // Perbandingan tinggi lebar (Portrait)
                        ),
                        itemCount: _listInfo.length,
                        itemBuilder: (context, index) {
                          final item = _listInfo[index];
                          return _buildInfoItem(context, item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // WIDGET ITEM (YANG SUDAH DIPERBAIKI)
  Widget _buildInfoItem(BuildContext context, BpsInfografis item) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showImageDialog(context, item.img, item.title, item.dl),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // GAMBAR DENGAN LOADING & ERROR HANDLER
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  _constructImageUrl(item.img),
                  fit: BoxFit.cover,
                  // Tampilkan loading saat gambar sedang diambil
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                      ),
                    );
                  },
                  // Tampilkan ikon rusak jika gambar gagal dimuat
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_rounded, color: Colors.grey, size: 30),
                          SizedBox(height: 4),
                          Text("Gagal Muat", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            // Judul
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}